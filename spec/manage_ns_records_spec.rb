require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/manage_ns_records.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/manage_ns_records/vpc-v2.compiled.yaml") }

  context 'Resource HostedZone' do

    let(:properties) { template["Resources"]["HostedZone"]["Properties"] }

    it 'has property Name' do
      expect(properties["Name"]).to eq({"Fn::Join"=>[".", [{"Ref"=>"EnvironmentName"}, {"Fn::Sub"=>"${DnsDomain}."}]]})
    end

    it 'has property HostedZoneConfig' do
      expect(properties["HostedZoneConfig"]).to eq({"Comment"=>{"Fn::Sub"=>"Hosted Zone for ${EnvironmentName}"}})
    end

    it 'has property HostedZoneTags' do
      expect(properties["HostedZoneTags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
    end

  end

  context 'Resource DomainNameZoneNSRecords' do

    let(:properties) { template["Resources"]["DomainNameZoneNSRecords"]["Properties"] }

    it 'has property ServiceToken' do
      expect(properties["ServiceToken"]).to eq({"Fn::GetAtt"=>["Route53ZoneCR", "Arn"]})
    end

    it 'has property AwsRegion' do
      expect(properties["AwsRegion"]).to eq({"Ref"=>"AWS::Region"})
    end

    it 'has property RootDomainName' do
      expect(properties["RootDomainName"]).to eq({"Fn::Sub"=>"${DnsDomain}."})
    end

    it 'has property DomainName' do
      expect(properties["DomainName"]).to eq({"Fn::Join"=>[".", [{"Ref"=>"EnvironmentName"}, {"Fn::Sub"=>"${DnsDomain}."}]]})
    end

    it 'has property NSRecords' do
      expect(properties["NSRecords"]).to eq({"Fn::GetAtt"=>["HostedZone", "NameServers"]})
    end

    it 'has property ParentIAMRole' do
      expect(properties["ParentIAMRole"]).to eq({"Ref"=>"dnszoneParentIAMRole"})
    end

  end

  context 'Resource NSRecords' do

    let(:properties) { template["Resources"]["NSRecords"]["Properties"] }

    it 'has property HostedZoneName' do
      expect(properties["HostedZoneName"]).to eq({"Fn::Sub"=>"${DnsDomain}."})
    end

    it 'has property Comment' do
      expect(properties["Comment"]).to eq({"Fn::Join"=>["", [{"Fn::Sub"=>"${EnvironmentName} - NS Records for ${EnvironmentName}."}, {"Fn::Sub"=>"${DnsDomain}."}]]})
    end

    it 'has property Name' do
      expect(properties["Name"]).to eq({"Fn::Join"=>[".", [{"Ref"=>"EnvironmentName"}, {"Fn::Sub"=>"${DnsDomain}."}]]})
    end

    it 'has property Type' do
      expect(properties["Type"]).to eq("NS")
    end

    it 'has property TTL' do
      expect(properties["TTL"]).to eq(60)
    end

    it 'has property ResourceRecords' do
      expect(properties["ResourceRecords"]).to eq({"Fn::GetAtt"=>["HostedZone", "NameServers"]})
    end

  end

  context 'Resource LambdaRoleRoute53ZoneResource' do

    let(:properties) { template["Resources"]["LambdaRoleRoute53ZoneResource"]["Properties"] }

    it 'has property AssumeRolePolicyDocument' do
      expect(properties["AssumeRolePolicyDocument"]).to eq({"Version"=>"2012-10-17", "Statement"=>[{"Effect"=>"Allow", "Principal"=>{"Service"=>"lambda.amazonaws.com"}, "Action"=>"sts:AssumeRole"}]})
    end

    it 'has property Path' do
      expect(properties["Path"]).to eq("/")
    end

    it 'has property Policies' do
      expect(properties["Policies"]).to eq([{"PolicyName"=>"cloudwatch-logs", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams", "logs:DescribeLogGroups"], "Resource"=>["arn:aws:logs:*:*:*"]}]}}, {"PolicyName"=>"route53", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["route53:*"], "Resource"=>"*"}]}}, {"PolicyName"=>"opsdns", "PolicyDocument"=>{"Statement"=>[{"Effect"=>"Allow", "Action"=>["sts:AssumeRole"], "Resource"=>[{"Fn::If"=>["RemoteNSRecords", {"Ref"=>"dnszoneParentIAMRole"}, "arn:aws:iam::123456789012:user/noaccess"]}]}]}}])
    end

  end

  context 'Resource Route53ZoneCR' do

    let(:properties) { template["Resources"]["Route53ZoneCR"]["Properties"] }

    it 'has property Code' do
      expect(properties["Code"]).to include("S3Key" => a_kind_of(String))
      expect(properties["Code"]).to include("S3Bucket" => a_kind_of(String))
    end

    it 'has property Environment' do
      expect(properties["Environment"]).to eq({"Variables"=>{"ENVIRONMENT_NAME"=>{"Ref"=>"EnvironmentName"}}})
    end

    it 'has property Handler' do
      expect(properties["Handler"]).to eq("route53_zone_cr.handler")
    end

    it 'has property MemorySize' do
      expect(properties["MemorySize"]).to eq(128)
    end

    it 'has property Role' do
      expect(properties["Role"]).to eq({"Fn::GetAtt"=>["LambdaRoleRoute53ZoneResource", "Arn"]})
    end

    it 'has property Runtime' do
      expect(properties["Runtime"]).to eq("python3.11")
    end

    it 'has property Timeout' do
      expect(properties["Timeout"]).to eq(600)
    end

  end

  context 'Resource Route53ZoneCRVersion' do
    
    let(:resource) { template["Resources"].select {|r| r.start_with?("Route53ZoneCRVersion") }.keys.first }
    let(:properties) { template["Resources"][resource]["Properties"] }

    it 'has property FunctionName' do
      expect(properties["FunctionName"]).to eq({"Ref"=>"Route53ZoneCR"})
    end

    it 'has property CodeSha256' do
      expect(properties["CodeSha256"]).to a_kind_of(String)
    end

  end

end
