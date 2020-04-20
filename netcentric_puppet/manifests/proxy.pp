class netcentric_puppet::proxy {
class{"nginx":
    manage_repo => true,
    package_source => 'nginx-mainline'
}

  nginx::resource::server{'domain.com':
    listen_port => 80,
    proxy       => 'http://10.10.10.10:80'
  }

  nginx::resource::location{'/resource':
    proxy => 'http://20.20.20.20:80/' ,
    server => 'domain.com',
  }
}
