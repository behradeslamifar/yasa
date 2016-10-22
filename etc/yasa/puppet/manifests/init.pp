# site.pp must exist (puppet #15106, foreman #1708)
# node /.*\.cvak\.local/ {
  package { 'rsyslog':
    ensure => present,
  }
  
  file { '/etc/rsyslog.d/usblock.conf':
    notify  => Service['rsyslog'],
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    source  => "puppet:///files/hosts/$::fqdn/etc/yasalog.conf",
  }

  service { 'rsyslog':
    ensure  => 'running',
    enable  => 'true',
    require => Package['rsyslog'],
  }
  
  file { '/etc/udev/rules.d/10-usblock.rules':
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => "puppet:///files/hosts/$::fqdn/etc/10-usblock.rules",
    notify  => Exec['puppet_trigger_udev'],
    notify  => Exec['puppet_trigger_subsystem'],
    notify  => Exec['puppet_trigger_devices'],
  }

  exec { 'puppet_trigger_udev':
    command     => "bash -c 'udevadm control --reload'",
    subscribe   => File['/etc/udev/rules.d/10-usblock.rules'],
    refreshonly => true,
  }

  exec { 'puppet_trigger_subsystem':
    command     => "bash -c 'udevadm trigger -c add -s usb'",
    subscribe   => File['/etc/udev/rules.d/10-usblock.rules'],
    refreshonly => true,
  }

  exec { 'puppet_trigger_devices':
    command     => "bash -c 'udevadm trigger -c add -t devices'",
    subscribe   => File['/etc/udev/rules.d/10-usblock.rules'],
    refreshonly => true,
  }
   
