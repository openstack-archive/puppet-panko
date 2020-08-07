require 'spec_helper_acceptance'

describe 'basic panko' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include openstack_integration
      include openstack_integration::repos
      include openstack_integration::apache
      include openstack_integration::mysql
      include openstack_integration::keystone
      include openstack_integration::panko
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe port(8977) do
        it { is_expected.to be_listening }
      end
    end

  end
end
