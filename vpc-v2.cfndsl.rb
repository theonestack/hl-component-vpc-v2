require 'ipaddr'

CloudFormation do
  
  vpc_tags, route_tables = Array.new(2) { [] }
  
  vpc_tags.push({ Key: 'Name', Value: FnSub("${EnvironmentName}-vpc") })
  vpc_tags.push({ Key: 'Environment', Value: Ref(:EnvironmentName) })
  vpc_tags.push({ Key: 'EnvironmentType', Value: Ref(:EnvironmentType) })
  vpc_tags.push(*tags.map {|k,v| {Key: k, Value: FnSub(v)}}).uniq { |h| h[:Key] } if defined? tags
    
  ###
  # VPC
  ###
  
  net = IPAddr.new(vpc_cidr)
  vpc_mask = vpc_cidr.split('/').last.to_i
  
  if vpc_mask < 16 || vpc_mask > 28
    raise ArgumentError, "The VPC CIDR block size must be from /16 to /28"
  end
  
  if subnet_mask.to_i < vpc_mask
    raise ArgumentError, "The Subnet CIDR block size must larger than the VPC CIDR block size"
  end
  
  if subnet_mask.to_i < 16 || subnet_mask.to_i > 28
    raise ArgumentError, "The Subnet CIDR block size must be from /16 to /28"
  end
  
  EC2_VPC(:VPC) {
    CidrBlock Ref('CIDR')
    EnableDnsSupport true
    EnableDnsHostnames true
    Tags vpc_tags
  }
  
  Output(:VPCId) {
    Value(Ref(:VPC))
    Export FnSub("${EnvironmentName}-#{component_name}-VPCId")
  }
  
  Output(:VPCCidr) {
    Value(FnGetAtt(:VPC, :CidrBlock))
    Export FnSub("${EnvironmentName}-#{component_name}-VPCCidr")
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
  
  ###
  # Network Access Control Lists
  ###
  
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
      direction = (rule.has_key?('egress') && rule['egress']) ? 'Outbound' : 'Inbound'
      
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
  
  ##
  # NAT Resource and conditions
  ##
  
  Condition(:CreateNatGatewayEIP, FnEquals(FnJoin("", Ref(:NatGatewayEIPs)), ""))
  Condition(:SpotEnabled, FnEquals(Ref(:NatInstancesSpot), 'true'))
  Condition(:ManagedNat, FnEquals(Ref(:NatType), 'managed'))
  Condition(:NatInstance, FnEquals(Ref(:NatType), 'instances'))
      
  EC2_SecurityGroup(:NatInstanceSecurityGroup) { 
    Condition(:NatInstance)
    VpcId Ref(:VPC)
    GroupDescription FnSub("${EnvironmentName} NAT Instances")
    SecurityGroupIngress([
      {
        CidrIp: FnGetAtt(:VPC, :CidrBlock),
        Description: "inbound all for ports from vpc cidr",
        IpProtocol: -1,
      }
    ])
    SecurityGroupEgress([
      {
        CidrIp: "0.0.0.0/0",
        Description: "outbound all for ports",
        IpProtocol: -1,
      }
    ])
    Tags vpc_tags
  }
  
  IAM_Role(:NatInstanceRole) {
    Condition(:NatInstance)
    AssumeRolePolicyDocument service_assume_role_policy('ec2')
    Path '/'
    Policies iam_role_policies(nat_iam_policies)
  }
      
  InstanceProfile(:NatInstanceProfile) {
    Condition(:NatInstance)
    Path '/'
    Roles [Ref(:NatInstanceRole)]
  }
  
  max_availability_zones.times do |az|
    
    get_az = { AZ: FnSelect(az, FnGetAZs(Ref('AWS::Region'))) }
    matches = ((az+1)..max_availability_zones).to_a
    
    # Determins whether we create resources in a particular availability zone
    Condition("CreateAvailabiltiyZone#{az}",
      if matches.length == 1
        FnEquals(Ref(:AvailabiltiyZones), max_availability_zones)
      else
        FnOr(matches.map { |i| FnEquals(Ref(:AvailabiltiyZones), i) })
      end
    )
    
    # Determins whether we create a Manage Nat Gateway for this availability zone
    Condition("CreateManagedNat#{az}",
      if matches.length == 1
        FnAnd([
          Condition("CreateAvailabiltiyZone#{az}"),
          Condition(:ManagedNat),
          FnEquals(Ref(:NatGateways), max_availability_zones)
        ])
      else
        FnAnd([
          Condition("CreateAvailabiltiyZone#{az}"),
          Condition(:ManagedNat),
          FnOr(matches.map { |i| FnEquals(Ref(:NatGateways), i) })
        ])
      end
    )
    
    # Determins whether we create a Nat EC2 Inatnce for this availability zone
    Condition("CreateNatInstance#{az}",
      if matches.length == 1
        FnAnd([
          Condition("CreateAvailabiltiyZone#{az}"),
          Condition(:NatInstance),
          FnEquals(Ref(:NatGateways), max_availability_zones)
        ])
      else
        FnAnd([
          Condition("CreateAvailabiltiyZone#{az}"),
          Condition(:NatInstance),
          FnOr(matches.map { |i| FnEquals(Ref(:NatGateways), i) })
        ])
      end
    )
    
    # Determins whether we create a default public route through the manage NAT Gateway for this availability zone 
    Condition("CreateManagedNatRoute#{az}",
      FnAnd([
        Condition("CreateAvailabiltiyZone#{az}"),
        Condition(:ManagedNat)
      ])
    )
    
    # Determins whether we create a default public route through the NAT EC2 Instance for this availability zone 
    Condition("CreateNatInstanceRoute#{az}",
      FnAnd([
        Condition("CreateAvailabiltiyZone#{az}"),
        Condition(:NatInstance)
      ])
    )
    
    # Determins whether we create a Elastic Public IP for this availability zone
    # This works across both managed nat and nat instances
    # We always want a EIP created even when disabled selected to allow transition between managed and instance with out loosing the IP
    Condition("CreateNatGatewayEIP#{az}", 
    if matches.length == 1
      FnAnd([
        Condition("CreateAvailabiltiyZone#{az}"),
        Condition('CreateNatGatewayEIP'),
        FnEquals(Ref(:NatGateways), max_availability_zones)
      ])
    else
      FnAnd([
        Condition("CreateAvailabiltiyZone#{az}"),
        Condition('CreateNatGatewayEIP'),
        FnOr(matches.map { |i| FnEquals(Ref(:NatGateways), i) })
      ])
    end
    )
        
    EC2_RouteTable("RouteTablePrivate#{az}") {
      VpcId Ref(:VPC)
      Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-private-${AZ}", get_az) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    route_tables.push(Ref("RouteTablePrivate#{az}"))
    
    EC2_EIP("NatIPAddress#{az}") {
      Condition "CreateNatGatewayEIP#{az}"
      DependsOn ["AttachGateway"]
      Domain 'vpc'
      Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-nat-${AZ}", get_az) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    ##
    # Managed Nat Gateway
    ##
        
    EC2_NatGateway("NatGateway#{az}") {
      Condition("CreateManagedNat#{az}")
      AllocationId FnIf(:CreateNatGatewayEIP, 
        FnGetAtt("NatIPAddress#{az}", :AllocationId),
        FnSelect(az, Ref(:NatGatewayEIPs)))
      SubnetId Ref("SubnetPublic#{az}")
      Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-natgw-${AZ}", get_az) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    EC2_Route("RouteOutToInternet#{az}") {
      Condition("CreateManagedNatRoute#{az}")
      RouteTableId Ref("RouteTablePrivate#{az}")
      DestinationCidrBlock '0.0.0.0/0'
      NatGatewayId FnIf("CreateManagedNat#{az}", 
        Ref("NatGateway#{az}"), 
        Ref("NatGateway0")) # defaults to nat 0 if no nat in that az
    }
    
    ##
    # Nat Gateway Instances
    ##
        
    nat_tags = vpc_tags.map(&:clone)
    nat_tags.push({ Key: 'Name', Value: FnSub("${EnvironmentName}-nat-${AZ}", get_az) })
    nat_tags = nat_tags.reverse.uniq { |h| h[:Key] }
    
    EC2_NetworkInterface("NetworkInterface#{az}") {
      Condition("CreateNatInstance#{az}")
      SubnetId Ref("SubnetPublic#{az}")
      SourceDestCheck false
      GroupSet [Ref(:NatInstanceSecurityGroup)]
      Tags nat_tags
    }
    
    EC2_EIPAssociation("EIPAssociation#{az}") {
      Condition("CreateNatInstance#{az}")
      AllocationId FnIf(:CreateNatGatewayEIP, 
        FnGetAtt("NatIPAddress#{az}", :AllocationId),
        FnSelect(az, Ref(:NatGatewayEIPs)))
      NetworkInterfaceId Ref("NetworkInterface#{az}")
    }

    nat_userdata = <<~USERDATA
      #!/bin/bash
      INSTANCE_ID=$(curl http://169.254.169.254/2014-11-05/meta-data/instance-id -s)
      aws ec2 attach-network-interface --instance-id $INSTANCE_ID --network-interface-id ${NetworkInterface#{az}} --device-index 1 --region ${AWS::Region}
      sysctl -w net.ipv4.ip_forward=1
      iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
      GW=$(curl -s http://169.254.169.254/2014-11-05/meta-data/local-ipv4/ | cut -d '.' -f 1-3).1
      route del -net 0.0.0.0 gw $GW netmask 0.0.0.0 dev eth0 metric 0
      route add -net 0.0.0.0 gw $GW netmask 0.0.0.0 dev eth0 metric 10002
      EOF
      systemctl disable postfix
    USERDATA

    template_data = {
      TagSpecifications: [
        { ResourceType: 'instance', Tags: nat_tags },
        { ResourceType: 'volume', Tags: nat_tags }
      ],
      ImageId: Ref(:NatAmi),
      InstanceType: Ref(:NatInstanceType),
      UserData: FnBase64(FnSub(nat_userdata)),
      IamInstanceProfile: { Name: Ref(:NatInstanceProfile) },
      NetworkInterfaces: [{
        DeviceIndex: 0,
        AssociatePublicIpAddress: true,
        Groups: [ Ref(:NatInstanceSecurityGroup) ]
      }]
    }
    
    spot_options = {
      MarketType: 'spot',
      SpotOptions: {
        SpotInstanceType: 'one-time',
      }
    }
    template_data[:InstanceMarketOptions] = FnIf(:SpotEnabled, spot_options, Ref('AWS::NoValue'))

    EC2_LaunchTemplate("LaunchTemplate#{az}") {
      Condition("CreateNatInstance#{az}")
      LaunchTemplateData(template_data)
    }
    
    asg_tags = nat_tags.map(&:clone)
    
    AutoScaling_AutoScalingGroup("AutoScaleGroup#{az}") {
      Condition("CreateNatInstance#{az}")
      UpdatePolicy(:AutoScalingRollingUpdate, {
        MaxBatchSize: '1',
        MinInstancesInService: 0,
        SuspendProcesses: %w(HealthCheck ReplaceUnhealthy AZRebalance AlarmNotification ScheduledActions)
      })  
      UpdatePolicy(:AutoScalingScheduledAction, {
        IgnoreUnmodifiedGroupSizeProperties: true
      })
      DesiredCapacity '1'
      MinSize '1'
      MaxSize '1'
      VPCZoneIdentifier [Ref("SubnetPublic#{az}")]
      LaunchTemplate({
        LaunchTemplateId: Ref("LaunchTemplate#{az}"),
        Version: FnGetAtt("LaunchTemplate#{az}", :LatestVersionNumber)
      })
      Tags asg_tags.each {|h| h[:PropagateAtLaunch]=false}
    }
    
    EC2_Route("RouteOutToInternet#{az}ViaNatInstance") {
      Condition("CreateNatInstanceRoute#{az}")
      RouteTableId Ref("RouteTablePrivate#{az}")
      DestinationCidrBlock '0.0.0.0/0'
      NetworkInterfaceId FnIf("CreateNatInstance#{az}",
        Ref("NetworkInterface#{az}"),
        Ref("NetworkInterface0")) # defaults to nat 0 if no nat in that az
    }
    
  end
  
  ##
  # Subnets
  ##
  subnet_groups = {}
  
  subnets.each_with_index do |(subnet,cfg),index|
    next unless cfg['enable']
    
    subnet_grp_refs = []

    max_availability_zones.times do |az|
      multiplyer = az+index*subnet_multiplyer
      subnet_name_az = "Subnet#{cfg['name']}#{az}"
      get_az = { AZ: FnSelect(az, FnGetAZs(Ref('AWS::Region'))) }
      
      if subnet_parameters
        subnet_cidr = FnSelect(az, Ref("#{cfg['name']}SubnetList"))
      else
        subnet_cidr = FnSelect(multiplyer,FnCidr(Ref('CIDR'),(subnet_multiplyer*subnets.length),Ref('SubnetBits')))
      end

      EC2_Subnet(subnet_name_az) {
        Condition("CreateAvailabiltiyZone#{az}")
        VpcId Ref(:VPC)
        CidrBlock subnet_cidr
        AvailabilityZone FnSelect(az, FnGetAZs(Ref('AWS::Region')))
        Tags [
          { Key: 'Name', Value: FnSub("${EnvironmentName}-#{cfg['name'].downcase}-${AZ}", get_az) },
          { Key: 'Type', Value: cfg['type'] }
        ].push(*vpc_tags).uniq! { |t| t[:Key] }
      }
      
      subnet_grp_refs.push(Ref(subnet_name_az))
      
      route_table = cfg['type'].downcase == 'public' ? 'RouteTablePublic' : "RouteTablePrivate#{az}"
      
      EC2_SubnetRouteTableAssociation("RouteTableAssociation#{subnet_name_az}") {
        Condition("CreateAvailabiltiyZone#{az}")
        SubnetId Ref(subnet_name_az)
        RouteTableId Ref(route_table)
      }
      
      EC2_SubnetNetworkAclAssociation("ACLAssociation#{subnet_name_az}") {
        Condition("CreateAvailabiltiyZone#{az}")
        SubnetId Ref(subnet_name_az)
        NetworkAclId Ref("NetworkAcl#{cfg['type'].capitalize}")
      }
      
    end
    
    subnet_grp_condition = ''
    max_availability_zones.times do |az|
      subnet_grp_condition = FnIf("CreateAvailabiltiyZone#{az}", subnet_grp_refs[0..az], subnet_grp_condition)
    end
    
    Output("#{cfg['name']}Subnets") {
      Value(FnJoin(',', subnet_grp_condition))
      Export FnSub("${EnvironmentName}-#{component_name}-#{cfg['name']}Subnets")
    }
    
    subnet_groups[cfg['name']] = subnet_grp_condition

  end

  ##
  # VPC Endpoints
  ##

  EC2_VPCEndpoint(:S3VpcEndpoint) {
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
  
  Output(:S3VPCEndpointId) {
    Value(Ref(:S3VpcEndpoint))
    Export FnSub("${EnvironmentName}-#{component_name}-S3VPCEndpointId")
  }
  
  if (defined? endpoints) && (endpoints.any?)
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
      vpce = endpoint.gsub(/[^0-9a-z ]/i, '')
      EC2_VPCEndpoint("#{vpce.capitalize}VpcEndpoint") {
        VpcId Ref(:VPC)
        ServiceName FnSub("com.amazonaws.${AWS::Region}.#{endpoint}")
        VpcEndpointType "Interface"
        PrivateDnsEnabled true
        SubnetIds subnet_groups[endpoint_subnets]
        SecurityGroupIds [ Ref(:VpcEndpointInterface) ]
      }
    end
  end
  
  ##
  # Transit VPC
  ##
  
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
  
  ##
  # VPC Flow logs
  ##
  
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
  
  ##
  # Route 53
  ##
  
  if !manage_ns_records && create_hosted_zone
    Route53_HostedZone(:HostedZone) {
      Name FnSub(dns_format)
      HostedZoneConfig ({
        Comment: FnSub("Hosted Zone for ${EnvironmentName}")
      })
      HostedZoneTags [{Key: 'Name', Value: FnSub(dns_format) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    Output(:HostedZone) {
      Value(Ref(:HostedZone))
      Export FnSub("${EnvironmentName}-#{component_name}-hosted-zone")
    }
  end
    
end
