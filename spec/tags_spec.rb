require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/tags.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/tags/vpc-v2.compiled.yaml") }

  context 'Resource VPC' do
    let(:tags) { template["Resources"]["VGW"]["Properties"]["Tags"] }

    it 'has property Tags' do
      expect(tags).to include({"Key"=>{"Fn::Sub"=>"Application"}, "Value"=>{"Fn::Sub"=>"MyApp"}})
      expect(tags).to include({"Key"=>{"Fn::Sub"=>"CreatedBy"}, "Value"=>{"Fn::Sub"=>"theonestack"}})
    end
  end

  context 'Resource Public Subnet' do
    let(:tags) { template["Resources"]["SubnetPublic0"]["Properties"]["Tags"] }

    it 'has property Tags' do
      expect(tags).to include({"Key"=>{"Fn::Sub"=>"kubernetes.io/cluster/${EnvironmentName}-cluster"},"Value"=>"shared"})
      expect(tags).to include({"Key"=>"kubernetes.io/role/elb", "Value"=>1})
      expect(tags).to include({"Key"=>{"Fn::Sub"=>"Application"}, "Value"=>{"Fn::Sub"=>"MyApp"}})
      expect(tags).to include({"Key"=>{"Fn::Sub"=>"CreatedBy"}, "Value"=>{"Fn::Sub"=>"theonestack"}})
    end
  end
  
end
