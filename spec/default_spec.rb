require 'yaml'
require 'spec_helper'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/vpc-v2.compiled.yaml") }

  context 'Resource VPC' do

    let(:properties) { template["Resources"]["VPC"]["Properties"] }

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.0.0/16"})
    end

    it 'has property EnableDnsSupport' do
      expect(properties["EnableDnsSupport"]).to eq(true)
    end

    it 'has property EnableDnsHostnames' do
      expect(properties["EnableDnsHostnames"]).to eq(true)
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource DHCPOptionSet' do

    let(:properties) { template["Resources"]["DHCPOptionSet"]["Properties"] }

    it 'has property DomainName' do
      expect(properties["DomainName"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}"})
    end

    it 'has property DomainNameServers' do
      expect(properties["DomainNameServers"]).to eq(["AmazonProvidedDNS"])
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource DHCPOptionsAssociation' do

    let(:properties) { template["Resources"]["DHCPOptionsAssociation"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property DhcpOptionsId' do
      expect(properties["DhcpOptionsId"]).to eq({"Ref"=>"DHCPOptionSet"})
    end

  end

  context 'Resource InternetGateway' do

    let(:properties) { template["Resources"]["InternetGateway"]["Properties"] }

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource AttachGateway' do

    let(:properties) { template["Resources"]["AttachGateway"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property InternetGatewayId' do
      expect(properties["InternetGatewayId"]).to eq({"Ref"=>"InternetGateway"})
    end

  end

  context 'Resource RouteTablePublic' do

    let(:properties) { template["Resources"]["RouteTablePublic"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-public"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NetworkAclPublic' do

    let(:properties) { template["Resources"]["NetworkAclPublic"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-public"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NetworkAclPrivate' do

    let(:properties) { template["Resources"]["NetworkAclPrivate"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-private"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource PublicRouteOutToInternet' do

    let(:properties) { template["Resources"]["PublicRouteOutToInternet"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property GatewayId' do
      expect(properties["GatewayId"]).to eq({"Ref"=>"InternetGateway"})
    end

  end

  context 'Resource NaclRuleInboundPublic100' do

    let(:properties) { template["Resources"]["NaclRuleInboundPublic100"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(100)
    end

    it 'has property Protocol' do
      expect(properties["Protocol"]).to eq("6")
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(false)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>80, "To"=>80})
    end

  end

  context 'Resource NaclRuleInboundPublic150' do

    let(:properties) { template["Resources"]["NaclRuleInboundPublic150"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(150)
    end

    it 'has property Protocol' do
      expect(properties["Protocol"]).to eq("6")
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(false)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>443, "To"=>443})
    end

  end

  context 'Resource NaclRuleInboundPublic200' do

    let(:properties) { template["Resources"]["NaclRuleInboundPublic200"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(200)
    end

    it 'has property Protocol' do
      expect(properties["Protocol"]).to eq("6")
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(false)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>1024, "To"=>65535})
    end

  end

  context 'Resource NaclRuleInboundPrivate100' do

    let(:properties) { template["Resources"]["NaclRuleInboundPrivate100"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(100)
    end

    it 'has property Protocol' do
      expect(properties["Protocol"]).to eq(-1)
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(false)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq("0.0.0.0/0")
    end

  end

  context 'Resource NaclRuleOutboundPrivate100' do

    let(:properties) { template["Resources"]["NaclRuleOutboundPrivate100"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(100)
    end

    it 'has property Protocol' do
      expect(properties["Protocol"]).to eq(-1)
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(true)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq("0.0.0.0/0")
    end

  end

  context 'Resource NaclRuleOutboundPublic100' do

    let(:properties) { template["Resources"]["NaclRuleOutboundPublic100"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(100)
    end

    it 'has property Protocol' do
      expect(properties["Protocol"]).to eq(-1)
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(true)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq("0.0.0.0/0")
    end

  end

  context 'Resource NatInstanceSecurityGroup' do

    let(:properties) { template["Resources"]["NatInstanceSecurityGroup"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property GroupDescription' do
      expect(properties["GroupDescription"]).to eq({"Fn::Sub"=>"${EnvironmentName} NAT Instances"})
    end

    it 'has property SecurityGroupIngress' do
      expect(properties["SecurityGroupIngress"]).to eq([
        {"CidrIp"=>{"Fn::GetAtt"=>["VPC", "CidrBlock"]}, 
        "Description"=>"inbound all for ports from vpc cidr", 
        "IpProtocol"=>-1}])
    end

    it 'has property SecurityGroupEgress' do
      expect(properties["SecurityGroupEgress"]).to eq([
        {"CidrIp"=>"0.0.0.0/0", 
          "Description"=>"outbound all for ports", 
          "IpProtocol"=>-1}])
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatInstanceRole' do

    let(:properties) { template["Resources"]["NatInstanceRole"]["Properties"] }

    it 'has property AssumeRolePolicyDocument' do
      expect(properties["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"ec2.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
    end

    it 'has property Path' do
      expect(properties["Path"]).to eq("/")
    end

    it 'has property Policies' do
      expect(properties["Policies"]).to eq([{"PolicyName"=>"eni-attach", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"eniattach", "Action"=>"ec2:AttachNetworkInterface", "Resource"=>["*"], "Effect"=>"Allow"}]}}])
    end

  end

  context 'Resource NatInstanceProfile' do

    let(:properties) { template["Resources"]["NatInstanceProfile"]["Properties"] }

    it 'has property Path' do
      expect(properties["Path"]).to eq("/")
    end

    it 'has property Roles' do
      expect(properties["Roles"]).to eq([{"Ref"=>"NatInstanceRole"}])
    end

  end

  context 'Resource RouteTablePrivate0' do

    let(:properties) { template["Resources"]["RouteTablePrivate0"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-private-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatIPAddress0' do

    let(:properties) { template["Resources"]["NatIPAddress0"]["Properties"] }

    it 'has property Domain' do
      expect(properties["Domain"]).to eq("vpc")
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatGateway0' do

    let(:properties) { template["Resources"]["NatGateway0"]["Properties"] }

    it 'has property AllocationId' do
      expect(properties["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress0", "AllocationId"]}, {"Fn::Select"=>[0, {"Ref"=>"NatGatewayEIPs"}]}]})
    end

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-natgw-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteOutToInternet0' do

    let(:properties) { template["Resources"]["RouteOutToInternet0"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property NatGatewayId' do
      expect(properties["NatGatewayId"]).to eq({"Fn::If"=>["CreateManagedNat0", {"Ref"=>"NatGateway0"}, {"Ref"=>"NatGateway0"}]})
    end

  end

  context 'Resource NetworkInterface0' do

    let(:properties) { template["Resources"]["NetworkInterface0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
    end

    it 'has property SourceDestCheck' do
      expect(properties["SourceDestCheck"]).to eq(false)
    end

    it 'has property GroupSet' do
      expect(properties["GroupSet"]).to eq([{"Ref"=>"NatInstanceSecurityGroup"}])
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
    end

  end

  context 'Resource EIPAssociation0' do

    let(:properties) { template["Resources"]["EIPAssociation0"]["Properties"] }

    it 'has property AllocationId' do
      expect(properties["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress0", "AllocationId"]}, {"Fn::Select"=>[0, {"Ref"=>"NatGatewayEIPs"}]}]})
    end

    it 'has property NetworkInterfaceId' do
      expect(properties["NetworkInterfaceId"]).to eq({"Ref"=>"NetworkInterface0"})
    end

  end

  context 'Resource LaunchTemplate0' do

    let(:properties) { template["Resources"]["LaunchTemplate0"]["Properties"] }

    it 'has property LaunchTemplateData' do
      expect(properties["LaunchTemplateData"]).to be_kind_of(Hash)
    end

  end

  context 'Resource AutoScaleGroup0' do

    let(:properties) { template["Resources"]["AutoScaleGroup0"]["Properties"] }

    it 'has property DesiredCapacity' do
      expect(properties["DesiredCapacity"]).to eq("1")
    end

    it 'has property MinSize' do
      expect(properties["MinSize"]).to eq("1")
    end

    it 'has property MaxSize' do
      expect(properties["MaxSize"]).to eq("1")
    end

    it 'has property VPCZoneIdentifier' do
      expect(properties["VPCZoneIdentifier"]).to eq([{"Ref"=>"SubnetPublic0"}])
    end

    it 'has property LaunchTemplate' do
      expect(properties["LaunchTemplate"]).to eq({"LaunchTemplateId"=>{"Ref"=>"LaunchTemplate0"}, "Version"=>{"Fn::GetAtt"=>["LaunchTemplate0", "LatestVersionNumber"]}})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}, "PropagateAtLaunch"=>false}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}, "PropagateAtLaunch"=>false}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}, "PropagateAtLaunch"=>false}])
    end

  end

  context 'Resource RouteOutToInternet0ViaNatInstance' do

    let(:properties) { template["Resources"]["RouteOutToInternet0ViaNatInstance"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property NetworkInterfaceId' do
      expect(properties["NetworkInterfaceId"]).to eq({"Fn::If"=>["CreateNatInstance0", {"Ref"=>"NetworkInterface0"}, {"Ref"=>"NetworkInterface0"}]})
    end

  end

  context 'Resource RouteTablePrivate1' do

    let(:properties) { template["Resources"]["RouteTablePrivate1"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-private-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatIPAddress1' do

    let(:properties) { template["Resources"]["NatIPAddress1"]["Properties"] }

    it 'has property Domain' do
      expect(properties["Domain"]).to eq("vpc")
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatGateway1' do

    let(:properties) { template["Resources"]["NatGateway1"]["Properties"] }

    it 'has property AllocationId' do
      expect(properties["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress1", "AllocationId"]}, {"Fn::Select"=>[1, {"Ref"=>"NatGatewayEIPs"}]}]})
    end

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-natgw-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteOutToInternet1' do

    let(:properties) { template["Resources"]["RouteOutToInternet1"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property NatGatewayId' do
      expect(properties["NatGatewayId"]).to eq({"Fn::If"=>["CreateManagedNat1", {"Ref"=>"NatGateway1"}, {"Ref"=>"NatGateway0"}]})
    end

  end

  context 'Resource NetworkInterface1' do

    let(:properties) { template["Resources"]["NetworkInterface1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
    end

    it 'has property SourceDestCheck' do
      expect(properties["SourceDestCheck"]).to eq(false)
    end

    it 'has property GroupSet' do
      expect(properties["GroupSet"]).to eq([{"Ref"=>"NatInstanceSecurityGroup"}])
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
    end

  end

  context 'Resource EIPAssociation1' do

    let(:properties) { template["Resources"]["EIPAssociation1"]["Properties"] }

    it 'has property AllocationId' do
      expect(properties["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress1", "AllocationId"]}, {"Fn::Select"=>[1, {"Ref"=>"NatGatewayEIPs"}]}]})
    end

    it 'has property NetworkInterfaceId' do
      expect(properties["NetworkInterfaceId"]).to eq({"Ref"=>"NetworkInterface1"})
    end

  end

  context 'Resource LaunchTemplate1' do

    let(:properties) { template["Resources"]["LaunchTemplate1"]["Properties"] }

    it 'has property LaunchTemplateData' do
      expect(properties["LaunchTemplateData"]).to be_kind_of(Hash)
    end

  end

  context 'Resource AutoScaleGroup1' do

    let(:properties) { template["Resources"]["AutoScaleGroup1"]["Properties"] }

    it 'has property DesiredCapacity' do
      expect(properties["DesiredCapacity"]).to eq("1")
    end

    it 'has property MinSize' do
      expect(properties["MinSize"]).to eq("1")
    end

    it 'has property MaxSize' do
      expect(properties["MaxSize"]).to eq("1")
    end

    it 'has property VPCZoneIdentifier' do
      expect(properties["VPCZoneIdentifier"]).to eq([{"Ref"=>"SubnetPublic1"}])
    end

    it 'has property LaunchTemplate' do
      expect(properties["LaunchTemplate"]).to eq({"LaunchTemplateId"=>{"Ref"=>"LaunchTemplate1"}, "Version"=>{"Fn::GetAtt"=>["LaunchTemplate1", "LatestVersionNumber"]}})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}, "PropagateAtLaunch"=>false}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}, "PropagateAtLaunch"=>false}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}, "PropagateAtLaunch"=>false}])
    end

  end

  context 'Resource RouteOutToInternet1ViaNatInstance' do

    let(:properties) { template["Resources"]["RouteOutToInternet1ViaNatInstance"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property NetworkInterfaceId' do
      expect(properties["NetworkInterfaceId"]).to eq({"Fn::If"=>["CreateNatInstance1", {"Ref"=>"NetworkInterface1"}, {"Ref"=>"NetworkInterface0"}]})
    end

  end

  context 'Resource RouteTablePrivate2' do

    let(:properties) { template["Resources"]["RouteTablePrivate2"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-private-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatIPAddress2' do

    let(:properties) { template["Resources"]["NatIPAddress2"]["Properties"] }

    it 'has property Domain' do
      expect(properties["Domain"]).to eq("vpc")
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource NatGateway2' do

    let(:properties) { template["Resources"]["NatGateway2"]["Properties"] }

    it 'has property AllocationId' do
      expect(properties["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress2", "AllocationId"]}, {"Fn::Select"=>[2, {"Ref"=>"NatGatewayEIPs"}]}]})
    end

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-natgw-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteOutToInternet2' do

    let(:properties) { template["Resources"]["RouteOutToInternet2"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property NatGatewayId' do
      expect(properties["NatGatewayId"]).to eq({"Fn::If"=>["CreateManagedNat2", {"Ref"=>"NatGateway2"}, {"Ref"=>"NatGateway0"}]})
    end

  end

  context 'Resource NetworkInterface2' do

    let(:properties) { template["Resources"]["NetworkInterface2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
    end

    it 'has property SourceDestCheck' do
      expect(properties["SourceDestCheck"]).to eq(false)
    end

    it 'has property GroupSet' do
      expect(properties["GroupSet"]).to eq([{"Ref"=>"NatInstanceSecurityGroup"}])
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
    end

  end

  context 'Resource EIPAssociation2' do

    let(:properties) { template["Resources"]["EIPAssociation2"]["Properties"] }

    it 'has property AllocationId' do
      expect(properties["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress2", "AllocationId"]}, {"Fn::Select"=>[2, {"Ref"=>"NatGatewayEIPs"}]}]})
    end

    it 'has property NetworkInterfaceId' do
      expect(properties["NetworkInterfaceId"]).to eq({"Ref"=>"NetworkInterface2"})
    end

  end

  context 'Resource LaunchTemplate2' do

    let(:properties) { template["Resources"]["LaunchTemplate2"]["Properties"] }

    it 'has property LaunchTemplateData' do
      expect(properties["LaunchTemplateData"]).to be_kind_of(Hash)
    end

  end

  context 'Resource AutoScaleGroup2' do

    let(:properties) { template["Resources"]["AutoScaleGroup2"]["Properties"] }

    it 'has property DesiredCapacity' do
      expect(properties["DesiredCapacity"]).to eq("1")
    end

    it 'has property MinSize' do
      expect(properties["MinSize"]).to eq("1")
    end

    it 'has property MaxSize' do
      expect(properties["MaxSize"]).to eq("1")
    end

    it 'has property VPCZoneIdentifier' do
      expect(properties["VPCZoneIdentifier"]).to eq([{"Ref"=>"SubnetPublic2"}])
    end

    it 'has property LaunchTemplate' do
      expect(properties["LaunchTemplate"]).to eq({"LaunchTemplateId"=>{"Ref"=>"LaunchTemplate2"}, "Version"=>{"Fn::GetAtt"=>["LaunchTemplate2", "LatestVersionNumber"]}})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}, "PropagateAtLaunch"=>false}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}, "PropagateAtLaunch"=>false}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}, "PropagateAtLaunch"=>false}])
    end

  end

  context 'Resource RouteOutToInternet2ViaNatInstance' do

    let(:properties) { template["Resources"]["RouteOutToInternet2ViaNatInstance"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("0.0.0.0/0")
    end

    it 'has property NetworkInterfaceId' do
      expect(properties["NetworkInterfaceId"]).to eq({"Fn::If"=>["CreateNatInstance2", {"Ref"=>"NetworkInterface2"}, {"Ref"=>"NetworkInterface0"}]})
    end

  end

  context 'Resource SubnetPublic0' do

    let(:properties) { template["Resources"]["SubnetPublic0"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.0.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Type", "Value"=>"public"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetPublic0' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetPublic0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
    end

  end

  context 'Resource ACLAssociationSubnetPublic0' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetPublic0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

  end

  context 'Resource SubnetPublic1' do

    let(:properties) { template["Resources"]["SubnetPublic1"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.1.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Type", "Value"=>"public"}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetPublic1' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetPublic1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
    end

  end

  context 'Resource ACLAssociationSubnetPublic1' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetPublic1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

  end

  context 'Resource SubnetPublic2' do

    let(:properties) { template["Resources"]["SubnetPublic2"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.2.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}},
        {"Key"=>"Type", "Value"=>"public"}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetPublic2' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetPublic2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
    end

  end

  context 'Resource ACLAssociationSubnetPublic2' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetPublic2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

  end

  context 'Resource SubnetCompute0' do

    let(:properties) { template["Resources"]["SubnetCompute0"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.4.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-compute-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, 
        {"Key"=>"Type", "Value"=>"private"}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetCompute0' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetCompute0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCompute0"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
    end

  end

  context 'Resource ACLAssociationSubnetCompute0' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetCompute0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCompute0"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetCompute1' do

    let(:properties) { template["Resources"]["SubnetCompute1"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.5.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-compute-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetCompute1' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetCompute1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCompute1"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
    end

  end

  context 'Resource ACLAssociationSubnetCompute1' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetCompute1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCompute1"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetCompute2' do

    let(:properties) { template["Resources"]["SubnetCompute2"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.6.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-compute-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetCompute2' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetCompute2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCompute2"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
    end

  end

  context 'Resource ACLAssociationSubnetCompute2' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetCompute2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCompute2"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetPersistence0' do

    let(:properties) { template["Resources"]["SubnetPersistence0"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.8.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-persistence-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetPersistence0' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetPersistence0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPersistence0"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
    end

  end

  context 'Resource ACLAssociationSubnetPersistence0' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetPersistence0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPersistence0"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetPersistence1' do

    let(:properties) { template["Resources"]["SubnetPersistence1"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.9.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-persistence-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetPersistence1' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetPersistence1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPersistence1"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
    end

  end

  context 'Resource ACLAssociationSubnetPersistence1' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetPersistence1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPersistence1"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetPersistence2' do

    let(:properties) { template["Resources"]["SubnetPersistence2"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.10.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-persistence-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetPersistence2' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetPersistence2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPersistence2"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
    end

  end

  context 'Resource ACLAssociationSubnetPersistence2' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetPersistence2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetPersistence2"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetCache0' do

    let(:properties) { template["Resources"]["SubnetCache0"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.12.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-cache-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetCache0' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetCache0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCache0"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
    end

  end

  context 'Resource ACLAssociationSubnetCache0' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetCache0"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCache0"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetCache1' do

    let(:properties) { template["Resources"]["SubnetCache1"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.13.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-cache-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetCache1' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetCache1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCache1"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
    end

  end

  context 'Resource ACLAssociationSubnetCache1' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetCache1"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCache1"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource SubnetCache2' do

    let(:properties) { template["Resources"]["SubnetCache2"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Sub"=>"${NetworkBits}.14.0/24"})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-cache-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource RouteTableAssociationSubnetCache2' do

    let(:properties) { template["Resources"]["RouteTableAssociationSubnetCache2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCache2"})
    end

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
    end

  end

  context 'Resource ACLAssociationSubnetCache2' do

    let(:properties) { template["Resources"]["ACLAssociationSubnetCache2"]["Properties"] }

    it 'has property SubnetId' do
      expect(properties["SubnetId"]).to eq({"Ref"=>"SubnetCache2"})
    end

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

  end

  context 'Resource S3VpcEndpoint' do

    let(:properties) { template["Resources"]["S3VpcEndpoint"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property PolicyDocument' do
      expect(properties["PolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>"*", "Action"=>["s3:*"], "Resource"=>["arn:aws:s3:::*"]}]})
    end

    it 'has property ServiceName' do
      expect(properties["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.s3"})
    end

    it 'has property RouteTableIds' do
      expect(properties["RouteTableIds"]).to eq([{"Ref"=>"RouteTablePrivate0"}, {"Ref"=>"RouteTablePrivate1"}, {"Ref"=>"RouteTablePrivate2"}])
    end

  end

  context 'Resource VGW' do

    let(:properties) { template["Resources"]["VGW"]["Properties"] }

    it 'has property Type' do
      expect(properties["Type"]).to eq("ipsec.1")
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-VGW"}}, {"Key"=>"transitvpc:spoke", "Value"=>{"Ref"=>"EnableTransitVPC"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource AttachVGWToVPC' do

    let(:properties) { template["Resources"]["AttachVGWToVPC"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property VpnGatewayId' do
      expect(properties["VpnGatewayId"]).to eq({"Ref"=>"VGW"})
    end

  end

  context 'Resource PropagateRoute' do

    let(:properties) { template["Resources"]["PropagateRoute"]["Properties"] }

    it 'has property RouteTableIds' do
      expect(properties["RouteTableIds"]).to eq([{"Ref"=>"RouteTablePrivate0"}, {"Ref"=>"RouteTablePrivate1"}, {"Ref"=>"RouteTablePrivate2"}])
    end

    it 'has property VpnGatewayId' do
      expect(properties["VpnGatewayId"]).to eq({"Ref"=>"VGW"})
    end

  end

  context 'Resource HostedZone' do

    let(:properties) { template["Resources"]["HostedZone"]["Properties"] }

    it 'has property Name' do
      expect(properties["Name"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}"})
    end

    it 'has property HostedZoneConfig' do
      expect(properties["HostedZoneConfig"]).to eq({"Comment"=>{"Fn::Sub"=>"Hosted Zone for ${EnvironmentName}"}})
    end

    it 'has property HostedZoneTags' do
      expect(properties["HostedZoneTags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end
  
  context 'Parameters' do
    
    let(:parameters) { template["Parameters"].keys }
    
    it 'has parameter EnvironmentName' do
      expect(parameters).to include('EnvironmentName')
    end
    
    it 'has parameter EnvironmentType' do
      expect(parameters).to include('EnvironmentType')
    end
    
    it 'has parameter DnsDomain' do
      expect(parameters).to include('DnsDomain')
    end
    
    it 'has parameter NetworkBits' do
      expect(parameters).to include('NetworkBits')
    end
    
    it 'NetworkBits has default value of' do
      expect(template["Parameters"]["NetworkBits"]["Default"]).to eq('10.0')
    end
    
    it 'has parameter AvailabiltiyZones' do
      expect(parameters).to include('AvailabiltiyZones')
    end
    
    it 'AvailabiltiyZones has allowed values of' do
      expect(template["Parameters"]["AvailabiltiyZones"]["AllowedValues"]).to match_array([1,2,3])
    end

    it 'has parameter NatGateways' do
      expect(parameters).to include('NatGateways')
    end
    
    it 'NatGateways has allowed values of' do
      expect(template["Parameters"]["NatGateways"]["AllowedValues"]).to match_array([1,2,3])
    end
    
    it 'has parameter NatGatewayEIPs' do
      expect(parameters).to include('NatGatewayEIPs')
    end
    
    it 'NatGatewayEIPs has type of' do
      expect(template["Parameters"]["NatGatewayEIPs"]["Type"]).to eq('CommaDelimitedList')
    end
    
    it 'has parameter EnableTransitVPC' do
      expect(parameters).to include('EnableTransitVPC')
    end
    
    it 'has parameter NatType' do
      expect(parameters).to include('NatType')
    end
    
    it 'NatType has allowed values of' do
      expect(template["Parameters"]["NatType"]["AllowedValues"]).to match_array(['managed','instances','disabled'])
    end
    
    it 'has parameter NatAmi' do
      expect(parameters).to include('NatAmi')
    end
    
    it 'NatAmi has type of' do
      expect(template["Parameters"]["NatAmi"]["Type"]).to eq('AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>')
    end
    
    it 'NatAmi has default value of' do
      expect(template["Parameters"]["NatAmi"]["Default"]).to eq('/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-ebs')
    end
    
    it 'has parameter NatInstanceType' do
      expect(parameters).to include('NatInstanceType')
    end
    
    it 'has parameter NatInstancesSpot' do
      expect(parameters).to include('NatInstancesSpot')
    end
    
    it 'NatInstancesSpot has allowed values of' do
      expect(template["Parameters"]["NatInstancesSpot"]["AllowedValues"]).to match_array(['true','false'])
    end
    
  end
  
  context 'Condition' do
    
    let(:conditions) { template["Conditions"] }
    
    it 'CreateNatGatewayEIP checks if NatGatewayEIPs is a empty string' do
      expect(conditions['CreateNatGatewayEIP']).to eq({"Fn::Equals" => [{"Fn::Join" => ["", {"Ref" => "NatGatewayEIPs"}]}, ""]})
    end

  end

end
