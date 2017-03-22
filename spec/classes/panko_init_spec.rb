require 'spec_helper'

describe 'panko' do

  shared_examples 'panko' do

    it { is_expected.to contain_class('panko::deps') }
    it { is_expected.to contain_class('panko::logging') }

    context 'with default parameters' do
      let :params do
        { :purge_config => false  }
      end

      it 'installs packages' do
        is_expected.to contain_package('panko').with(
          :name   => platform_params[:panko_common_package],
          :ensure => 'present',
          :tag    => ['openstack', 'panko-package']
        )
      end

      it 'passes purge to resource' do
        is_expected.to contain_resources('panko_config').with({
          :purge => false
        })
      end
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :panko_common_package => 'panko-common' }
        when 'RedHat'
          { :panko_common_package => 'openstack-panko-common' }
        end
      end
      it_behaves_like 'panko'
    end
  end

end
