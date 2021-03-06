class nginx (
  $package = $nginx::params::package,
  $owner = $nginx::params::owner,
  $group = $nginx::params::group,
  $docroot,
  $confdir = $nginx::params::confdir,
  $blockdir = $nginx::params::blockdir,
  $logdir = $nginx::params::logdir,
  $user = $nginx::params::user,
) inherits nginx::params {
  
  File { 
    owner => $owner,
    group => $group,
    mode => '0664',
  }
  
  package { $package:
    ensure => present,
  }
  
  file { $docroot:
    ensure => directory,
  }
  
  file { "${docroot}/index.html":
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
  }

  file { "${confdir}/nginx.conf":
    ensure => file,
    source => 'puppet:///modules/nginx/nginx.conf',
    notify => Service['nginx'],
  }

  file { $blockdir:
    ensure => directory,
   }

  file { "${blockdir}/default.conf":
    ensure => file,
    source => 'puppet:///modules/nginx/default.conf',
    notify => Service['nginx'],
  }
  
  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
