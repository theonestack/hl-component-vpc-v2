require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/transit_vpc.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/transit_vpc/vpc-v2.compiled.yaml") }

  context 'Resource VGW' do
    let(:properties) { template["Resources"]["VGW"]["Properties"] }

    it 'has property Type' do
      expect(properties["Type"]).to eq('ipsec.1')
    end

    it 'has property AmazonSideAsn' do
      expect(properties["AmazonSideAsn"]).to eq(64512)
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to eq([
        {"Key"=>"Name", "Value"=>{"Fn::Sub"=>"${EnvironmentName}-VGW"}}, 
        {"Key"=>"transitvpc:spoke", "Value"=>{"Ref"=>"EnableTransitVPC"}}, 
        {"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, 
        {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end
  end

  context 'Resource AttachVGWToVPC' do
    let(:properties) { template["Resources"]["AttachVGWToVPC"]["Properties"] }
    let(:condition) { template["Resources"]["AttachVGWToVPC"]["Condition"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref" => "VPC"})
    end
    
    it 'has property VpnGatewayId' do
      expect(properties["VpnGatewayId"]).to eq({"Ref" => "VGW"})
    end
    
    it 'has condition' do
      expect(condition).to eq('DoEnableTransitVPC')
    end
  end
  
  context 'Resource PropagateRoute' do
    let(:properties) { template["Resources"]["PropagateRoute"]["Properties"] }
    let(:condition) { template["Resources"]["PropagateRoute"]["Condition"] }
    let(:depends_on) { template["Resources"]["PropagateRoute"]["DependsOn"] }

    it 'has property RouteTableIds' do
      expect(properties["RouteTableIds"]).to eq([
        {"Ref" => "RouteTablePrivate0"},
        {"Ref" => "RouteTablePrivate1"},
        {"Ref" => "RouteTablePrivate2"}
      ])
    end
    
    it 'has property VpnGatewayId' do
      expect(properties["VpnGatewayId"]).to eq({"Ref" => "VGW"})
    end
    
    it 'has condition' do
      expect(condition).to eq('DoEnableTransitVPC')
    end
    
    it 'has depends on' do
      expect(depends_on).to eq(['AttachVGWToVPC'])
    end
  end
  
  context 'Parameters' do
    
    let(:parameters) { template["Parameters"].keys }
    
    it 'has parameter EnableTransitVPC' do
      expect(parameters).to include('EnableTransitVPC')
    end
  end
  
  context 'Condition' do
    
    let(:conditions) { template["Conditions"] }
    
    it 'DoEnableTransitVPC checks if EnableTransitVPC is true' do
      expect(conditions['DoEnableTransitVPC']).to eq({"Fn::Equals" => [{"Ref" => "EnableTransitVPC"}, 'true']})
    end

  end
  
end