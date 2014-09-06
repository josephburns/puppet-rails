class rails {

  include rvm
  include stdlib

  rvm_system_ruby {
    'ruby-2.1.2':
      ensure      => 'present',
      default_use => true,
      build_opts  => ['--binary'];
  }
  
  rvm::system_user { rails: ; }

  /* app user for rails */
  group { "webdev":
    ensure => present,
  }
  user { "rails":
    ensure     => present,
    gid        => "webdev",
    groups     => ["webdev"],
    membership => minimum,
    shell      => "/bin/bash",
    require    => Group["webdev"]
  }

  file {"/srv":
    owner => 'rails',
    group => 'webdev',
    recurse => true,
    require => [Group["webdev"], User["rails"]]
  }

  file { '/etc/init/rails.conf':
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/rails/etc/init/rails.conf'
  }
  # register it with ubuntu
  exec { 'reload-initctl':
    path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    command     => '/sbin/initctl reload-configuration',
    user        => 'root',
    subscribe   => File['/etc/init/rails.conf'],
    refreshonly => true,
    timeout     => 0,
    notify      => Service['rails']
  }
  # Ensure that the service is running.
  service { 'rails':
    provider => 'upstart',
    require => [File['/etc/init/rails.conf'], User['rails'], Group['webdev'], File["/srv"]]
  }
}
