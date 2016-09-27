require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'

require 'rspec-puppet-facts'
require 'puppet-openstack_spec_helper/defaults'
include RspecPuppetFacts

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'
end

at_exit { RSpec::Puppet::Coverage.report! }
