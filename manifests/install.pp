# == Class ezproxy::install
#
# This class is called from ezproxy for install.
#
class ezproxy::install {

  $version = $::ezproxy::version
  $download_version = regsubst($version, '\.', '-', 'G')

  group { $::ezproxy::ezproxy_group:
    ensure => present,
    system => true,
  }
  user { $::ezproxy::ezproxy_user:
    ensure  => present,
    system  => true,
    home    => $::ezproxy::install_path,
    shell   => $::ezproxy::ezproxy_shell,
    gid     => $::ezproxy::ezproxy_group,
    require => Group[$::ezproxy::ezproxy_group]
  }

  file { $::ezproxy::install_path:
    ensure  => directory,
    owner   => $::ezproxy::ezproxy_user,
    group   => $::ezproxy::ezproxy_group,
    require => User[$::ezproxy::ezproxy_user]
  }

  exec { 'download ezproxy':
    command => "curl -o ${::ezproxy::install_path}/ezproxy ${::ezproxy::download_url}/${download_version}/ezproxy-linux.bin",
    creates => "${::ezproxy::install_path}/ezproxy",
    path    => '/sbin:/bin:/usr/sbin:/usr/bin',
    require => File[$::ezproxy::install_path]
  }

  file { "${::ezproxy::install_path}/ezproxy":
    ensure  => present,
    mode    => '0755',
    owner   => $::ezproxy::ezproxy_user,
    group   => $::ezproxy::ezproxy_group,
    require => Exec['download ezproxy'],
    notify  => Exec['bootstrap ezproxy']
  }

  $::ezproxy::dependencies.each |$dependency| {
    package { $dependency:
      ensure => installed,
      notify => Exec['bootstrap ezproxy']
    }
  }

  exec { 'bootstrap ezproxy':
    command     => "${::ezproxy::install_path}/ezproxy -mg",
    refreshonly => true,
    returns     => '1',
  }

  if versioncmp($version, '6.0.0') > 0 {
    if $::ezproxy::ws_key {
      exec { 'authorize ezproxy wskey':
        command => "${::ezproxy::install_path}/ezproxy -k ${::ezproxy::ws_key}",
        creates => "${::ezproxy::install_path}/wskey.key",
        require => Exec['bootstrap ezproxy'],
      }
    }
    else {
      fail('EZProxy 6 requires a WS Key for authorization.')
    }
  }
}
