require 'spec_helper'

describe 'panko::client' do

  shared_examples_for 'panko client' do

    it { is_expected.to contain_class('panko::deps') }
    it { is_expected.to contain_class('panko::params') }

    it 'installs panko client package' do
      is_expected.to contain_package('python-pankoclient').with(
        :ensure => 'present',
        :name   => platform_params[:client_package_name],
        :tag    => 'openstack',
      )
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let :platform_params do
        { :client_package_name => 'python-pankoclient' }
      end

      it_behaves_like 'panko client'
    end
  end

end
