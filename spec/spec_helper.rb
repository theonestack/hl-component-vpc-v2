RSpec.configure do |config|
  config.before(:context) { @validate = ENV['GITHUB_HEAD_REF'] ? '--no-validate' : '--validate' }
end
