require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/flowlogs.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/flowlogs/vpc-v2.compiled.yaml") }

  context 'Resource FlowLogsLogGroup' do

    let(:properties) { template["Resources"]["FlowLogsLogGroup"]["Properties"] }

    it 'has property LogGroupName' do
      expect(properties["LogGroupName"]).to eq({"Fn::Sub"=>"${EnvironmentName}-vpc-flowlogs"})
    end

    it 'has property RetentionInDays' do
      expect(properties["RetentionInDays"]).to eq("7")
    end

  end

  context 'Resource PutVPCFlowLogsRole' do

    let(:properties) { template["Resources"]["PutVPCFlowLogsRole"]["Properties"] }

    it 'has property AssumeRolePolicyDocument' do
      expect(properties["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"vpc-flow-logs.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
    end

    it 'has property Path' do
      expect(properties["Path"]).to eq("/")
    end

    it 'has property Policies' do
      expect(properties["Policies"]).to eq([{"PolicyName"=>"PutVPCFlowLogsRole", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"], "Resource"=>"*"}]}}])
    end

  end

  context 'Resource VPCFlowLogs' do

    let(:properties) { template["Resources"]["VPCFlowLogs"]["Properties"] }

    it 'has property DeliverLogsPermissionArn' do
      expect(properties["DeliverLogsPermissionArn"]).to eq({"Fn::GetAtt"=>["PutVPCFlowLogsRole", "Arn"]})
    end

    it 'has property LogGroupName' do
      expect(properties["LogGroupName"]).to eq({"Ref"=>"FlowLogsLogGroup"})
    end

    it 'has property ResourceId' do
      expect(properties["ResourceId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property ResourceType' do
      expect(properties["ResourceType"]).to eq("VPC")
    end

    it 'has property TrafficType' do
      expect(properties["TrafficType"]).to eq("ALL")
    end

  end

end
