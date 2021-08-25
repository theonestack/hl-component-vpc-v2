require 'ipaddr'
require "#{ENV['CF_COMPONENT_PATH']}/ext/cfndsl/subnets"

CfhighlanderTemplate do
  Name 'vpc-v2'
  
  DependsOn 'lib-iam@0.1.0'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    
    ComponentParam 'DnsDomain', 
      isGlobal: true,
      description: 'the root zone used to create the route53 hosted zone'
    
    ComponentParam 'CIDR', vpc_cidr,
      description: 'override the default vpc cidr in the config'
    
    net = IPAddr.new(vpc_cidr)
    
    if subnet_parameters
        
      subnets.each_with_index do |(subnet,cfg),index|
        next unless cfg['enable']
        subnets = []
        max_availability_zones.times {|az| subnets << calculate_subnet((az+index*subnet_multiplyer),vpc_cidr,subnet_mask) }
        ComponentParam "#{cfg['name']}SubnetList", subnets.join(','), type: 'CommaDelimitedList'
      end
      
    else
      ComponentParam 'SubnetBits', (32 - subnet_mask).to_s,
        description: 'The number of subnet bits for the each subnet CIDR. For example, specifying a value "8" for this parameter will create a CIDR with a mask of "/24"'
    end
    
    ComponentParam 'AvailabilityZones', max_availability_zones, 
      allowedValues: (1..max_availability_zones).to_a,
      description: 'Set the Availabiltiy Zone count for the stack',
      isGlobal: true
      
    ComponentParam 'NatGateways', max_availability_zones, 
      allowedValues: (1..max_availability_zones).to_a,
      description: 'NAT Gateway count. If larger than AvailabilityZones value, the smaller is used.'
      
    ComponentParam 'NatGatewayEIPs', "", 
      type: 'CommaDelimitedList',
      description: 'List of EIP Ids, must be the same length as NatGateways'
    
    if enable_transit_vpc
      ComponentParam 'EnableTransitVPC', 'false', 
        description: 'Allows conditional creation of the the transit vpc resources'
    end
    
    ComponentParam 'NatType', 'managed', 
      allowedValues: ['managed','instances','disabled']
      
    ComponentParam 'NatAmi', '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-ebs',
      type: String
      
    ComponentParam 'NatInstanceType', 't3.nano'
    
    ComponentParam 'NatInstancesSpot', 'true', 
      allowedValues: ['true','false']
    
  end
  
  Component template: 'route53-zone@1.0.2', name: 'dnszone', render: Inline do
    parameter name: 'CreateZone', value: 'true'
    parameter name: 'RootDomainName', value: FnSub('${DnsDomain}.')
  end if manage_ns_records && create_hosted_zone

end
