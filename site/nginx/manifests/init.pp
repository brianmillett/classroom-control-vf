class nginx {

  case $::osfamily {
    'redhat','debian' : {
                          $package = 'nginx'
                          $owner = 'root'
                          $group = 'root'
                          $docroot = '/var/www'
                          $confdir = '/etc/nginx'
                          $blockdir = "${confdir}/conf.d"
                          $logdir = '/var/log/nginx'
                        }
    'windows' : {
                  $package = 'nginx-service'
                  $owner = 'Administrator'
                  $group = 'Administrators'
                  $docroot = 'C:/ProgramData/nginx/html'
                  $confdir = 'C:/ProgramData/nginx'
                  $blockdir = "${confdir}/conf.d"
                  $logdir = 'C:/ProgramData/nginx/logs'
                }
   default : {
                fail("Module ${module_name} is not supported on ${::osfamily}")
              }
  }
  
  # user the service will run as. Used in the nginx.conf.erb template
  $user = $::osfamily ? {
                          'redhat' => 'nginx',
                          'debian' => 'www-data',
                          'windows' => 'nobody',
                        }
                        
  package { $package:
    ensure => present,
  }
  
  File { 
    owner => $owner,
    group => $group,
    mode => '0664',
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
    require => Package['nginx'],
    notify => Service['nginx'],
  }

  file { $blockdir:
    ensure => directory,
   }

  file { "${blockdir}/default.conf":
    ensure => file,
    source => 'puppet:///modules/nginx/default.conf',
    require => Package['nginx'],
    notify => Service['nginx'],
  }
  
  service { 'nginx':
    ensure => running,
    enable => true,
  }
}
