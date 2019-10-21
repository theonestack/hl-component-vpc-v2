require 'netaddr'

CloudFormation do
  
  vpc_tags, route_tables, subnet_refs = Array.new(3) { [] }
  
  vpc_tags.push({ Key: 'Name', Value: FnSub("${EnvironmentName}-vpc") })
  vpc_tags.push({ Key: 'Environment', Value: Ref(:EnvironmentName) })
  vpc_tags.push({ Key: 'EnvironmentType', Value: Ref(:EnvironmentType) })
  vpc_tags.push(*tags.map {|k,v| {Key: k, Value: FnSub(v)}}).uniq { |h| h[:Key] } if defined? tags
  
  net = NetAddr::IPv4Net.parse(vpc_cidr)
  static_bits = net.network.to_s.split('.').drop(net.netmask.prefix_len/8)
  
  # VPC
  EC2_VPC(:VPC) {
    CidrBlock FnSub("${NetworkPrefix}.#{static_bits.join('.')}/#{net.netmask.prefix_len}")
    EnableDnsSupport true
    EnableDnsHostnames true
    Tags vpc_tags
  }
  
  EC2_DHCPOptions(:DHCPOptionSet) {
    DomainName FnSub(dns_format)
    DomainNameServers ['AmazonProvidedDNS']
    Tags vpc_tags
  }

  EC2_VPCDHCPOptionsAssociation(:DHCPOptionsAssociation) {
    VpcId Ref(:VPC)
    DhcpOptionsId Ref(:DHCPOptionSet)
  }
  
  EC2_InternetGateway(:InternetGateway) {
    Tags vpc_tags
  }
  
  EC2_VPCGatewayAttachment(:AttachGateway){
    VpcId Ref(:VPC)
    InternetGatewayId Ref(:InternetGateway)
  }
  
  EC2_RouteTable(:RouteTablePublic) {
    VpcId Ref(:VPC)
    Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-public") }].push(*vpc_tags).uniq! { |t| t[:Key] }
  }
    
  EC2_NetworkAcl(:NetworkAclPublic) {
    VpcId Ref(:VPC)
    Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-public") }].push(*vpc_tags).uniq! { |t| t[:Key] }
  }
  
  EC2_NetworkAcl(:NetworkAclPrivate) {
    VpcId Ref(:VPC)
    Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-private") }].push(*vpc_tags).uniq! { |t| t[:Key] }
  }
  
  EC2_Route(:PublicRouteOutToInternet) {
    DependsOn ['AttachGateway']
    RouteTableId Ref(:RouteTablePublic)
    DestinationCidrBlock '0.0.0.0/0'
    GatewayId Ref(:InternetGateway)
  }
  
  acl_rules.each do |rule|
    cidrs = []
    
    if rule.has_key?('ips')
      cidrs.push(*rule['ips'].map {|ip| is_cidr?(ip) ? ip : ip_lookup(ip,ip_blocks) }.flatten(1))
    elsif rule.has_key?('cidr')
      cidrs.push(rule['cidr'])
    else
      cidrs.push('0.0.0.0/0')
    end
    
    cidrs.each_with_index do |cidr,index|
      rule_number = rule['number'] + index
      direction = (rule.has_key?('egress') && rule['egress']) ? 'Inbound' : 'Outbound'
      
      EC2_NetworkAclEntry("NaclRule#{direction}#{rule['acl'].capitalize}#{rule_number}") {
        NetworkAclId Ref("NetworkAcl#{rule['acl'].capitalize}")
        RuleNumber rule_number
        Protocol rule['protocol'] || '6'
        RuleAction rule['action'] || 'allow'
        Egress rule['egress'] || false
        CidrBlock cidr
        unless rule.has_key?('protocol') && rule['protocol'].to_s == '-1'
          PortRange ({ From: rule['from'], To: rule['to'] || rule['from'] })
        end
      }
    end
  end
  
  Condition('CreateNatGatewayEIP', FnEquals(FnJoin('', Ref('NatGatewayEIPs')), ''))
  
  max_availability_zones.times do |az|
    
    get_az = { AZ: FnSelect(az, FnGetAZs(Ref('AWS::Region'))) }
    matches = ((az+1)..max_availability_zones).to_a
    
    Condition("CreateNatGateway#{az}",
      if matches.length == 1
        FnEquals(Ref(:NatGateways), max_availability_zones)
      else
        FnOr(matches.map { |i| FnEquals(Ref(:NatGateways), i) })
      end
    )
    
    Condition("CreateNatGatewayEIP#{az}", FnAnd([
      Condition("CreateNatGateway#{az}"),
      Condition('CreateNatGatewayEIP')
    ]))
        
    EC2_RouteTable("RouteTablePrivate#{az}") {
      VpcId Ref(:VPC)
      Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-private-${AZ}", get_az) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    route_tables.push(Ref("RouteTablePrivate#{az}"))
    
    EC2_EIP("NatIPAddress#{az}") {
      Condition("CreateNatGatewayEIP#{az}")
      DependsOn ["AttachGateway"]
      Domain 'vpc'
    }
    
    EC2_NatGateway("NatGateway#{az}") {
      Condition("CreateNatGateway#{az}")
      AllocationId FnIf('CreateNatGatewayEIP', 
        FnGetAtt("NatIPAddress#{az}", 'AllocationId'),
        FnSelect(az, Ref('NatGatewayEIPs')))
      SubnetId Ref("SubnetPublic#{az}")
      Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-natgw-${AZ}", get_az) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    EC2_Route("RouteOutToInternet#{az}") {
      RouteTableId Ref("RouteTablePrivate#{az}")
      DestinationCidrBlock '0.0.0.0/0'
      NatGatewayId FnIf("CreateNatGateway#{az}", 
        Ref("NatGateway#{az}"), 
        Ref("NatGateway0"))
    }
    
  end
  
  # Subnets
  subnets.each_with_index do |(subnet,cfg),index|
    
    subnet_grp_refs = []
    
    max_availability_zones.times do |az|
      multiplyer = az + index * subnet_multiplyer
      
      subnet_cidr = net.nth_subnet(subnet_mask,multiplyer).to_s
      subnet_cidr = subnet_cidr.split('.').drop(static_bits.length)

      subnet_name_az = "Subnet#{cfg['name']}#{az}"
      
      get_az = { AZ: FnSelect(az, FnGetAZs(Ref('AWS::Region'))) }

      EC2_Subnet(subnet_name_az) {
        VpcId Ref(:VPC)
        CidrBlock FnSub("${NetworkPrefix}.#{subnet_cidr.join('.')}")
        AvailabilityZone FnSelect(az, FnGetAZs(Ref('AWS::Region')))
        Tags [
          { Key: 'Name', Value: FnSub("${EnvironmentName}-#{cfg['name'].downcase}-${AZ}", get_az) },
          { Key: 'Type', Value: cfg['type'] }
        ].push(*vpc_tags).uniq! { |t| t[:Key] }
      }
      
      subnet_refs.push(Ref(subnet_name_az))
      subnet_grp_refs.push(Ref(subnet_name_az))
      
      route_table = cfg['type'].downcase == 'public' ? 'RouteTablePublic' : "RouteTablePrivate#{az}"
      
      EC2_SubnetRouteTableAssociation("RouteTableAssociation#{subnet_name_az}") { 
        SubnetId Ref(subnet_name_az)
        RouteTableId Ref(route_table)
      }
      
      EC2_SubnetNetworkAclAssociation("ACLAssociation#{subnet_name_az}") {
        SubnetId Ref(subnet_name_az)
        NetworkAclId Ref("NetworkAcl#{cfg['type'].capitalize}")
      }
      
    end
    
    Output("#{cfg['name']}Subnets") {
      Value(FnJoin(',', subnet_grp_refs))
      Export FnSub("${EnvironmentName}-#{component_name}-#{cfg['name']}Subnets")
    }
        
  end
  
  EC2_SecurityGroup(:VpcEndpointInterface) {
    VpcId Ref(:VPC)
    GroupDescription FnSub("Access to Amazon service VPC Endpoints from within the ${EnvironmentName} VPC")
    SecurityGroupIngress([
      {
        CidrIp: FnGetAtt(:VPC, :CidrBlock),
        Description: FnSub("HTTPS from ${EnvironmentName} VPC"),
        IpProtocol: 'tcp',
        FromPort: '443',
        ToPort: '443'
      }
    ])
  } 
  
  endpoints.each do |endpoint|
    if endpoint.downcase == 's3'
      
      EC2_VPCEndpoint("#{endpoint.capitalize}VpcEndpoint") {
        VpcId Ref(:VPC)
        PolicyDocument({
          Version: "2012-10-17",
          Statement: [{
            Effect: "Allow",
            Principal: "*",
            Action: ["s3:*"],
            Resource: ["arn:aws:s3:::*"]
          }]
        })
        ServiceName FnSub("com.amazonaws.${AWS::Region}.s3")
        RouteTableIds route_tables
      }
      
    else
      
      EC2_VPCEndpoint("#{endpoint.capitalize}VpcEndpoint") {
        VpcId Ref(:VPC)
        ServiceName FnSub("com.amazonaws.${AWS::Region}.#{endpoint}")
        VpcEndpointType "Interface"
        PrivateDnsEnabled true
        SubnetIds subnet_refs
        SecurityGroupIds [ Ref(:VpcEndpointInterface) ]
      }
      
    end
  end
  
  if enable_transit_vpc
    Condition('DoEnableTransitVPC', FnEquals(Ref('EnableTransitVPC'),'true'))
    
    transit_vpc_tags = [
        { Key: 'Name', Value: FnSub("${EnvironmentName}-VGW") },
        { Key: 'transitvpc:spoke', Value: Ref('EnableTransitVPC') }
    ]
    
    VPNGateway(:VGW) {
      Condition('DoEnableTransitVPC')
      Type 'ipsec.1'
      Tags transit_vpc_tags.push(*vpc_tags).uniq! { |t| t[:Key] }
    }

    VPCGatewayAttachment(:AttachVGWToVPC) {
      Condition('DoEnableTransitVPC')
      VpcId Ref(:VPC)
      VpnGatewayId Ref(:VGW)
    }

    VPNGatewayRoutePropagation(:PropagateRoute) {
      Condition('DoEnableTransitVPC')
      DependsOn ['AttachVGWToVPC']
      RouteTableIds route_tables
      VpnGatewayId Ref(:VGW)
    }
  end
  
  if defined?(flowlogs)
    log_retention = (flowlogs.is_a?(Hash) && flowlogs.has_key?('log_retention')) ? flowlogs['log_retention'] : 7

    Logs_LogGroup(:FlowLogsLogGroup) {
      LogGroupName FnSub("${EnvironmentName}-vpc-flowlogs")
      RetentionInDays "#{log_retention}"
    }

    IAM_Role(:PutVPCFlowLogsRole) {
      AssumeRolePolicyDocument service_role_assume_policy('vpc-flow-logs')
      Path '/'
      Policies ([
        PolicyName: 'PutVPCFlowLogsRole',
        PolicyDocument: {
          Statement: [
            {
              Effect: 'Allow',
              Action: [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
              ],
              Resource: '*'
            }
          ]
        }
      ])
    }

    EC2_FlowLog(:VPCFlowLogs) {
      DeliverLogsPermissionArn FnGetAtt(:PutVPCFlowLogsRole, :Arn)
      LogGroupName Ref(:FlowLogsLogGroup)
      ResourceId Ref(:VPC)
      ResourceType 'VPC'
      TrafficType (flowlogs.is_a?(Hash) && flowlogs.has_key?('traffic_type')) ? flowlogs['traffic_type'] : 'ALL'
    }
    
  end
  
  Output(:VPCId) {
    Value(Ref(:VPC))
    Export FnSub("${EnvironmentName}-#{component_name}-VPCId")
  }
  
  Output(:VPCCidr) {
    Value(FnGetAtt(:VPC, :CidrBlock))
    Export FnSub("${EnvironmentName}-#{component_name}-VPCCidr")
  }
  
end
