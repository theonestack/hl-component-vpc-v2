require 'yaml'

describe 'compiled component' do
    
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/endpoints.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/endpoints/vpc-v2.compiled.yaml") }

  context 'Resource VpcEndpointInterface' do

    let(:properties) { template["Resources"]["VpcEndpointInterface"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property GroupDescription' do
      expect(properties["GroupDescription"]).to eq({"Fn::Sub"=>"Access to Amazon service VPC Endpoints from within the ${EnvironmentName} VPC"})
    end

    it 'has property SecurityGroupIngress' do
      expect(properties["SecurityGroupIngress"]).to eq([{"CidrIp"=>{"Fn::GetAtt"=>["VPC", "CidrBlock"]}, "Description"=>{"Fn::Sub"=>"HTTPS from ${EnvironmentName} VPC"}, "IpProtocol"=>"tcp", "FromPort"=>"443", "ToPort"=>"443"}])
    end

  end

  context 'Resource SsmVpcEndpoint' do

    let(:properties) { template["Resources"]["SsmVpcEndpoint"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property ServiceName' do
      expect(properties["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.ssm"})
    end

    it 'has property VpcEndpointType' do
      expect(properties["VpcEndpointType"]).to eq("Interface")
    end

    it 'has property PrivateDnsEnabled' do
      expect(properties["PrivateDnsEnabled"]).to eq(true)
    end

    it 'has property SubnetIds' do
      expect(properties["SubnetIds"]).to eq({"Fn::If"=>["CreateAvailabilityZone2", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}], {"Fn::If"=>["CreateAvailabilityZone1", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}], {"Fn::If"=>["CreateAvailabilityZone0", [{"Ref"=>"SubnetCompute0"}], ""]}]}]})
    end

    it 'has property SecurityGroupIds' do
      expect(properties["SecurityGroupIds"]).to eq([{"Ref"=>"VpcEndpointInterface"}])
    end

  end

  context 'Resource SsmmessagesVpcEndpoint' do

    let(:properties) { template["Resources"]["SsmmessagesVpcEndpoint"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property ServiceName' do
      expect(properties["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.ssmmessages"})
    end

    it 'has property VpcEndpointType' do
      expect(properties["VpcEndpointType"]).to eq("Interface")
    end

    it 'has property PrivateDnsEnabled' do
      expect(properties["PrivateDnsEnabled"]).to eq(true)
    end

    it 'has property SubnetIds' do
      expect(properties["SubnetIds"]).to eq({"Fn::If"=>["CreateAvailabilityZone2", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}], {"Fn::If"=>["CreateAvailabilityZone1", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}], {"Fn::If"=>["CreateAvailabilityZone0", [{"Ref"=>"SubnetCompute0"}], ""]}]}]})
    end

    it 'has property SecurityGroupIds' do
      expect(properties["SecurityGroupIds"]).to eq([{"Ref"=>"VpcEndpointInterface"}])
    end

  end

  context 'Resource Ec2VpcEndpoint' do

    let(:properties) { template["Resources"]["Ec2VpcEndpoint"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property ServiceName' do
      expect(properties["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.ec2"})
    end

    it 'has property VpcEndpointType' do
      expect(properties["VpcEndpointType"]).to eq("Interface")
    end

    it 'has property PrivateDnsEnabled' do
      expect(properties["PrivateDnsEnabled"]).to eq(true)
    end

    it 'has property SubnetIds' do
      expect(properties["SubnetIds"]).to eq({"Fn::If"=>["CreateAvailabilityZone2", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}], {"Fn::If"=>["CreateAvailabilityZone1", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}], {"Fn::If"=>["CreateAvailabilityZone0", [{"Ref"=>"SubnetCompute0"}], ""]}]}]})
    end

    it 'has property SecurityGroupIds' do
      expect(properties["SecurityGroupIds"]).to eq([{"Ref"=>"VpcEndpointInterface"}])
    end

  end

  context 'Resource Ec2messagesVpcEndpoint' do

    let(:properties) { template["Resources"]["Ec2messagesVpcEndpoint"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property ServiceName' do
      expect(properties["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.ec2messages"})
    end

    it 'has property VpcEndpointType' do
      expect(properties["VpcEndpointType"]).to eq("Interface")
    end

    it 'has property PrivateDnsEnabled' do
      expect(properties["PrivateDnsEnabled"]).to eq(true)
    end

    it 'has property SubnetIds' do
      expect(properties["SubnetIds"]).to eq({"Fn::If"=>["CreateAvailabilityZone2", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}], {"Fn::If"=>["CreateAvailabilityZone1", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}], {"Fn::If"=>["CreateAvailabilityZone0", [{"Ref"=>"SubnetCompute0"}], ""]}]}]})
    end

    it 'has property SecurityGroupIds' do
      expect(properties["SecurityGroupIds"]).to eq([{"Ref"=>"VpcEndpointInterface"}])
    end

  end

  context 'Resource Ec2apiVpcEndpoint' do

    let(:properties) { template["Resources"]["Ec2apiVpcEndpoint"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property ServiceName' do
      expect(properties["ServiceName"]).to eq({"Fn::Sub"=>"com.amazonaws.${AWS::Region}.ec2.api"})
    end

    it 'has property VpcEndpointType' do
      expect(properties["VpcEndpointType"]).to eq("Interface")
    end

    it 'has property PrivateDnsEnabled' do
      expect(properties["PrivateDnsEnabled"]).to eq(true)
    end

    it 'has property SubnetIds' do
      expect(properties["SubnetIds"]).to eq({"Fn::If"=>["CreateAvailabilityZone2", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}, {"Ref"=>"SubnetCompute2"}], {"Fn::If"=>["CreateAvailabilityZone1", [{"Ref"=>"SubnetCompute0"}, {"Ref"=>"SubnetCompute1"}], {"Fn::If"=>["CreateAvailabilityZone0", [{"Ref"=>"SubnetCompute0"}], ""]}]}]})
    end

    it 'has property SecurityGroupIds' do
      expect(properties["SecurityGroupIds"]).to eq([{"Ref"=>"VpcEndpointInterface"}])
    end

  end
  
end
