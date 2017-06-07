require 'spec_helper'

describe 'panko::wsgi::apache' do

  shared_examples_for 'apache serving panko with mod_wsgi' do
    it { is_expected.to contain_service('httpd').with_name(platform_params[:httpd_service_name]) }
    it { is_expected.to contain_class('panko::params') }
    it { is_expected.to contain_class('apache') }
    it { is_expected.to contain_class('apache::mod::wsgi') }

    describe 'with default parameters' do

      it { is_expected.to contain_file("#{platform_params[:wsgi_script_path]}").with(
        'ensure'  => 'directory',
        'owner'   => 'panko',
        'group'   => 'panko',
        'require' => 'Package[httpd]'
      )}


      it { is_expected.to contain_file('panko_wsgi').with(
        'ensure'  => 'file',
        'path'    => "#{platform_params[:wsgi_script_path]}/app",
        'source'  => platform_params[:wsgi_script_source],
        'owner'   => 'panko',
        'group'   => 'panko',
        'mode'    => '0644'
      )}
      it { is_expected.to contain_file('panko_wsgi').that_requires("File[#{platform_params[:wsgi_script_path]}]") }

      it { is_expected.to contain_apache__vhost('panko_wsgi').with(
        'servername'                  => 'some.host.tld',
        'ip'                          => nil,
        'port'                        => '8977',
        'docroot'                     => "#{platform_params[:wsgi_script_path]}",
        'docroot_owner'               => 'panko',
        'docroot_group'               => 'panko',
        'ssl'                         => 'true',
        'wsgi_daemon_process'         => 'panko',
        'wsgi_daemon_process_options' => {
          'user'         => 'panko',
          'group'        => 'panko',
          'processes'    => 1,
          'threads'      => '4',
          'display-name' => 'panko_wsgi',
        },
        'wsgi_process_group'          => 'panko',
        'wsgi_script_aliases'         => { '/' => "#{platform_params[:wsgi_script_path]}/app" },
        'require'                     => 'File[panko_wsgi]'
      )}
      it { is_expected.to contain_concat("#{platform_params[:httpd_ports_file]}") }
    end

    describe 'when overriding parameters using different ports' do
      let :params do
        {
          :servername                => 'dummy.host',
          :bind_host                 => '10.42.51.1',
          :port                      => 12345,
          :ssl                       => false,
          :wsgi_process_display_name => 'panko',
          :workers                   => 8,
        }
      end

      it { is_expected.to contain_apache__vhost('panko_wsgi').with(
        'servername'                  => 'dummy.host',
        'ip'                          => '10.42.51.1',
        'port'                        => '12345',
        'docroot'                     => "#{platform_params[:wsgi_script_path]}",
        'docroot_owner'               => 'panko',
        'docroot_group'               => 'panko',
        'ssl'                         => 'false',
        'wsgi_daemon_process'         => 'panko',
        'wsgi_daemon_process_options' => {
            'user'         => 'panko',
            'group'        => 'panko',
            'processes'    => '8',
            'threads'      => '4',
            'display-name' => 'panko',
        },
        'wsgi_process_group'          => 'panko',
        'wsgi_script_aliases'         => { '/' => "#{platform_params[:wsgi_script_path]}/app" },
        'require'                     => 'File[panko_wsgi]'
      )}

      it { is_expected.to contain_concat("#{platform_params[:httpd_ports_file]}") }
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers     => 4,
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'some.host.tld',
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :httpd_service_name => 'apache2',
            :httpd_ports_file   => '/etc/apache2/ports.conf',
            :wsgi_script_path   => '/usr/lib/cgi-bin/panko',
            :wsgi_script_source => '/usr/share/panko-common/app.wsgi'
          }
        when 'RedHat'
          {
            :httpd_service_name => 'httpd',
            :httpd_ports_file   => '/etc/httpd/conf/ports.conf',
            :wsgi_script_path   => '/var/www/cgi-bin/panko',
            :wsgi_script_source => '/usr/lib/python2.7/site-packages/panko/api/app.wsgi'
          }
        end
      end

      it_behaves_like 'apache serving panko with mod_wsgi'
    end
  end
end
