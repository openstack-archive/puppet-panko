class { '::panko': }
class { '::panko::keystone::authtoken':
  password => 'a_big_secret',
}
class { '::panko::api':
  enabled      => true,
  service_name => 'httpd',
}
include ::apache
class { '::panko::wsgi::apache':
  ssl => false,
}
class { '::panko::auth':
  auth_password => 'a_big_secret',
}

