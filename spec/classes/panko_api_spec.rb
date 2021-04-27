require 'spec_helper'

describe 'panko::api' do

  let :pre_condition do
    "include apache
     class { 'panko': }
     include panko::db
     class {'panko::keystone::authtoken':
       password => 'password',
     }"
  end

  let :params do
    { :enabled            => true,
      :manage_service     => true,
      :package_ensure     => 'latest',
      :max_retries        => '10',
      :retry_interval     => '20',
      :es_ssl_enabled     => true,
      :es_index_name      => 'panko',
      :event_time_to_live => '3600',
    }
  end

  shared_examples_for 'panko-api' do

    it { is_expected.to contain_class('panko::deps') }
    it { is_expected.to contain_class('panko::params') }
    it { is_expected.to contain_class('panko::policy') }

    it 'installs panko-api package' do
      is_expected.to contain_package('panko-api').with(
        :ensure => 'latest',
        :name   => platform_params[:api_package_name],
        :tag    => ['openstack', 'panko-package'],
      )
    end

    it 'configures keystone authentication middleware' do
      is_expected.to contain_panko_config('storage/max_retries').with_value(params[:max_retries])
      is_expected.to contain_panko_config('storage/retry_interval').with_value(params[:retry_interval])
      is_expected.to contain_panko_config('storage/es_ssl_enabled').with_value(params[:es_ssl_enabled])
      is_expected.to contain_panko_config('storage/es_index_name').with_value(params[:es_index_name])
      is_expected.to contain_oslo__middleware('panko_config').with(
        :enable_proxy_headers_parsing => '<SERVICE DEFAULT>',
        :max_request_body_size        => '<SERVICE DEFAULT>',
      )
      is_expected.to contain_panko_config('database/event_time_to_live').with_value( params[:event_time_to_live] )
    end

    context 'with sync_db set to true' do
      before do
        params.merge!({
          :sync_db => true})
      end
      it { is_expected.to contain_class('panko::db::sync') }
    end

    context 'with enable_proxy_headers_parsing' do
      before do
        params.merge!({:enable_proxy_headers_parsing => true })
      end

      it { is_expected.to contain_oslo__middleware('panko_config').with(
        :enable_proxy_headers_parsing => true,
      )}
    end

    context 'with max_request_body_size' do
      before do
        params.merge!({:max_request_body_size => '102400' })
      end

      it { is_expected.to contain_oslo__middleware('panko_config').with(
        :max_request_body_size => '102400',
      )}
    end

    context 'when service_name is not valid' do
      before do
        params.merge!({ :service_name   => 'foobar' })
      end

      let :pre_condition do
        "include apache
         include panko::db
         class { 'panko': }"
      end

      it_raises 'a Puppet::Error', /Invalid service_name/
    end

    context "with noauth" do
      before do
        params.merge!({
          :auth_strategy => 'noauth',
        })
      end
      it 'configures pipeline' do
        is_expected.to contain_panko_api_paste_ini('pipeline:main/pipeline').with_value('panko+noauth');
      end
    end

    context "with keystone" do
      before do
        params.merge!({
          :auth_strategy => 'keystone',
        })
      end
      it 'configures pipeline' do
        is_expected.to contain_panko_api_paste_ini('pipeline:main/pipeline').with_value('panko+auth');
      end
    end
  end


  shared_examples_for 'panko-api without standalone service' do

    let :pre_condition do
      "include apache
       include panko::db
       class { 'panko': }
       class {'panko::keystone::authtoken':
         password => 'password',
       }"
    end

    it { is_expected.to_not contain_service('panko-api') }
  end


  shared_examples_for 'panko-api with standalone service' do

    [{:enabled => true}, {:enabled => false}].each do |param_hash|
      context "when service should be #{param_hash[:enabled] ? 'enabled' : 'disabled'}" do
        before do
          params.merge!(param_hash)
        end

        it 'configures panko-api service' do
          is_expected.to contain_service('panko-api').with(
            :ensure     => (params[:manage_service] && params[:enabled]) ? 'running' : 'stopped',
            :name       => platform_params[:api_service_name],
            :enable     => params[:enabled],
            :hasstatus  => true,
            :hasrestart => true,
            :tag        => ['panko-service', 'panko-db-sync-service'],
          )
        end
        it { is_expected.to contain_service('panko-api').that_subscribes_to('Anchor[panko::service::begin]')}
        it { is_expected.to contain_service('panko-api').that_notifies('Anchor[panko::service::end]')}
      end
    end

    context 'with disabled service managing' do
      before do
        params.merge!({
          :manage_service => false,
          :enabled        => false })
      end

      it 'configures panko-api service' do
        is_expected.to contain_service('panko-api').with(
          :ensure     => nil,
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :hasstatus  => true,
          :hasrestart => true,
          :tag        => ['panko-service', 'panko-db-sync-service'],
        )
      end
    end

    context 'when running panko-api in wsgi' do
      before do
        params.merge!({ :service_name   => 'httpd' })
      end

      let :pre_condition do
        "include apache
         include panko::db
         class { 'panko': }
         class {'panko::keystone::authtoken':
           password => 'password',
         }"
      end

      it 'configures panko-api service with Apache' do
        is_expected.to contain_service('panko-api').with(
          :ensure     => 'stopped',
          :name       => platform_params[:api_service_name],
          :enable     => false,
          :tag        => ['panko-service', 'panko-db-sync-service'],
        )
      end
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :concat_basedir => '/var/lib/puppet/concat',
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          if facts[:operatingsystem] == 'Ubuntu'
            { :api_package_name => 'panko-api' }
          else
            { :api_package_name => 'panko-api',
              :api_service_name => 'panko-api' }
          end
        when 'RedHat'
          { :api_package_name => 'openstack-panko-api' }
        end
      end

      if facts[:osfamily] == 'Debian' and facts[:operatingsystem] != 'Ubuntu'
        it_behaves_like 'panko-api with standalone service'
      else
        it_behaves_like 'panko-api without standalone service'
      end
      it_behaves_like 'panko-api'
    end
  end

end
