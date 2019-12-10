require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/subnet_parameters.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/subnet_parameters/vpc-v2.compiled.yaml") }

  context 'Resource VPC' do

    let(:properties) { template["Resources"]["VPC"]["Properties"] }

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Ref"=>"CIDR"})
    end

  end
  
  context 'Resource Subnet Public0' do
    
    let(:properties) { template["Resources"]["SubnetPublic0"]["Properties"] }
    
    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[0, {"Ref"=>"PublicSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Public1' do
    
    let(:properties) { template["Resources"]["SubnetPublic1"]["Properties"] }
    
    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[1, {"Ref"=>"PublicSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Public2' do
    
    let(:properties) { template["Resources"]["SubnetPublic2"]["Properties"] }
    
    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[2, {"Ref"=>"PublicSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Compute0' do
    
    let(:properties) { template["Resources"]["SubnetCompute0"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[0, {"Ref"=>"ComputeSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Compute1' do
    
    let(:properties) { template["Resources"]["SubnetCompute1"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[1, {"Ref"=>"ComputeSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Compute2' do
    
    let(:properties) { template["Resources"]["SubnetCompute2"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[2, {"Ref"=>"ComputeSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Persistence0' do
    
    let(:properties) { template["Resources"]["SubnetPersistence0"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[0, {"Ref"=>"PersistenceSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Persistence1' do
    
    let(:properties) { template["Resources"]["SubnetPersistence1"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[1, {"Ref"=>"PersistenceSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Persistence2' do
    
    let(:properties) { template["Resources"]["SubnetPersistence2"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[2, {"Ref"=>"PersistenceSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Cache0' do
    
    let(:properties) { template["Resources"]["SubnetCache0"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[0, {"Ref"=>"CacheSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Cache1' do
    
    let(:properties) { template["Resources"]["SubnetCache1"]["Properties"] }
    
    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[1, {"Ref"=>"CacheSubnetList"}]})
    end
    
  end
  
  context 'Resource Subnet Cache2' do
    
    let(:properties) { template["Resources"]["SubnetCache2"]["Properties"] }

    it "has property CidrBlock with a Fn::Select" do
      expect(properties["CidrBlock"]).to eq({"Fn::Select"=>[2, {"Ref"=>"CacheSubnetList"}]})
    end
    
  end

  context 'Parameters' do
    
    let(:parameters) { template["Parameters"].keys }
    
    it 'has parameter CIDR' do
      expect(parameters).to include('CIDR')
    end
    
    it 'CIDR parameter has default value of' do
      expect(template["Parameters"]["CIDR"]["Default"]).to eq('192.168.1.0/23')
    end
    
    it 'has parameter PublicSubnetList' do
      expect(parameters).to include('PublicSubnetList')
    end
    
    it 'PublicSubnetList parameter has default value of' do
      expect(template["Parameters"]["PublicSubnetList"]["Default"]).to eq('192.168.0.0/28,192.168.0.16/28,192.168.0.32/28')
    end
    
    it 'has parameter ComputeSubnetList' do
      expect(parameters).to include('ComputeSubnetList')
    end
    
    it 'ComputeSubnetList parameter has default value of' do
      expect(template["Parameters"]["ComputeSubnetList"]["Default"]).to eq('192.168.0.64/28,192.168.0.80/28,192.168.0.96/28')
    end
    
    it 'has parameter ComputeSubnetList' do
      expect(parameters).to include('ComputeSubnetList')
    end
    
    it 'PersistenceSubnetList parameter has default value of' do
      expect(template["Parameters"]["PersistenceSubnetList"]["Default"]).to eq('192.168.0.128/28,192.168.0.144/28,192.168.0.160/28')
    end
    
    it 'has parameter ComputeSubnetList' do
      expect(parameters).to include('ComputeSubnetList')
    end
    
    it 'CacheSubnetList parameter has default value of' do
      expect(template["Parameters"]["CacheSubnetList"]["Default"]).to eq('192.168.0.192/28,192.168.0.208/28,192.168.0.224/28')
    end
    
  end

end
