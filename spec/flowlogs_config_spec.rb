require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/flowlogs_config.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/flowlogs_config/vpc-v2.compiled.yaml") }

  context 'Resource FlowLogsLogGroup' do

    let(:properties) { template["Resources"]["FlowLogsLogGroup"]["Properties"] }

    it 'has property RetentionInDays' do
      expect(properties["RetentionInDays"]).to eq("14")
    end

  end

  context 'Resource VPCFlowLogs' do

    let(:properties) { template["Resources"]["VPCFlowLogs"]["Properties"] }

    it 'has property TrafficType' do
      expect(properties["TrafficType"]).to eq("ACCEPT")
    end

  end

end
