require 'netaddr'

CfhighlanderTemplate do
  Name 'vpc-v2'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    
    ComponentParam 'DnsDomain', 
      isGlobal: true,
      description: 'the root zone used to create the route53 hosted zone'
    
    net = NetAddr::IPv4Net.parse(vpc_cidr)
    ComponentParam 'NetworkBits', net.network.to_s.split('.').shift(net.netmask.prefix_len/8).join('.'),
      description: 'override vpc cidr network bits'
    
    ComponentParam 'AvailabiltiyZones', max_availability_zones, 
      allowedValues: (1..max_availability_zones).to_a,
      description: 'Set the Availabiltiy Zone count for the stack'
      
    ComponentParam 'NatGateways', max_availability_zones, 
      allowedValues: (1..max_availability_zones).to_a,
      description: 'NAT Gateway count. If larger than AvailabiltiyZones value, the smaller is used.'
      
    ComponentParam 'NatGatewayEIPs', "", 
      type: 'CommaDelimitedList',
      description: 'List of EIP Ids, must be the same length as NatGateways'
    
    if enable_transit_vpc
      ComponentParam 'EnableTransitVPC', 'false', 
        description: 'Allows conditional creation of the the transit vpc resources'
    end
    
  end
  
  Component template: 'route53-zone@1.0.2', name: 'dnszone', render: Inline do
    parameter name: 'CreateZone', value: 'true'
    parameter name: 'RootDomainName', value: FnSub('${DnsDomain}.')
  end if manage_ns_records


end
