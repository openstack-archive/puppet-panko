#
# Unit tests for panko::expirer
#

require 'spec_helper'

describe 'panko::expirer' do

  shared_examples_for 'panko-expirer' do

    it { is_expected.to contain_class('panko::deps') }
    it { is_expected.to contain_class('panko::params') }

    let :params do
        { }
    end

    it 'configures a cron' do
      is_expected.to contain_cron('panko-expirer').with(
        :ensure      => 'present',
        :command     => 'panko-expirer',
        :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
        :user        => 'panko',
        :minute      => 1,
        :hour        => 0,
        :monthday    => '*',
        :month       => '*',
        :weekday     => '*'
      )
    end

    context 'with cron not enabled' do
      before do
        params.merge!({
          :enable_cron => false })
      end
      it {
        is_expected.to contain_cron('panko-expirer').with(
          :ensure      => 'absent',
          :command     => 'panko-expirer',
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin SHELL=/bin/sh',
          :user        => 'panko',
          :minute      => 1,
          :hour        => 0,
          :monthday    => '*',
          :month       => '*',
          :weekday     => '*'
        )
      }
    end

  end
end
