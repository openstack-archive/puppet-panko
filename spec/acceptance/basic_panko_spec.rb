require 'spec_helper_acceptance'

describe 'basic panko' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
      include ::openstack_integration
      include ::openstack_integration::repos
      include ::openstack_integration::mysql
      include ::openstack_integration::keystone

      class { '::panko::db::mysql':
        password => 'a_big_secret',
      }
      class { '::panko::keystone::auth':
        password => 'a_big_secret',
      }

      case $::osfamily {
        'Debian': {
          warning('Panko is not yet packaged on Ubuntu systems.')
        }
        'RedHat': {
          include ::panko
          class { '::panko::db':
            database_connection => 'mysql+pymysql://panko:a_big_secret@127.0.0.1/panko?charset=utf8',
          }
          class { '::panko::keystone::authtoken':
            password => 'a_big_secret',
          }
          class { '::panko::api':
            enabled      => true,
            service_name => 'httpd',
            sync_db      => true,
          }
          include ::apache
          class { '::panko::wsgi::apache':
            ssl => false,
          }
        }
        default: {
          fail("Unsupported osfamily (${::osfamily})")
        }
      }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if os[:family].casecmp('RedHat') == 0
      describe port(8779) do
        it { is_expected.to be_listening }
      end
    end

  end
end
