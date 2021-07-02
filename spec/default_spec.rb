require 'yaml'

describe 'compiled component vpc-v2' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/vpc-v2.compiled.yaml") }
  
  context "Resource" do

    
    context "VPC" do
      let(:resource) { template["Resources"]["VPC"] }

      it "is of type AWS::EC2::VPC" do
          expect(resource["Type"]).to eq("AWS::EC2::VPC")
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Ref"=>"CIDR"})
      end
      
      it "to have property EnableDnsSupport" do
          expect(resource["Properties"]["EnableDnsSupport"]).to eq(true)
      end
      
      it "to have property EnableDnsHostnames" do
          expect(resource["Properties"]["EnableDnsHostnames"]).to eq(true)
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "DHCPOptionSet" do
      let(:resource) { template["Resources"]["DHCPOptionSet"] }

      it "is of type AWS::EC2::DHCPOptions" do
          expect(resource["Type"]).to eq("AWS::EC2::DHCPOptions")
      end
      
      it "to have property DomainName" do
          expect(resource["Properties"]["DomainName"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}"})
      end
      
      it "to have property DomainNameServers" do
          expect(resource["Properties"]["DomainNameServers"]).to eq(["AmazonProvidedDNS"])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "DHCPOptionsAssociation" do
      let(:resource) { template["Resources"]["DHCPOptionsAssociation"] }

      it "is of type AWS::EC2::VPCDHCPOptionsAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::VPCDHCPOptionsAssociation")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property DhcpOptionsId" do
          expect(resource["Properties"]["DhcpOptionsId"]).to eq({"Ref"=>"DHCPOptionSet"})
      end
      
    end
    
    context "InternetGateway" do
      let(:resource) { template["Resources"]["InternetGateway"] }

      it "is of type AWS::EC2::InternetGateway" do
          expect(resource["Type"]).to eq("AWS::EC2::InternetGateway")
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "AttachGateway" do
      let(:resource) { template["Resources"]["AttachGateway"] }

      it "is of type AWS::EC2::VPCGatewayAttachment" do
          expect(resource["Type"]).to eq("AWS::EC2::VPCGatewayAttachment")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property InternetGatewayId" do
          expect(resource["Properties"]["InternetGatewayId"]).to eq({"Ref"=>"InternetGateway"})
      end
      
    end
    
    context "RouteTablePublic" do
      let(:resource) { template["Resources"]["RouteTablePublic"] }

      it "is of type AWS::EC2::RouteTable" do
          expect(resource["Type"]).to eq("AWS::EC2::RouteTable")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-public"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NetworkAclPublic" do
      let(:resource) { template["Resources"]["NetworkAclPublic"] }

      it "is of type AWS::EC2::NetworkAcl" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAcl")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-public"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NetworkAclPrivate" do
      let(:resource) { template["Resources"]["NetworkAclPrivate"] }

      it "is of type AWS::EC2::NetworkAcl" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAcl")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-private"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "PublicRouteOutToInternet" do
      let(:resource) { template["Resources"]["PublicRouteOutToInternet"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property GatewayId" do
          expect(resource["Properties"]["GatewayId"]).to eq({"Ref"=>"InternetGateway"})
      end
      
    end
    
    context "NaclRuleInboundPublic100" do
      let(:resource) { template["Resources"]["NaclRuleInboundPublic100"] }

      it "is of type AWS::EC2::NetworkAclEntry" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAclEntry")
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
      it "to have property RuleNumber" do
          expect(resource["Properties"]["RuleNumber"]).to eq(100)
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq("6")
      end
      
      it "to have property RuleAction" do
          expect(resource["Properties"]["RuleAction"]).to eq("allow")
      end
      
      it "to have property Egress" do
          expect(resource["Properties"]["Egress"]).to eq(false)
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property PortRange" do
          expect(resource["Properties"]["PortRange"]).to eq({"From"=>80, "To"=>80})
      end
      
    end
    
    context "NaclRuleInboundPublic150" do
      let(:resource) { template["Resources"]["NaclRuleInboundPublic150"] }

      it "is of type AWS::EC2::NetworkAclEntry" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAclEntry")
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
      it "to have property RuleNumber" do
          expect(resource["Properties"]["RuleNumber"]).to eq(150)
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq("6")
      end
      
      it "to have property RuleAction" do
          expect(resource["Properties"]["RuleAction"]).to eq("allow")
      end
      
      it "to have property Egress" do
          expect(resource["Properties"]["Egress"]).to eq(false)
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property PortRange" do
          expect(resource["Properties"]["PortRange"]).to eq({"From"=>443, "To"=>443})
      end
      
    end
    
    context "NaclRuleInboundPublic200" do
      let(:resource) { template["Resources"]["NaclRuleInboundPublic200"] }

      it "is of type AWS::EC2::NetworkAclEntry" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAclEntry")
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
      it "to have property RuleNumber" do
          expect(resource["Properties"]["RuleNumber"]).to eq(200)
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq("6")
      end
      
      it "to have property RuleAction" do
          expect(resource["Properties"]["RuleAction"]).to eq("allow")
      end
      
      it "to have property Egress" do
          expect(resource["Properties"]["Egress"]).to eq(false)
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property PortRange" do
          expect(resource["Properties"]["PortRange"]).to eq({"From"=>1024, "To"=>65535})
      end
      
    end
    
    context "NaclRuleInboundPrivate100" do
      let(:resource) { template["Resources"]["NaclRuleInboundPrivate100"] }

      it "is of type AWS::EC2::NetworkAclEntry" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAclEntry")
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
      it "to have property RuleNumber" do
          expect(resource["Properties"]["RuleNumber"]).to eq(100)
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq(-1)
      end
      
      it "to have property RuleAction" do
          expect(resource["Properties"]["RuleAction"]).to eq("allow")
      end
      
      it "to have property Egress" do
          expect(resource["Properties"]["Egress"]).to eq(false)
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq("0.0.0.0/0")
      end
      
    end
    
    context "NaclRuleOutboundPrivate100" do
      let(:resource) { template["Resources"]["NaclRuleOutboundPrivate100"] }

      it "is of type AWS::EC2::NetworkAclEntry" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAclEntry")
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
      it "to have property RuleNumber" do
          expect(resource["Properties"]["RuleNumber"]).to eq(100)
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq(-1)
      end
      
      it "to have property RuleAction" do
          expect(resource["Properties"]["RuleAction"]).to eq("allow")
      end
      
      it "to have property Egress" do
          expect(resource["Properties"]["Egress"]).to eq(true)
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq("0.0.0.0/0")
      end
      
    end
    
    context "NaclRuleOutboundPublic100" do
      let(:resource) { template["Resources"]["NaclRuleOutboundPublic100"] }

      it "is of type AWS::EC2::NetworkAclEntry" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkAclEntry")
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
      it "to have property RuleNumber" do
          expect(resource["Properties"]["RuleNumber"]).to eq(100)
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq(-1)
      end
      
      it "to have property RuleAction" do
          expect(resource["Properties"]["RuleAction"]).to eq("allow")
      end
      
      it "to have property Egress" do
          expect(resource["Properties"]["Egress"]).to eq(true)
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq("0.0.0.0/0")
      end
      
    end
    
    context "NatInstanceSecurityGroup" do
      let(:resource) { template["Resources"]["NatInstanceSecurityGroup"] }

      it "is of type AWS::EC2::SecurityGroup" do
          expect(resource["Type"]).to eq("AWS::EC2::SecurityGroup")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property GroupDescription" do
          expect(resource["Properties"]["GroupDescription"]).to eq({"Fn::Sub"=>"${EnvironmentName} NAT Instances"})
      end
      
      it "to have property SecurityGroupIngress" do
          expect(resource["Properties"]["SecurityGroupIngress"]).to eq([{"CidrIp"=>{"Fn::GetAtt"=>["VPC", "CidrBlock"]}, "Description"=>"inbound all for ports from vpc cidr", "IpProtocol"=>-1}])
      end
      
      it "to have property SecurityGroupEgress" do
          expect(resource["Properties"]["SecurityGroupEgress"]).to eq([{"CidrIp"=>"0.0.0.0/0", "Description"=>"outbound all for ports", "IpProtocol"=>-1}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-vpc"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatInstanceRole" do
      let(:resource) { template["Resources"]["NatInstanceRole"] }

      it "is of type AWS::IAM::Role" do
          expect(resource["Type"]).to eq("AWS::IAM::Role")
      end
      
      it "to have property AssumeRolePolicyDocument" do
          expect(resource["Properties"]["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"ec2.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Policies" do
          expect(resource["Properties"]["Policies"]).to eq([{"PolicyName"=>"eni-attach", "PolicyDocument"=>{"Statement"=>[{"Sid"=>"eniattach", "Action"=>"ec2:AttachNetworkInterface", "Resource"=>["*"], "Effect"=>"Allow"}]}}])
      end
      
      it "to have property ManagedPolicyArns" do
          expect(resource["Properties"]["ManagedPolicyArns"]).to eq(["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"])
      end
      
    end
    
    context "NatInstanceProfile" do
      let(:resource) { template["Resources"]["NatInstanceProfile"] }

      it "is of type AWS::IAM::InstanceProfile" do
          expect(resource["Type"]).to eq("AWS::IAM::InstanceProfile")
      end
      
      it "to have property Path" do
          expect(resource["Properties"]["Path"]).to eq("/")
      end
      
      it "to have property Roles" do
          expect(resource["Properties"]["Roles"]).to eq([{"Ref"=>"NatInstanceRole"}])
      end
      
    end
    
    context "RouteTablePrivate0" do
      let(:resource) { template["Resources"]["RouteTablePrivate0"] }

      it "is of type AWS::EC2::RouteTable" do
          expect(resource["Type"]).to eq("AWS::EC2::RouteTable")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-private-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatIPAddress0" do
      let(:resource) { template["Resources"]["NatIPAddress0"] }

      it "is of type AWS::EC2::EIP" do
          expect(resource["Type"]).to eq("AWS::EC2::EIP")
      end
      
      it "to have property Domain" do
          expect(resource["Properties"]["Domain"]).to eq("vpc")
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatGateway0" do
      let(:resource) { template["Resources"]["NatGateway0"] }

      it "is of type AWS::EC2::NatGateway" do
          expect(resource["Type"]).to eq("AWS::EC2::NatGateway")
      end
      
      it "to have property AllocationId" do
          expect(resource["Properties"]["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress0", "AllocationId"]}, {"Fn::Select"=>[0, {"Ref"=>"NatGatewayEIPs"}]}]})
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-natgw-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "RouteOutToInternet0" do
      let(:resource) { template["Resources"]["RouteOutToInternet0"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property NatGatewayId" do
          expect(resource["Properties"]["NatGatewayId"]).to eq({"Fn::If"=>["CreateManagedNat0", {"Ref"=>"NatGateway0"}, {"Ref"=>"NatGateway0"}]})
      end
      
    end
    
    context "NetworkInterface0" do
      let(:resource) { template["Resources"]["NetworkInterface0"] }

      it "is of type AWS::EC2::NetworkInterface" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkInterface")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
      end
      
      it "to have property SourceDestCheck" do
          expect(resource["Properties"]["SourceDestCheck"]).to eq(false)
      end
      
      it "to have property GroupSet" do
          expect(resource["Properties"]["GroupSet"]).to eq([{"Ref"=>"NatInstanceSecurityGroup"}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "EIPAssociation0" do
      let(:resource) { template["Resources"]["EIPAssociation0"] }

      it "is of type AWS::EC2::EIPAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::EIPAssociation")
      end
      
      it "to have property AllocationId" do
          expect(resource["Properties"]["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress0", "AllocationId"]}, {"Fn::Select"=>[0, {"Ref"=>"NatGatewayEIPs"}]}]})
      end
      
      it "to have property NetworkInterfaceId" do
          expect(resource["Properties"]["NetworkInterfaceId"]).to eq({"Ref"=>"NetworkInterface0"})
      end
      
    end
    
    context "LaunchTemplate0" do
      let(:resource) { template["Resources"]["LaunchTemplate0"] }

      it "is of type AWS::EC2::LaunchTemplate" do
          expect(resource["Type"]).to eq("AWS::EC2::LaunchTemplate")
      end
      
      it "to have property LaunchTemplateData" do
          expect(resource["Properties"]["LaunchTemplateData"]).to eq({"TagSpecifications"=>[{"ResourceType"=>"instance", "Tags"=>[{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}]}, {"ResourceType"=>"volume", "Tags"=>[{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}]}], "ImageId"=>{"Ref"=>"NatAmi"}, "InstanceType"=>{"Ref"=>"NatInstanceType"}, "UserData"=>{"Fn::Base64"=>{"Fn::Sub"=>"#!/bin/bash\nINSTANCE_ID=$(curl http://169.254.169.254/2014-11-05/meta-data/instance-id -s)\naws ec2 attach-network-interface --instance-id $INSTANCE_ID --network-interface-id ${NetworkInterface0} --device-index 1 --region ${AWS::Region}\n/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchTemplate0 --region ${AWS::Region}\nsystemctl disable postfix\nsystemctl stop postfix\nsystemctl enable snat\nsystemctl start snat\n"}}, "IamInstanceProfile"=>{"Name"=>{"Ref"=>"NatInstanceProfile"}}, "NetworkInterfaces"=>[{"DeviceIndex"=>0, "AssociatePublicIpAddress"=>true, "Groups"=>[{"Ref"=>"NatInstanceSecurityGroup"}]}], "InstanceMarketOptions"=>{"Fn::If"=>["SpotEnabled", {"MarketType"=>"spot", "SpotOptions"=>{"SpotInstanceType"=>"one-time"}}, {"Ref"=>"AWS::NoValue"}]}})
      end
      
    end
    
    context "AutoScaleGroup0" do
      let(:resource) { template["Resources"]["AutoScaleGroup0"] }

      it "is of type AWS::AutoScaling::AutoScalingGroup" do
          expect(resource["Type"]).to eq("AWS::AutoScaling::AutoScalingGroup")
      end
      
      it "to have property DesiredCapacity" do
          expect(resource["Properties"]["DesiredCapacity"]).to eq("1")
      end
      
      it "to have property MinSize" do
          expect(resource["Properties"]["MinSize"]).to eq("1")
      end
      
      it "to have property MaxSize" do
          expect(resource["Properties"]["MaxSize"]).to eq("1")
      end
      
      it "to have property VPCZoneIdentifier" do
          expect(resource["Properties"]["VPCZoneIdentifier"]).to eq([{"Ref"=>"SubnetPublic0"}])
      end
      
      it "to have property LaunchTemplate" do
          expect(resource["Properties"]["LaunchTemplate"]).to eq({"LaunchTemplateId"=>{"Ref"=>"LaunchTemplate0"}, "Version"=>{"Fn::GetAtt"=>["LaunchTemplate0", "LatestVersionNumber"]}})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}, "PropagateAtLaunch"=>false}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}, "PropagateAtLaunch"=>false}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}, "PropagateAtLaunch"=>false}])
      end
      
    end
    
    context "RouteOutToInternet0ViaNatInstance" do
      let(:resource) { template["Resources"]["RouteOutToInternet0ViaNatInstance"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property NetworkInterfaceId" do
          expect(resource["Properties"]["NetworkInterfaceId"]).to eq({"Fn::If"=>["CreateNatInstance0", {"Ref"=>"NetworkInterface0"}, {"Ref"=>"NetworkInterface0"}]})
      end
      
    end
    
    context "RouteTablePrivate1" do
      let(:resource) { template["Resources"]["RouteTablePrivate1"] }

      it "is of type AWS::EC2::RouteTable" do
          expect(resource["Type"]).to eq("AWS::EC2::RouteTable")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-private-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatIPAddress1" do
      let(:resource) { template["Resources"]["NatIPAddress1"] }

      it "is of type AWS::EC2::EIP" do
          expect(resource["Type"]).to eq("AWS::EC2::EIP")
      end
      
      it "to have property Domain" do
          expect(resource["Properties"]["Domain"]).to eq("vpc")
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatGateway1" do
      let(:resource) { template["Resources"]["NatGateway1"] }

      it "is of type AWS::EC2::NatGateway" do
          expect(resource["Type"]).to eq("AWS::EC2::NatGateway")
      end
      
      it "to have property AllocationId" do
          expect(resource["Properties"]["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress1", "AllocationId"]}, {"Fn::Select"=>[1, {"Ref"=>"NatGatewayEIPs"}]}]})
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-natgw-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "RouteOutToInternet1" do
      let(:resource) { template["Resources"]["RouteOutToInternet1"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property NatGatewayId" do
          expect(resource["Properties"]["NatGatewayId"]).to eq({"Fn::If"=>["CreateManagedNat1", {"Ref"=>"NatGateway1"}, {"Ref"=>"NatGateway0"}]})
      end
      
    end
    
    context "NetworkInterface1" do
      let(:resource) { template["Resources"]["NetworkInterface1"] }

      it "is of type AWS::EC2::NetworkInterface" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkInterface")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
      end
      
      it "to have property SourceDestCheck" do
          expect(resource["Properties"]["SourceDestCheck"]).to eq(false)
      end
      
      it "to have property GroupSet" do
          expect(resource["Properties"]["GroupSet"]).to eq([{"Ref"=>"NatInstanceSecurityGroup"}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "EIPAssociation1" do
      let(:resource) { template["Resources"]["EIPAssociation1"] }

      it "is of type AWS::EC2::EIPAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::EIPAssociation")
      end
      
      it "to have property AllocationId" do
          expect(resource["Properties"]["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress1", "AllocationId"]}, {"Fn::Select"=>[1, {"Ref"=>"NatGatewayEIPs"}]}]})
      end
      
      it "to have property NetworkInterfaceId" do
          expect(resource["Properties"]["NetworkInterfaceId"]).to eq({"Ref"=>"NetworkInterface1"})
      end
      
    end
    
    context "LaunchTemplate1" do
      let(:resource) { template["Resources"]["LaunchTemplate1"] }

      it "is of type AWS::EC2::LaunchTemplate" do
          expect(resource["Type"]).to eq("AWS::EC2::LaunchTemplate")
      end
      
      it "to have property LaunchTemplateData" do
          expect(resource["Properties"]["LaunchTemplateData"]).to eq({"TagSpecifications"=>[{"ResourceType"=>"instance", "Tags"=>[{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}]}, {"ResourceType"=>"volume", "Tags"=>[{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}]}], "ImageId"=>{"Ref"=>"NatAmi"}, "InstanceType"=>{"Ref"=>"NatInstanceType"}, "UserData"=>{"Fn::Base64"=>{"Fn::Sub"=>"#!/bin/bash\nINSTANCE_ID=$(curl http://169.254.169.254/2014-11-05/meta-data/instance-id -s)\naws ec2 attach-network-interface --instance-id $INSTANCE_ID --network-interface-id ${NetworkInterface1} --device-index 1 --region ${AWS::Region}\n/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchTemplate1 --region ${AWS::Region}\nsystemctl disable postfix\nsystemctl stop postfix\nsystemctl enable snat\nsystemctl start snat\n"}}, "IamInstanceProfile"=>{"Name"=>{"Ref"=>"NatInstanceProfile"}}, "NetworkInterfaces"=>[{"DeviceIndex"=>0, "AssociatePublicIpAddress"=>true, "Groups"=>[{"Ref"=>"NatInstanceSecurityGroup"}]}], "InstanceMarketOptions"=>{"Fn::If"=>["SpotEnabled", {"MarketType"=>"spot", "SpotOptions"=>{"SpotInstanceType"=>"one-time"}}, {"Ref"=>"AWS::NoValue"}]}})
      end
      
    end
    
    context "AutoScaleGroup1" do
      let(:resource) { template["Resources"]["AutoScaleGroup1"] }

      it "is of type AWS::AutoScaling::AutoScalingGroup" do
          expect(resource["Type"]).to eq("AWS::AutoScaling::AutoScalingGroup")
      end
      
      it "to have property DesiredCapacity" do
          expect(resource["Properties"]["DesiredCapacity"]).to eq("1")
      end
      
      it "to have property MinSize" do
          expect(resource["Properties"]["MinSize"]).to eq("1")
      end
      
      it "to have property MaxSize" do
          expect(resource["Properties"]["MaxSize"]).to eq("1")
      end
      
      it "to have property VPCZoneIdentifier" do
          expect(resource["Properties"]["VPCZoneIdentifier"]).to eq([{"Ref"=>"SubnetPublic1"}])
      end
      
      it "to have property LaunchTemplate" do
          expect(resource["Properties"]["LaunchTemplate"]).to eq({"LaunchTemplateId"=>{"Ref"=>"LaunchTemplate1"}, "Version"=>{"Fn::GetAtt"=>["LaunchTemplate1", "LatestVersionNumber"]}})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}, "PropagateAtLaunch"=>false}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}, "PropagateAtLaunch"=>false}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}, "PropagateAtLaunch"=>false}])
      end
      
    end
    
    context "RouteOutToInternet1ViaNatInstance" do
      let(:resource) { template["Resources"]["RouteOutToInternet1ViaNatInstance"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property NetworkInterfaceId" do
          expect(resource["Properties"]["NetworkInterfaceId"]).to eq({"Fn::If"=>["CreateNatInstance1", {"Ref"=>"NetworkInterface1"}, {"Ref"=>"NetworkInterface0"}]})
      end
      
    end
    
    context "RouteTablePrivate2" do
      let(:resource) { template["Resources"]["RouteTablePrivate2"] }

      it "is of type AWS::EC2::RouteTable" do
          expect(resource["Type"]).to eq("AWS::EC2::RouteTable")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-private-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatIPAddress2" do
      let(:resource) { template["Resources"]["NatIPAddress2"] }

      it "is of type AWS::EC2::EIP" do
          expect(resource["Type"]).to eq("AWS::EC2::EIP")
      end
      
      it "to have property Domain" do
          expect(resource["Properties"]["Domain"]).to eq("vpc")
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "NatGateway2" do
      let(:resource) { template["Resources"]["NatGateway2"] }

      it "is of type AWS::EC2::NatGateway" do
          expect(resource["Type"]).to eq("AWS::EC2::NatGateway")
      end
      
      it "to have property AllocationId" do
          expect(resource["Properties"]["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress2", "AllocationId"]}, {"Fn::Select"=>[2, {"Ref"=>"NatGatewayEIPs"}]}]})
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-natgw-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "RouteOutToInternet2" do
      let(:resource) { template["Resources"]["RouteOutToInternet2"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property NatGatewayId" do
          expect(resource["Properties"]["NatGatewayId"]).to eq({"Fn::If"=>["CreateManagedNat2", {"Ref"=>"NatGateway2"}, {"Ref"=>"NatGateway0"}]})
      end
      
    end
    
    context "NetworkInterface2" do
      let(:resource) { template["Resources"]["NetworkInterface2"] }

      it "is of type AWS::EC2::NetworkInterface" do
          expect(resource["Type"]).to eq("AWS::EC2::NetworkInterface")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
      end
      
      it "to have property SourceDestCheck" do
          expect(resource["Properties"]["SourceDestCheck"]).to eq(false)
      end
      
      it "to have property GroupSet" do
          expect(resource["Properties"]["GroupSet"]).to eq([{"Ref"=>"NatInstanceSecurityGroup"}])
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "EIPAssociation2" do
      let(:resource) { template["Resources"]["EIPAssociation2"] }

      it "is of type AWS::EC2::EIPAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::EIPAssociation")
      end
      
      it "to have property AllocationId" do
          expect(resource["Properties"]["AllocationId"]).to eq({"Fn::If"=>["CreateNatGatewayEIP", {"Fn::GetAtt"=>["NatIPAddress2", "AllocationId"]}, {"Fn::Select"=>[2, {"Ref"=>"NatGatewayEIPs"}]}]})
      end
      
      it "to have property NetworkInterfaceId" do
          expect(resource["Properties"]["NetworkInterfaceId"]).to eq({"Ref"=>"NetworkInterface2"})
      end
      
    end
    
    context "LaunchTemplate2" do
      let(:resource) { template["Resources"]["LaunchTemplate2"] }

      it "is of type AWS::EC2::LaunchTemplate" do
          expect(resource["Type"]).to eq("AWS::EC2::LaunchTemplate")
      end
      
      it "to have property LaunchTemplateData" do
          expect(resource["Properties"]["LaunchTemplateData"]).to eq({"TagSpecifications"=>[{"ResourceType"=>"instance", "Tags"=>[{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}]}, {"ResourceType"=>"volume", "Tags"=>[{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}]}], "ImageId"=>{"Ref"=>"NatAmi"}, "InstanceType"=>{"Ref"=>"NatInstanceType"}, "UserData"=>{"Fn::Base64"=>{"Fn::Sub"=>"#!/bin/bash\nINSTANCE_ID=$(curl http://169.254.169.254/2014-11-05/meta-data/instance-id -s)\naws ec2 attach-network-interface --instance-id $INSTANCE_ID --network-interface-id ${NetworkInterface2} --device-index 1 --region ${AWS::Region}\n/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchTemplate2 --region ${AWS::Region}\nsystemctl disable postfix\nsystemctl stop postfix\nsystemctl enable snat\nsystemctl start snat\n"}}, "IamInstanceProfile"=>{"Name"=>{"Ref"=>"NatInstanceProfile"}}, "NetworkInterfaces"=>[{"DeviceIndex"=>0, "AssociatePublicIpAddress"=>true, "Groups"=>[{"Ref"=>"NatInstanceSecurityGroup"}]}], "InstanceMarketOptions"=>{"Fn::If"=>["SpotEnabled", {"MarketType"=>"spot", "SpotOptions"=>{"SpotInstanceType"=>"one-time"}}, {"Ref"=>"AWS::NoValue"}]}})
      end
      
    end
    
    context "AutoScaleGroup2" do
      let(:resource) { template["Resources"]["AutoScaleGroup2"] }

      it "is of type AWS::AutoScaling::AutoScalingGroup" do
          expect(resource["Type"]).to eq("AWS::AutoScaling::AutoScalingGroup")
      end
      
      it "to have property DesiredCapacity" do
          expect(resource["Properties"]["DesiredCapacity"]).to eq("1")
      end
      
      it "to have property MinSize" do
          expect(resource["Properties"]["MinSize"]).to eq("1")
      end
      
      it "to have property MaxSize" do
          expect(resource["Properties"]["MaxSize"]).to eq("1")
      end
      
      it "to have property VPCZoneIdentifier" do
          expect(resource["Properties"]["VPCZoneIdentifier"]).to eq([{"Ref"=>"SubnetPublic2"}])
      end
      
      it "to have property LaunchTemplate" do
          expect(resource["Properties"]["LaunchTemplate"]).to eq({"LaunchTemplateId"=>{"Ref"=>"LaunchTemplate2"}, "Version"=>{"Fn::GetAtt"=>["LaunchTemplate2", "LatestVersionNumber"]}})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-nat-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}, "PropagateAtLaunch"=>false}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}, "PropagateAtLaunch"=>false}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}, "PropagateAtLaunch"=>false}])
      end
      
    end
    
    context "RouteOutToInternet2ViaNatInstance" do
      let(:resource) { template["Resources"]["RouteOutToInternet2ViaNatInstance"] }

      it "is of type AWS::EC2::Route" do
          expect(resource["Type"]).to eq("AWS::EC2::Route")
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
      end
      
      it "to have property DestinationCidrBlock" do
          expect(resource["Properties"]["DestinationCidrBlock"]).to eq("0.0.0.0/0")
      end
      
      it "to have property NetworkInterfaceId" do
          expect(resource["Properties"]["NetworkInterfaceId"]).to eq({"Fn::If"=>["CreateNatInstance2", {"Ref"=>"NetworkInterface2"}, {"Ref"=>"NetworkInterface0"}]})
      end
      
    end
    
    context "SubnetPublic0" do
      let(:resource) { template["Resources"]["SubnetPublic0"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[0, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"public"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetPublic0" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetPublic0"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
      end
      
    end
    
    context "ACLAssociationSubnetPublic0" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetPublic0"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic0"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
    end
    
    context "SubnetPublic1" do
      let(:resource) { template["Resources"]["SubnetPublic1"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[1, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"public"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetPublic1" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetPublic1"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
      end
      
    end
    
    context "ACLAssociationSubnetPublic1" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetPublic1"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic1"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
    end
    
    context "SubnetPublic2" do
      let(:resource) { template["Resources"]["SubnetPublic2"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[2, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"public"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetPublic2" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetPublic2"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePublic"})
      end
      
    end
    
    context "ACLAssociationSubnetPublic2" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetPublic2"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPublic2"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
      end
      
    end
    
    context "SubnetCompute0" do
      let(:resource) { template["Resources"]["SubnetCompute0"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[4, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-compute-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetCompute0" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetCompute0"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCompute0"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
      end
      
    end
    
    context "ACLAssociationSubnetCompute0" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetCompute0"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCompute0"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetCompute1" do
      let(:resource) { template["Resources"]["SubnetCompute1"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[5, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-compute-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetCompute1" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetCompute1"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCompute1"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
      end
      
    end
    
    context "ACLAssociationSubnetCompute1" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetCompute1"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCompute1"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetCompute2" do
      let(:resource) { template["Resources"]["SubnetCompute2"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[6, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-compute-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetCompute2" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetCompute2"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCompute2"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
      end
      
    end
    
    context "ACLAssociationSubnetCompute2" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetCompute2"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCompute2"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetPersistence0" do
      let(:resource) { template["Resources"]["SubnetPersistence0"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[8, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-persistence-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetPersistence0" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetPersistence0"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPersistence0"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
      end
      
    end
    
    context "ACLAssociationSubnetPersistence0" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetPersistence0"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPersistence0"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetPersistence1" do
      let(:resource) { template["Resources"]["SubnetPersistence1"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[9, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-persistence-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetPersistence1" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetPersistence1"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPersistence1"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
      end
      
    end
    
    context "ACLAssociationSubnetPersistence1" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetPersistence1"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPersistence1"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetPersistence2" do
      let(:resource) { template["Resources"]["SubnetPersistence2"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[10, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-persistence-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetPersistence2" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetPersistence2"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPersistence2"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
      end
      
    end
    
    context "ACLAssociationSubnetPersistence2" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetPersistence2"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetPersistence2"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetCache0" do
      let(:resource) { template["Resources"]["SubnetCache0"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[12, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-cache-${AZ}", {"AZ"=>{"Fn::Select"=>[0, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetCache0" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetCache0"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCache0"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
      end
      
    end
    
    context "ACLAssociationSubnetCache0" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetCache0"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCache0"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetCache1" do
      let(:resource) { template["Resources"]["SubnetCache1"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[13, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-cache-${AZ}", {"AZ"=>{"Fn::Select"=>[1, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetCache1" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetCache1"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCache1"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
      end
      
    end
    
    context "ACLAssociationSubnetCache1" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetCache1"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCache1"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "SubnetCache2" do
      let(:resource) { template["Resources"]["SubnetCache2"] }

      it "is of type AWS::EC2::Subnet" do
          expect(resource["Type"]).to eq("AWS::EC2::Subnet")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property CidrBlock" do
          expect(resource["Properties"]["CidrBlock"]).to eq({"Fn::Select"=>[14, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
      end
      
      it "to have property AvailabilityZone" do
          expect(resource["Properties"]["AvailabilityZone"]).to eq({"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Type", "Value"=>"private"}, {"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-cache-${AZ}", {"AZ"=>{"Fn::Select"=>[2, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}])
      end
      
    end
    
    context "RouteTableAssociationSubnetCache2" do
      let(:resource) { template["Resources"]["RouteTableAssociationSubnetCache2"] }

      it "is of type AWS::EC2::SubnetRouteTableAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetRouteTableAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCache2"})
      end
      
      it "to have property RouteTableId" do
          expect(resource["Properties"]["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate2"})
      end
      
    end
    
    context "ACLAssociationSubnetCache2" do
      let(:resource) { template["Resources"]["ACLAssociationSubnetCache2"] }

      it "is of type AWS::EC2::SubnetNetworkAclAssociation" do
          expect(resource["Type"]).to eq("AWS::EC2::SubnetNetworkAclAssociation")
      end
      
      it "to have property SubnetId" do
          expect(resource["Properties"]["SubnetId"]).to eq({"Ref"=>"SubnetCache2"})
      end
      
      it "to have property NetworkAclId" do
          expect(resource["Properties"]["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
      end
      
    end
    
    context "S3VpcEndpoint" do
      let(:resource) { template["Resources"]["S3VpcEndpoint"] }

      it "is of type AWS::EC2::VPCEndpoint" do
          expect(resource["Type"]).to eq("AWS::EC2::VPCEndpoint")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property PolicyDocument" do
          expect(resource["Properties"]["PolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>"*", "Action"=>["s3:*"], "Resource"=>["arn:aws:s3:::*"]}]})
      end
      
      it "to have property ServiceName" do
          expect(resource["Properties"]["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.s3"})
      end
      
      it "to have property RouteTableIds" do
          expect(resource["Properties"]["RouteTableIds"]).to eq([{"Ref"=>"RouteTablePrivate0"}, {"Ref"=>"RouteTablePrivate1"}, {"Ref"=>"RouteTablePrivate2"}])
      end
      
    end
    
    context "VGW" do
      let(:resource) { template["Resources"]["VGW"] }

      it "is of type AWS::EC2::VPNGateway" do
          expect(resource["Type"]).to eq("AWS::EC2::VPNGateway")
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("ipsec.1")
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-VGW"}}, {"Key"=>"transitvpc:spoke", "Value"=>{"Ref"=>"EnableTransitVPC"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "AttachVGWToVPC" do
      let(:resource) { template["Resources"]["AttachVGWToVPC"] }

      it "is of type AWS::EC2::VPCGatewayAttachment" do
          expect(resource["Type"]).to eq("AWS::EC2::VPCGatewayAttachment")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPC"})
      end
      
      it "to have property VpnGatewayId" do
          expect(resource["Properties"]["VpnGatewayId"]).to eq({"Ref"=>"VGW"})
      end
      
    end
    
    context "PropagateRoute" do
      let(:resource) { template["Resources"]["PropagateRoute"] }

      it "is of type AWS::EC2::VPNGatewayRoutePropagation" do
          expect(resource["Type"]).to eq("AWS::EC2::VPNGatewayRoutePropagation")
      end
      
      it "to have property RouteTableIds" do
          expect(resource["Properties"]["RouteTableIds"]).to eq([{"Ref"=>"RouteTablePrivate0"}, {"Ref"=>"RouteTablePrivate1"}, {"Ref"=>"RouteTablePrivate2"}])
      end
      
      it "to have property VpnGatewayId" do
          expect(resource["Properties"]["VpnGatewayId"]).to eq({"Ref"=>"VGW"})
      end
      
    end
    
    context "HostedZone" do
      let(:resource) { template["Resources"]["HostedZone"] }

      it "is of type AWS::Route53::HostedZone" do
          expect(resource["Type"]).to eq("AWS::Route53::HostedZone")
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}"})
      end
      
      it "to have property HostedZoneConfig" do
          expect(resource["Properties"]["HostedZoneConfig"]).to eq({"Comment"=>{"Fn::Sub"=>"Hosted Zone for ${EnvironmentName}"}})
      end
      
      it "to have property HostedZoneTags" do
          expect(resource["Properties"]["HostedZoneTags"]).to eq([{"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}"}}, {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
  end

end