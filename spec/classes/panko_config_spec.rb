require 'spec_helper'

describe 'panko::config' do

  let :params do
    { :panko_config => {
        'DEFAULT/foo' => { 'value'  => 'fooValue' },
        'DEFAULT/bar' => { 'value'  => 'barValue' },
        'DEFAULT/baz' => { 'ensure' => 'absent' }
      },
      :panko_api_paste_ini => {
        'DEFAULT/foo2' => { 'value'  => 'fooValue' },
        'DEFAULT/bar2' => { 'value'  => 'barValue' },
        'DEFAULT/baz2' => { 'ensure' => 'absent' }
      }
    }
  end

  shared_examples_for 'panko-config' do
    it { is_expected.to contain_class('panko::deps') }

    it 'configures arbitrary panko configurations' do
      is_expected.to contain_panko_config('DEFAULT/foo').with_value('fooValue')
      is_expected.to contain_panko_config('DEFAULT/bar').with_value('barValue')
      is_expected.to contain_panko_config('DEFAULT/baz').with_ensure('absent')
    end

    it 'configures arbitrary panko-api-paste configurations' do
      is_expected.to contain_panko_api_paste_ini('DEFAULT/foo2').with_value('fooValue')
      is_expected.to contain_panko_api_paste_ini('DEFAULT/bar2').with_value('barValue')
      is_expected.to contain_panko_api_paste_ini('DEFAULT/baz2').with_ensure('absent')
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'panko-config'
    end
  end
end

