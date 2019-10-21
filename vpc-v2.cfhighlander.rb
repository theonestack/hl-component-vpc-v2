require 'netaddr'

CfhighlanderTemplate do
  Name 'vpc-v2'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
    
    ComponentParam 'DnsDomain', isGlobal: true
    
    net = NetAddr::IPv4Net.parse(vpc_cidr)
    ComponentParam 'NetworkPrefix', net.network.to_s.split('.').shift(net.netmask.prefix_len/8).join('.')
    
    ComponentParam 'NatGateways', max_availability_zones, allowedValues: (1..max_availability_zones).to_a
    ComponentParam 'NatGatewayEIPs', '', type: 'CommaDelimitedList'
    
    if enable_transit_vpc
      ComponentParam 'EnableTransitVPC', 'false', isGlobal: true
    end
    
  end
  
  Component template: 'route53-zone@1.0.2', name: 'dnszone', render: Inline do
    parameter name: 'CreateZone', value: 'true'
    parameter name: 'RootDomainName', value: FnSub('${DnsDomain}.')
  end if manage_ns_records


end
