require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/nacl.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/nacl/vpc-v2.compiled.yaml") }

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
      expect(properties["CidrBlock"]).to eq("1.1.1.1/32")
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>22, "To"=>22})
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
      expect(properties["Protocol"]).to eq("6")
    end

    it 'has property RuleAction' do
      expect(properties["RuleAction"]).to eq("allow")
    end

    it 'has property Egress' do
      expect(properties["Egress"]).to eq(false)
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::GetAtt"=>["VPC", "CidrBlock"]})
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>22, "To"=>22})
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

  context 'Resource NaclRuleInboundPublic101' do

    let(:properties) { template["Resources"]["NaclRuleInboundPublic101"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPublic"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(101)
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
      expect(properties["CidrBlock"]).to eq({"Fn::GetAtt"=>["VPC", "CidrBlock"]})
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>22, "To"=>22})
    end

  end

  context 'Resource NaclRuleInboundPrivate101' do

    let(:properties) { template["Resources"]["NaclRuleInboundPrivate101"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(101)
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
      expect(properties["CidrBlock"]).to eq("10.0.3.5/32")
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>22, "To"=>22})
    end

  end

  context 'Resource NaclRuleInboundPrivate102' do

    let(:properties) { template["Resources"]["NaclRuleInboundPrivate102"]["Properties"] }

    it 'has property NetworkAclId' do
      expect(properties["NetworkAclId"]).to eq({"Ref"=>"NetworkAclPrivate"})
    end

    it 'has property RuleNumber' do
      expect(properties["RuleNumber"]).to eq(102)
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
      expect(properties["CidrBlock"]).to eq("192.168.5.8/32")
    end

    it 'has property PortRange' do
      expect(properties["PortRange"]).to eq({"From"=>22, "To"=>22})
    end

  end

end
