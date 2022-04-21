require 'yaml'
require 'spec_helper'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/custom_routes.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/custom_routes/vpc-v2.compiled.yaml") }

  context 'Resource CustomRoute00' do

    let(:properties) { template["Resources"]["CustomRoute00"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate0"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("192.168.1.0/24")
    end

    it 'has property TransitGatewayId' do
      expect(properties["TransitGatewayId"]).to eq("tgw-0a9c82d1928fce121")
    end

  end

  context 'Resource CustomRoute01' do

    let(:properties) { template["Resources"]["CustomRoute11"]["Properties"] }

    it 'has property RouteTableId' do
      expect(properties["RouteTableId"]).to eq({"Ref"=>"RouteTablePrivate1"})
    end

    it 'has property DestinationCidrBlock' do
      expect(properties["DestinationCidrBlock"]).to eq("10.8.0.0/16")
    end

    it 'has property TransitGatewayId' do
      expect(properties["VpcPeeringConnectionId"]).to eq("pcx-1c1f309b02067137e")
    end

  end

end
