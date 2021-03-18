require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/no_dhcp.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/no_dhcp/vpc-v2.compiled.yaml") }
  let(:resources) { template["Resources"] }
        
  context 'DHCP resource' do

    it 'DHCPOptionSet not created' do
      expect(resources).not_to have_key('DHCPOptionSet')
    end

    it 'DHCPOptionsAssociation not created' do
      expect(resources).not_to have_key('DHCPOptionsAssociation')
    end

  end

end
