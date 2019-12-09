require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/create_hosted_zone.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/create_hosted_zone/vpc-v2.compiled.yaml") }
  
  context 'Resources' do
    
    let(:types) { template["Resources"].collect { |key,value| value["Type"] } }
    
    it 'only contains' do
      expect(types).not_to include('AWS::Route53::HostedZone')
    end
    
  end

end
