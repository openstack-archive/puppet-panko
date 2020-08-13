require 'spec_helper'

describe 'panko::expirer' do
  shared_examples 'panko::expirer' do
    let :params do
      {}
    end

    context 'with default' do
      it { is_expected.to contain_class('panko::deps') }
      it { is_expected.to contain_class('panko::params') }

      it { is_expected.to contain_cron('panko-expirer').with(
        :ensure      => 'present',
        :command     => 'panko-expirer',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'panko',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[panko::install::end]'
      )}
    end

    context 'with overridden parameters' do
      before do
        params.merge!( :maxdelay => 300 )
      end

      it { is_expected.to contain_class('panko::deps') }
      it { is_expected.to contain_class('panko::params') }

      it { is_expected.to contain_cron('panko-expirer').with(
        :ensure      => 'present',
        :command     => 'sleep `expr ${RANDOM} \\% 300`; panko-expirer',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'panko',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[panko::install::end]'
      )}
    end

    context 'with cron not enabled' do
      before do
        params.merge!( :enable_cron => false )
      end

      it { is_expected.to contain_cron('panko-expirer').with(
        :ensure      => 'absent',
        :command     => 'panko-expirer',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'panko',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*',
        :require     => 'Anchor[panko::install::end]'
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'panko::expirer'
    end
  end
end
