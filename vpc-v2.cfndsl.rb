require 'ipaddr'

CloudFormation do

  export = external_parameters.fetch(:export_name, external_parameters[:component_name])
  
  tags = external_parameters.fetch(:tags, {})

  custom_routes = external_parameters.fetch(:custom_routes, {})

  vpc_tags, route_tables = Array.new(2) { [] }
  
  vpc_tags.push({ Key: 'Name', Value: FnSub("${EnvironmentName}-vpc") })
  vpc_tags.push({ Key: 'Environment', Value: Ref(:EnvironmentName) })
  vpc_tags.push({ Key: 'EnvironmentType', Value: Ref(:EnvironmentType) })
  vpc_tags.push(*tags.map {|k,v| {Key: FnSub(k), Value: FnSub(v)}})
    
  ###
  # VPC
  ###
  
  net = IPAddr.new(external_parameters[:vpc_cidr])
  vpc_mask = external_parameters[:vpc_cidr].split('/').last.to_i
  subnet_mask = external_parameters[:subnet_mask].to_i
  
  if vpc_mask < 16 || vpc_mask > 28
    raise ArgumentError, "The VPC CIDR block size must be from /16 to /28"
  end
  
  if subnet_mask < vpc_mask
    raise ArgumentError, "The Subnet CIDR block size must larger than the VPC CIDR block size"
  end
  
  if subnet_mask < 16 || subnet_mask > 28
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
    Export FnSub("${EnvironmentName}-#{export}-VPCId")
  }
  
  Output(:VPCCidr) {
    Value(FnGetAtt(:VPC, :CidrBlock))
    Export FnSub("${EnvironmentName}-#{export}-VPCCidr")
  }
  
  Output(:DefaultSecurityGroup) {
    Value(FnGetAtt(:VPC, :DefaultSecurityGroup))
    Export FnSub("${EnvironmentName}-#{export}-DefaultSecurityGroup")
  }
  
  if external_parameters[:enable_dhcp]
    EC2_DHCPOptions(:DHCPOptionSet) {
      DomainName FnSub(external_parameters[:dns_format])
      DomainNameServers ['AmazonProvidedDNS']
      Tags vpc_tags
    }

    EC2_VPCDHCPOptionsAssociation(:DHCPOptionsAssociation) {
      VpcId Ref(:VPC)
      DhcpOptionsId Ref(:DHCPOptionSet)
    }
  end
  
  if external_parameters[:enable_internet_gateway]
    EC2_InternetGateway(:InternetGateway) {
      Tags vpc_tags
    }
  
    EC2_VPCGatewayAttachment(:AttachGateway){
      VpcId Ref(:VPC)
      InternetGatewayId Ref(:InternetGateway)
    }
  end
  
  EC2_RouteTable(:RouteTablePublic) {
    VpcId Ref(:VPC)
    Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-public") }].push(*vpc_tags).uniq! { |t| t[:Key] }
  }
  Output(:PublicRouteTableIds) {
    Value(Ref(:RouteTablePublic))
    Export FnSub("${EnvironmentName}-#{export}-PublicRouteTableIds")
  }
    
  EC2_NetworkAcl(:NetworkAclPublic) {
    VpcId Ref(:VPC)
    Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-public") }].push(*vpc_tags).uniq! { |t| t[:Key] }
  }
  
  EC2_NetworkAcl(:NetworkAclPrivate) {
    VpcId Ref(:VPC)
    Tags [{Key: 'Name', Value: FnSub("${EnvironmentName}-private") }].push(*vpc_tags).uniq! { |t| t[:Key] }
  }

  if external_parameters[:enable_internet_gateway]
    EC2_Route(:PublicRouteOutToInternet) {
      DependsOn ['AttachGateway']
      RouteTableId Ref(:RouteTablePublic)
      DestinationCidrBlock '0.0.0.0/0'
      GatewayId Ref(:InternetGateway)
    }
  end

  ##
  # Custom routes
  ##
  if custom_routes.length > 0
    custom_routes.each_with_index do |(key,value),index|

      if value.is_a?(String)
        routeType = value.split('-').first
        routeValue = value
      else
        routeType = value['type']
        routeValue = value['value']
      end
      
      EC2_Route("CustomRoutePublic#{index}") {
        DependsOn ['AttachGateway']
        RouteTableId Ref(:RouteTablePublic)
        DestinationCidrBlock key
        case routeType
        when "tgw"
          TransitGatewayId routeValue
        when "eigw"
          EgressOnlyInternetGatewayId routeValue
        when "vpce"
          VpcEndpointId routeValue
        when "vgw"
          GatewayId routeValue
        when "igw"
          GatewayId routeValue
        when "nat"
          NatGatewayId routeValue
        when "i"
          InstanceId routeValue
        when "eni"
          NetworkInterfaceId routeValue
        when "pcx"
          VpcPeeringConnectionId routeValue
        when "lgw"
          LocalGatewayId routeValue
        end
      }
      
    end
  end
  
  ###
  # Network Access Control Lists
  ###
    
  external_parameters[:acl_rules].each do |rule|
    cidrs = []
    
    if rule.has_key?('ips')
      cidrs.push(*rule['ips'].map {|ip| is_cidr?(ip) ? ip : ip_lookup(ip,external_parameters[:ip_blocks]) }.flatten(1))
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
  
  Condition(:CreateNatGatewayEIP, FnAnd([FnEquals(FnJoin("", Ref(:NatGatewayEIPs)), ""),FnNot(Condition(:NatDisabled))]))
  Condition(:SpotEnabled, FnEquals(Ref(:NatInstancesSpot), 'true'))
  Condition(:ManagedNat, FnEquals(Ref(:NatType), 'managed'))
  Condition(:NatInstance, FnEquals(Ref(:NatType), 'instances'))
  Condition(:NatDisabled, FnEquals(Ref(:NatType), 'disabled'))
      
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
    Policies iam_role_policies(external_parameters[:nat_iam_policies])
    ManagedPolicyArns([
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ])
  }
      
  IAM_InstanceProfile(:NatInstanceProfile) {
    Condition(:NatInstance)
    Path '/'
    Roles [Ref(:NatInstanceRole)]
  }
  
  external_parameters[:max_availability_zones].times do |az|
    
    if az_mapping == true
      get_az = { 
        AZ: FnSelect(
            FnSelect(az, 
              FnSplit(',', 
                FnFindInMap('Accounts', Ref('AWS::AccountId'), 'AZs')
              )
            ), 
          FnGetAZs(Ref('AWS::Region'))
        ) 
      }
    else
      get_az = { AZ: FnSelect(az, FnGetAZs(Ref('AWS::Region'))) }
    end
    matches = ((az+1)..external_parameters[:max_availability_zones]).to_a
    
    # Determins whether we create resources in a particular availability zone
    Condition("CreateAvailabilityZone#{az}",
      if matches.length == 1
        FnEquals(Ref(:AvailabilityZones), external_parameters[:max_availability_zones])
      else
        FnOr(matches.map { |i| FnEquals(Ref(:AvailabilityZones), i) })
      end
    )
    
    # Determins whether we create a Manage Nat Gateway for this availability zone
    Condition("CreateManagedNat#{az}",
      if matches.length == 1
        FnAnd([
          Condition("CreateAvailabilityZone#{az}"),
          Condition(:ManagedNat),
          FnEquals(Ref(:NatGateways), external_parameters[:max_availability_zones])
        ])
      else
        FnAnd([
          Condition("CreateAvailabilityZone#{az}"),
          Condition(:ManagedNat),
          FnOr(matches.map { |i| FnEquals(Ref(:NatGateways), i) })
        ])
      end
    )
    
    # Determins whether we create a Nat EC2 Inatnce for this availability zone
    Condition("CreateNatInstance#{az}",
      if matches.length == 1
        FnAnd([
          Condition("CreateAvailabilityZone#{az}"),
          Condition(:NatInstance),
          FnEquals(Ref(:NatGateways), external_parameters[:max_availability_zones])
        ])
      else
        FnAnd([
          Condition("CreateAvailabilityZone#{az}"),
          Condition(:NatInstance),
          FnOr(matches.map { |i| FnEquals(Ref(:NatGateways), i) })
        ])
      end
    )
    
    # Determins whether we create a default public route through the manage NAT Gateway for this availability zone 
    Condition("CreateManagedNatRoute#{az}",
      FnAnd([
        Condition("CreateAvailabilityZone#{az}"),
        Condition(:ManagedNat)
      ])
    )
    
    # Determins whether we create a default public route through the NAT EC2 Instance for this availability zone 
    Condition("CreateNatInstanceRoute#{az}",
      FnAnd([
        Condition("CreateAvailabilityZone#{az}"),
        Condition(:NatInstance)
      ])
    )
    
    # Determins whether we create a Elastic Public IP for this availability zone
    # This works across both managed nat and nat instances
    # We always want a EIP created even when disabled selected to allow transition between managed and instance with out loosing the IP
    Condition("CreateNatGatewayEIP#{az}", 
    if matches.length == 1
      FnAnd([
        Condition("CreateAvailabilityZone#{az}"),
        Condition('CreateNatGatewayEIP'),
        FnEquals(Ref(:NatGateways), external_parameters[:max_availability_zones])
      ])
    else
      FnAnd([
        Condition("CreateAvailabilityZone#{az}"),
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
      if external_parameters[:enable_internet_gateway]
        DependsOn ["AttachGateway"]
      end
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
    # Custom routes
    ##
    if custom_routes.length > 0
      custom_routes.each_with_index do |(key,value),index|
        if value.is_a?(String)
          routeType = value.split('-').first
          routeValue = value
        else
          routeType = value['type']
          routeValue = value['value']
        end
        
        EC2_Route("CustomRoute#{az}#{index}") {
          RouteTableId Ref("RouteTablePrivate#{az}")
          DestinationCidrBlock key
          case routeType
          when "tgw"
            TransitGatewayId routeValue
          when "eigw"
            EgressOnlyInternetGatewayId routeValue
          when "vpce"
            VpcEndpointId routeValue
          when "vgw"
            GatewayId routeValue
          when "igw"
            GatewayId routeValue
          when "nat"
            NatGatewayId routeValue
          when "i"
            InstanceId routeValue
          when "eni"
            NetworkInterfaceId routeValue
          when "pcx"
            VpcPeeringConnectionId routeValue
          when "lgw"
            LocalGatewayId routeValue
          end
        }
        
      end
    end
    
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

    if external_parameters[:nat_userdata]
      nat_userdata = external_parameters[:nat_userdata]
    else  
      nat_userdata = <<~USERDATA
        #!/bin/bash
        INSTANCE_ID=$(curl http://169.254.169.254/2014-11-05/meta-data/instance-id -s)
        aws ec2 attach-network-interface --instance-id $INSTANCE_ID --network-interface-id ${NetworkInterface#{az}} --device-index 1 --region ${AWS::Region}
        /opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchTemplate#{az} --region ${AWS::Region}
        systemctl disable postfix
        systemctl stop postfix
        systemctl enable snat
        systemctl start snat
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
      Metadata({
        'AWS::CloudFormation::Init': {
          configSets: {
            default: [
              'setup'
            ]
          },
          setup: {
            files: {
              '/opt/snat.sh': {
                mode: '000755',
                owner: 'root',
                group: 'root',
                content: <<~CONTENT
                  #!/bin/bash -x

                  # wait for eth1
                  while ! ip link show dev eth1; do
                    sleep 1
                  done

                  # enable IP forwarding and NAT
                  sysctl -q -w net.ipv4.ip_forward=1
                  sysctl -q -w net.ipv4.conf.eth1.send_redirects=0
                  iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

                  # switch the default route to eth1
                  ip route del default dev eth0

                  # wait for network connection
                  curl --retry 10 http://www.example.com

                  # reestablish connections
                  systemctl restart amazon-ssm-agent.service
                CONTENT
              },
              '/etc/systemd/system/snat.service': {
                mode: '000644',
                owner: 'root',
                group: 'root',
                content: <<~CONTENT
                  [Unit]
                  Description = SNAT via ENI eth1

                  [Service]
                  ExecStart = /opt/snat.sh
                  Type = oneshot

                  [Install]
                  WantedBy = multi-user.target
                CONTENT
              }
            }
          }
        }
      })
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
  
  Output(:PrivateRouteTableIds) {
    Value(FnJoin(",",route_tables))
    Export FnSub("${EnvironmentName}-#{export}-PrivateRouteTableIds")
  }

  ##
  # Subnets
  ##
  subnet_groups = {}
  
  external_parameters[:subnets].each_with_index do |(subnet,cfg),index|
    next unless cfg['enable']
    
    subnet_grp_refs = []

    external_parameters[:max_availability_zones].times do |az|
      multiplyer = az+index*external_parameters[:subnet_multiplyer]
      subnet_name_az = "Subnet#{cfg['name']}#{az}"
      
      if az_mapping == true
        get_az = FnSelect(
              FnSelect(az, 
                FnSplit(',', 
                  FnFindInMap('Accounts', Ref('AWS::AccountId'), 'AZs')
                )
              ), 
            FnGetAZs(Ref('AWS::Region'))
          )
      else
        get_az = FnSelect(az, FnGetAZs(Ref('AWS::Region')))
      end
      
      if external_parameters[:subnet_parameters]
        subnet_cidr = FnSelect(az, Ref("#{cfg['name']}SubnetList"))
      else
        subnet_cidr = FnSelect(multiplyer,FnCidr(Ref('CIDR'),(external_parameters[:subnet_multiplyer]*external_parameters[:subnets].length),Ref('SubnetBits')))
      end

      subnet_tags = vpc_tags.map(&:clone)
      subnet_tags << { Key: 'Name', Value: FnSub("${EnvironmentName}-#{cfg['name'].downcase}-${AZ}", { AZ: get_az }) }
      subnet_tags << { Key: 'Type', Value: cfg['type'] }
      subnet_tags.push(*cfg['tags'].map{|t| t.transform_keys(&:to_sym) }) if cfg.key?('tags')

      EC2_Subnet(subnet_name_az) {
        Condition("CreateAvailabilityZone#{az}")
        VpcId Ref(:VPC)
        CidrBlock subnet_cidr
        AvailabilityZone get_az
        Tags subnet_tags.reverse.uniq {|t| t[:Key]}
      }
      
      subnet_grp_refs.push(Ref(subnet_name_az))
      
      route_table = cfg['type'].downcase == 'public' ? 'RouteTablePublic' : "RouteTablePrivate#{az}"
      
      EC2_SubnetRouteTableAssociation("RouteTableAssociation#{subnet_name_az}") {
        Condition("CreateAvailabilityZone#{az}")
        SubnetId Ref(subnet_name_az)
        RouteTableId Ref(route_table)
      }
      
      EC2_SubnetNetworkAclAssociation("ACLAssociation#{subnet_name_az}") {
        Condition("CreateAvailabilityZone#{az}")
        SubnetId Ref(subnet_name_az)
        NetworkAclId Ref("NetworkAcl#{cfg['type'].capitalize}")
      }
      
    end
    
    subnet_grp_condition = ''
    external_parameters[:max_availability_zones].times do |az|
      subnet_grp_condition = FnIf("CreateAvailabilityZone#{az}", subnet_grp_refs[0..az], subnet_grp_condition)
    end
    
    Output("#{cfg['name']}Subnets") {
      Value(FnJoin(',', subnet_grp_condition))
      Export FnSub("${EnvironmentName}-#{export}-#{cfg['name']}Subnets")
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
    Export FnSub("${EnvironmentName}-#{export}-S3VPCEndpointId")
  }

  EC2_VPCEndpoint(:DynamodbVpcEndpoint) {
    VpcId Ref(:VPC)
    ServiceName FnSub("com.amazonaws.${AWS::Region}.dynamodb")
    RouteTableIds route_tables
  }
  
  Output(:DynamodbVPCEndpointId) {
    Value(Ref(:DynamodbVpcEndpoint))
    Export FnSub("${EnvironmentName}-#{export}-DynamodbVPCEndpointId")
  }
  
  endpoints = external_parameters.fetch(:endpoints, [])
  
  if endpoints.any?
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
      Metadata({
        cfn_nag: {
          rules_to_suppress: [
            { id: 'F1000', reason: 'adding rules using cfn resources' }
          ]
        }
      })
    }
  
    endpoints.each do |endpoint|
      vpce = endpoint.gsub(/[^0-9a-z ]/i, '')
      EC2_VPCEndpoint("#{vpce.capitalize}VpcEndpoint") {
        VpcId Ref(:VPC)
        ServiceName FnSub("com.amazonaws.${AWS::Region}.#{endpoint}")
        VpcEndpointType "Interface"
        PrivateDnsEnabled true
        SubnetIds subnet_groups[external_parameters[:endpoint_subnets]]
        SecurityGroupIds [ Ref(:VpcEndpointInterface) ]
      }

      Output("#{vpce.capitalize}VPCEndpointId") {
        Value(Ref("#{vpce.capitalize}VpcEndpoint"))
        Export FnSub("${EnvironmentName}-#{export}-#{vpce.capitalize}VPCEndpointId")
      }
    end
  end
  
  ##
  # Transit VPC
  ##
  
  if external_parameters[:enable_transit_vpc]
    Condition('DoEnableTransitVPC', FnEquals(Ref('EnableTransitVPC'),'true'))
    
    transit_vpc_tags = [
        { Key: 'Name', Value: FnSub("${EnvironmentName}-VGW") },
        { Key: 'transitvpc:spoke', Value: Ref('EnableTransitVPC') }
    ]
    
    VPNGateway(:VGW) {
      Condition('DoEnableTransitVPC')
      Type 'ipsec.1'
      if external_parameters[:vgw_asn]
        AmazonSideAsn external_parameters[:vgw_asn]
      end
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
  
  flowlogs = external_parameters.fetch(:flowlogs, false)
  
  if flowlogs
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
  
  if !external_parameters[:manage_ns_records] && external_parameters[:create_hosted_zone]
    Route53_HostedZone(:HostedZone) {
      Name FnSub(external_parameters[:dns_format])
      HostedZoneConfig ({
        Comment: FnSub("Hosted Zone for ${EnvironmentName}")
      })
      HostedZoneTags [{Key: 'Name', Value: FnSub(external_parameters[:dns_format]) }].push(*vpc_tags).uniq! { |t| t[:Key] }
    }
    
    Output(:HostedZone) {
      Value(Ref(:HostedZone))
      Export FnSub("${EnvironmentName}-#{export}-hosted-zone")
    }
  end
    
end
