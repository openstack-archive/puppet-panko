require 'spec_helper'

describe 'panko::db' do

  shared_examples 'panko::db' do
    context 'with default parameters' do
      it { is_expected.to contain_panko_config('database/connection').with_value('sqlite:////var/lib/panko/panko.sqlite') }
      it { is_expected.to contain_panko_config('database/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_panko_config('database/min_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_panko_config('database/max_retries').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_panko_config('database/retry_interval').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_panko_config('database/max_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_panko_config('database/max_overflow').with_value('<SERVICE DEFAULT>') }
    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://panko:panko@localhost/panko',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_max_pool_size  => '11',
          :database_max_overflow   => '21',
        }
      end

      it { is_expected.to contain_panko_config('database/connection').with_value('mysql+pymysql://panko:panko@localhost/panko') }
      it { is_expected.to contain_panko_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_panko_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_panko_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_panko_config('database/retry_interval').with_value('11') }
      it { is_expected.to contain_panko_config('database/max_pool_size').with_value('11') }
      it { is_expected.to contain_panko_config('database/max_overflow').with_value('21') }
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://panko:panko@localhost/panko', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection     => 'mysql://panko:panko@localhost/panko', }
      end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'foodb://panko:panko@localhost/panko', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection     => 'foo+pymysql://panko:panko@localhost/panko', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  shared_examples_for 'panko::db on Debian' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://panko:panko@localhost/panko', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('db_backend_package').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => 'openstack'
        )
      end
    end
  end

  shared_examples_for 'panko::db on RedHat' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://panko:panko@localhost/panko', }
      end

      it 'install the proper backend package' do
        is_expected.not_to contain_package('db_backend_package')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'panko::db'
      it_configures "panko::db on #{facts[:osfamily]}"
    end
  end
end
