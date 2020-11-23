require 'spec_helper'

describe 'panko::db::sync' do

  shared_examples_for 'panko-dbsync' do

    it { is_expected.to contain_class('panko::deps') }

    it 'runs panko-db-sync' do
      is_expected.to contain_exec('panko-db-sync').with(
        :command     => 'panko-dbsync --config-file /etc/panko/panko.conf ',
        :path        => '/usr/bin',
        :refreshonly => 'true',
        :user        => 'panko',
        :try_sleep   => 5,
        :tries       => 10,
        :timeout     => 300,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[panko::install::end]',
                         'Anchor[panko::config::end]',
                         'Anchor[panko::dbsync::begin]'],
        :notify      => 'Anchor[panko::dbsync::end]',
        :tag         => 'openstack-db',
      )
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :os_workers     => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'panko-dbsync'
    end
  end

end
