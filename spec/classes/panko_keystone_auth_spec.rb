#
# Unit tests for panko::keystone::auth
#

require 'spec_helper'

describe 'panko::keystone::auth' do
  shared_examples_for 'panko-keystone-auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'panko_password',
          :tenant   => 'foobar' }
      end

      it { is_expected.to contain_keystone_user('panko').with(
        :ensure   => 'present',
        :password => 'panko_password',
      ) }

      it { is_expected.to contain_keystone_user_role('panko@foobar').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )}

      it { is_expected.to contain_keystone_service('panko::FIXME').with(
        :ensure      => 'present',
        :description => 'panko FIXME Service'
      ) }

      it { is_expected.to contain_keystone_endpoint('RegionOne/panko::FIXME').with(
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:FIXME',
        :admin_url    => 'http://127.0.0.1:FIXME',
        :internal_url => 'http://127.0.0.1:FIXME',
      ) }
    end

    context 'when overriding URL parameters' do
      let :params do
        { :password     => 'panko_password',
          :public_url   => 'https://10.10.10.10:80',
          :internal_url => 'http://10.10.10.11:81',
          :admin_url    => 'http://10.10.10.12:81', }
      end

      it { is_expected.to contain_keystone_endpoint('RegionOne/panko::FIXME').with(
        :ensure       => 'present',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'http://10.10.10.11:81',
        :admin_url    => 'http://10.10.10.12:81',
      ) }
    end

    context 'when overriding auth name' do
      let :params do
        { :password => 'foo',
          :auth_name => 'pankoy' }
      end

      it { is_expected.to contain_keystone_user('pankoy') }
      it { is_expected.to contain_keystone_user_role('pankoy@services') }
      it { is_expected.to contain_keystone_service('panko::FIXME') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/panko::FIXME') }
    end

    context 'when overriding service name' do
      let :params do
        { :service_name => 'panko_service',
          :auth_name    => 'panko',
          :password     => 'panko_password' }
      end

      it { is_expected.to contain_keystone_user('panko') }
      it { is_expected.to contain_keystone_user_role('panko@services') }
      it { is_expected.to contain_keystone_service('panko_service::FIXME') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/panko_service::FIXME') }
    end

    context 'when disabling user configuration' do

      let :params do
        {
          :password       => 'panko_password',
          :configure_user => false
        }
      end

      it { is_expected.not_to contain_keystone_user('panko') }
      it { is_expected.to contain_keystone_user_role('panko@services') }
      it { is_expected.to contain_keystone_service('panko::FIXME').with(
        :ensure      => 'present',
        :description => 'panko FIXME Service'
      ) }

    end

    context 'when disabling user and user role configuration' do

      let :params do
        {
          :password            => 'panko_password',
          :configure_user      => false,
          :configure_user_role => false
        }
      end

      it { is_expected.not_to contain_keystone_user('panko') }
      it { is_expected.not_to contain_keystone_user_role('panko@services') }
      it { is_expected.to contain_keystone_service('panko::FIXME').with(
        :ensure      => 'present',
        :description => 'panko FIXME Service'
      ) }

    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'panko-keystone-auth'
    end
  end
end
