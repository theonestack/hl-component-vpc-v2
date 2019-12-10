require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/disable_subnet_groups.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/disable_subnet_groups/vpc-v2.compiled.yaml") }
  
  context 'Resources' do
    
    let(:subnets) { template["Resources"].select { |key,value| value["Type"] == 'AWS::EC2::Subnet' }.keys }
    
    it 'only contain public and custom subnets' do
      expect(subnets).to contain_exactly(
        "SubnetPublic0", 
        "SubnetPublic1", 
        "SubnetPublic2", 
        "SubnetCustom0", 
        "SubnetCustom1", 
        "SubnetCustom2")
    end
    
  end

end
