# ezproxy::config
#
# This class is called from ezproxy for service config.
#
class ezproxy::config {
  # Set resource defaults
  File {
    owner   => $::ezproxy::user,
    group   => $::ezproxy::group,
  }

  file { "${::ezproxy::install_dir}/user.txt":
    ensure  => file,
    content => template('ezproxy/user.txt.erb')
  }

  file { "${::ezproxy::install_dir}/config.txt":
    ensure  => file,
    content => template('ezproxy/config.txt.erb')
  }

  file { "${::ezproxy::install_dir}/ezproxy.rnd":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/license.txt":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/messages.txt":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/mimetype":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs":
    ensure  => directory,
  }
  file { "${::ezproxy::install_dir}/docs/cookie.htm":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs/login.htm":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs/loginbu.htm":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs/logout.htm":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs/logup.htm":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs/menu.htm":
    ensure  => file,
  }
  file { "${::ezproxy::install_dir}/docs/https.htm":
    ensure  => file,
  }

  concat { 'ezproxy groups':
    ensure => present,
    path   => "${::ezproxy::install_dir}/groups.txt",
    owner  => $::ezproxy::user,
    group  => $::ezproxy::group,
  }

  ezproxy::group { 'default':
    auto_login_ips => $::ezproxy::auto_login_ips,
    include_ips    => $::ezproxy::include_ips,
    exclude_ips    => $::ezproxy::exclude_ips,
    reject_ips     => $::ezproxy::reject_ips,
    group_order    => '999999',
  }

  if $::ezproxy::ssl {
    file { "${::ezproxy::install_dir}/ssl":
      ensure => directory,
      owner  => $::ezproxy::user,
      group  => $::ezproxy::group,
      mode    => '0700',
    }
    file { "${::ezproxy::install_dir}/ssl/00000001.key":
      ensure  => present,
      content => ${::ezproxy::ssl_key},
      owner   => $::ezproxy::user,
      group   => $::ezproxy::group,
      mode    => '0600',
    }
    file { "${::ezproxy::install_dir}/ssl/00000001.crt":
      ensure  => present,
      content => ${::ezproxy::ssl_crt},
      owner   => $::ezproxy::user,
      group   => $::ezproxy::group,
      mode    => '0600',
    }
    file { "${::ezproxy::install_dir}/ssl/00000001.ca":
      ensure  => present,
      content => ${::ezproxy::ssl_ca},
      owner   => $::ezproxy::user,
      group   => $::ezproxy::group,
      mode    => '0600',
    }
    file { "${::ezproxy::install_dir}/ssl/00000001.cnf":
      ensure  => present,
      content => "### MANAGED BY PUPPET ###",
      owner   => $::ezproxy::user,
      group   => $::ezproxy::group,
      mode    => '0600',
    }
    file { "${::ezproxy::install_dir}/ssl/active":
      ensure  => present,
      content => "1",
      owner   => $::ezproxy::user,
      group   => $::ezproxy::group,
      mode    => '0600',
    }
  } else {
    file { "${::ezproxy::install_dir}/ssl":
      ensure => absent,
    }
  }

  if $::ezproxy::default_stanzas {
    ezproxy::stanza { 'Worldcat.org':
      urls      => [ 'http://worldcat.org' ],
      domain_js => [ 'worldcat.org' ],
      order     => '1',
      group     => 'default',
    }
    ezproxy::stanza { 'WhatIsMyIP':
      urls      => [ 'http://whatismyip.com' ],
      domain_js => [ 'whatismyip.com' ],
      order     => '1',
      group     => 'default',
    }
    ezproxy::stanza { 'DOI System':
      urls    => [ 'http://dx.doi.org' ],
      domains => [ 'doi.org' ],
      order   => '1',
      group   => 'default',
      hide    => true,
    }
  }

  $::ezproxy::groups.each |$group, $params| {
    ::ezproxy::group { $group:
      auto_login_ips => $params['auto_login_ips'],
      include_ips    => $params['include_ips'],
      exclude_ips    => $params['exclude_ips'],
      reject_ips     => $params['reject_ips'],
      group_order    => $params['group_order'],
    }
  }

  $::ezproxy::stanzas.each |$stanza, $params| {
    ::ezproxy::stanza { $stanza:
      hide      => $params['hide'],
      hide_flag => $params['hide_flag'],
      urls      => $params['urls'],
      hosts     => $params['hosts'],
      domains   => $params['domains'],
      domain_js => $params['domain_js'],
      host_js   => $params['host_js'],
      prepends  => $params['prepends'],
      appends   => $params['appends'],
      order     => $params['order'],
      group     => $params['group'],
    }
  }

  $::ezproxy::remote_configs.each |$remote_config, $params| {
    ::ezproxy::remote_config { $remote_config:
      download_link => $params['download_link'],
      file_name     => $params['file_name'],
      order         => $params['order'],
      group         => $params['group'],
    }
  }
}
