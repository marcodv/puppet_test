class netcentric_puppet::forward_proxy_log {
class{"nginx":
    manage_repo => true,
    package_source => 'nginx-mainline',
    log_format => {
      main => 'Request protocol: $scheme | Remote IP: $upstream_addr | Request time: $request_time',
    }
}

  nginx::resource::server{'localhost':
    listen_port => 8000,
    resolver    => ['8.8.8.8'],
    proxy       => 'http://$http_host$uri$is_args$args',
    format_log  => main,
  }

}