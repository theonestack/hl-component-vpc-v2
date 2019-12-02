# vpc-v2 CfHighlander component

Base component in which to build AWS network based resources from such as EC2, RDS and ECS

```bash
kurgan add vpc-v2
```

## Requirements

## Parameters

| Name | Use | Default | Global | Type | Allowed Values |
| ---- | --- | ------- | ------ | ---- | -------------- |
| EnvironmentName | Tagging | dev | true | string
| EnvironmentType | Tagging | development | true | string | ['development','production']
| DnsDomain | create route53 zone | | true | string
| NetworkBits | override vpc cidr network bits | `vpc_cidr:` | false | string
| AvailabiltiyZones | set the az count for the stack | `max_availability_zones:` | false | string
| NatType | Select the NAT type | `managed` | false | string | [`managed`,`instances`,`disabled`]
| NatGateways | NAT Gateway count. If larger than AvailabiltiyZones value, the smaller is used | `max_availability_zones:` | false | string
| NatGatewayEIPs | List of EIP Ids, must be the same length as NatGateways' | | false | CommaDelimitedList
| NatInstanceType | Ec2 instance type | `t3.micro` | false | string
| NatAmi | Amazon Machine Image Id as a string or ssm parameter | `/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-ebs` | false | SSM Parameter
| NatInstancesSpot | Enable spot for the EC2 Nat Instances | `true` | false | String | ['true','false']
| EnableTransitVPC | Allows conditional creation of the the transit vpc resources | 

## Configuration

### Subnetting

Default subnet groups that will be created in the VPC stack.
```yaml
subnets:
  public:
    name: Public
    type: public
  compute:
    name: Compute
    type: private
  persistence:
    name: Persistence
    type: private
  cache:
    name: Cache
    type: private
```

Determines how many subnets will allocated per subnet group.
**Update** would require replacement of the whole VPC stack.
```yaml
subnet_multiplyer: 5
```

Determines the maximum amount of availability zones this stack can create.
Cannot be a larger number than `subnet_multiplyer`.
**Update** to a larger value would have no effect if the `AvailabiltiyZones` parameter stays the same.
**Update** to a smaller value may remove az's if the value is smaller than the `AvailabiltiyZones` parameter.
```yaml
max_availability_zones: 3
```

Determines the subnet size of the subnets
```yaml
subnet_mask: 24
```

The VPC CIDR for this component only supports classful networks [`/8`, `/16`,` /24`]
The value is used to generate the subnet bits for each subnet, and then the network bits can be overridden as a parameter.
```yaml
vpc_cidr: 10.0.0.0/16
```

For example, the vpc cidr `10.0.0.0/16` used to generate 3 `/24` subnets.
The `NetworkBits` parameter default value is `10.0` with the 3 subnets cidr value set to 
    ```ruby
    FnSub("${NetworkBits}.0.0/24")
    FnSub("${NetworkBits}.1.0/24")
    FnSub("${NetworkBits}.2.0/24")
    ```

### NetworkACLs

2 NACLs are created, one for public subnets and the other for private subnets.
The rules on these acls can be modified using the `acl_rules` config.

the default public rules are tcp ports 80, 443 and 1024-65535 from 0.0.0.0/0
the default private rules are allow everything

```yaml
acl_rules:
  -
    # public or private nacl
    acl: public
    # the rule number. if multiple ips are used this value is incremented by 1 for each ip
    number: 100
    # the port range. if to: is not set from is is used
    from: 1024
    to: 65535
    # protocol, defaults to tcp
    protocol: tcp
    # specify a specific ip
    cidr: 0.0.0.0/0
    # specify a range of ips or ip_block or the vpc cidr using the term `stack`
    ips:
      - vpn
      - stack
      
ip_blocks:
  vpn:
    1.1.1.1/32
```

### VPC Gateway Endpoints

A S3 VPC Gateway Endpoint is always created and added to all route tables. 

### VPC Interface Endpoints

List of aws service interface endpoints to enable access over the private network.
See [here](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html) for more info on available endpoints.
**Note:** each vpce is [priced](https://aws.amazon.com/privatelink/pricing/) per interface per az plus data throughput.

```yaml
endpoints:
  - ec2
  - ec2.api
```


Override the default vpce interface subnets

```yaml
endpoint_subnets: Compute
```

### DNS

defines the dns format for the project using a `Fn::Fub:`.
There a 2 common patterns

1. use the same root domain across all environments and have the stack create a sub domain 
```yaml
dns_format: ${EnvironmentName}.${DnsDomain}
```

2. have a different root zone for each environment
```yaml
dns_format: ${DnsDomain}
```

### NAT

NATs can be toggled between NAT Instances (EC2) and AWS managed NAT Gateways.
Check out this [table](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-comparison.html) for comparison

Select the amount of nat's to deploy for the environment, max is 1 per az and min is 1. If less than the max az count is selected, the default route is directed out through Nat in AZ 0

**Managed**

- AWS managed NAT Gateway
- Attaches EIP
- Can be more expensive
- Can't be shut down
- Easier to manage
- Guaranteed high network throughput
- Recommended for production type environments
    
**Instances**

- EC2 instance in an ASG per availabiltiy zone
- Attaches a secondary ENI with a EIP
- Creates an extra attack surface
- Network through put limited by the instance type
- Can be cheaper using small instance sizes and utilising the spot market
- Can be shutdown saving on cost
- Recommended for development type environments

**Disabled**

- No resources associated with NAT Gateways are created
- Recommended for when no public access is required
- If you want to move between Managed NAT and Instances you must update to `disabled` first. This is due to EIP's already being attached to the current NAT ENI or Gateway.

**AMI Requirements**
- linux
- [awscli](https://github.com/aws/aws-cli)
- iptables
- route

## Outputs/Exports

| Name | Value | Exported |
| ---- | ----- | -------- |
| VPCId | VPCId | true
| VPCCidr | VPCCidr | true
| HostedZone | Hosted Zone Id | true
| GroupSubnets | CommaDelimitedList of each subnet group | true

## Included Components

[route53-zone](https://github.com/theonestack/hl-component-route53-zone)

If your using environment sub domains and you want to automatically delegate the domain to the root, specify 

```yaml
manage_ns_records: true
```