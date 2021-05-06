require 'yaml'

describe 'compiled component' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/az_mapping.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/az_mapping/vpc-v2.compiled.yaml") }
  
  context 'Resource SubnetPublic0' do

    let(:properties) { template["Resources"]["SubnetPublic0"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Select" => [0, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[{"Fn::Select"=>[0, {"Fn::Split"=>[",", {"Fn::FindInMap"=>["Accounts", {"Ref"=> "AWS::AccountId"}, "AZs"]}]}]}, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to include({"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[{"Fn::Select"=>[0, {"Fn::Split"=>[",", {"Fn::FindInMap"=>["Accounts", {"Ref"=> "AWS::AccountId"}, "AZs"]}]}]}, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}})
      expect(properties["Tags"]).to include({"Key"=>"Type", "Value"=>"public"})
      expect(properties["Tags"]).to include({"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}})
      expect(properties["Tags"]).to include({"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}})
    end

  end

  context 'Resource SubnetPublic1' do

    let(:properties) { template["Resources"]["SubnetPublic1"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Select" => [1, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[{"Fn::Select"=>[1, {"Fn::Split"=>[",", {"Fn::FindInMap"=>["Accounts", {"Ref"=> "AWS::AccountId"}, "AZs"]}]}]}, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to include({"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[{"Fn::Select"=>[1, {"Fn::Split"=>[",", {"Fn::FindInMap"=>["Accounts", {"Ref"=> "AWS::AccountId"}, "AZs"]}]}]}, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}})
      expect(properties["Tags"]).to include({"Key"=>"Type", "Value"=>"public"})
      expect(properties["Tags"]).to include({"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}})
      expect(properties["Tags"]).to include({"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}})
    end

  end

  context 'Resource SubnetPublic2' do

    let(:properties) { template["Resources"]["SubnetPublic2"]["Properties"] }

    it 'has property VpcId' do
      expect(properties["VpcId"]).to eq({"Ref"=>"VPC"})
    end

    it 'has property CidrBlock' do
      expect(properties["CidrBlock"]).to eq({"Fn::Select" => [2, {"Fn::Cidr"=>[{"Ref"=>"CIDR"}, 16, {"Ref"=>"SubnetBits"}]}]})
    end

    it 'has property AvailabilityZone' do
      expect(properties["AvailabilityZone"]).to eq({"Fn::Select"=>[{"Fn::Select"=>[2, {"Fn::Split"=>[",", {"Fn::FindInMap"=>["Accounts", {"Ref"=> "AWS::AccountId"}, "AZs"]}]}]}, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]})
    end

    it 'has property Tags' do
      expect(properties["Tags"]).to include({"Key"=>"Name", "Value"=>{"Fn::Sub"=>["${EnvironmentName}-public-${AZ}", {"AZ"=>{"Fn::Select"=>[{"Fn::Select"=>[2, {"Fn::Split"=>[",", {"Fn::FindInMap"=>["Accounts", {"Ref"=> "AWS::AccountId"}, "AZs"]}]}]}, {"Fn::GetAZs"=>{"Ref"=>"AWS::Region"}}]}}]}})
      expect(properties["Tags"]).to include({"Key"=>"Type", "Value"=>"public"})
      expect(properties["Tags"]).to include({"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}})
      expect(properties["Tags"]).to include({"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}})
    end

  end

end

