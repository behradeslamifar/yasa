# site.pp must exist (puppet #15106, foreman #1708)
# node /.*\.cvak\.local/ {
  package { 'rsyslog':
    ensure => present,
  }
  
  file { '/etc/rsyslog.d/usblock.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    source  => "puppet:///files/hosts/$::fqdn/etc/yasalog.conf",
    require => Package['rsyslog'],
  }
  
  file { '/etc/udev/rules.d/10-usblock.rules':
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => "puppet:///files/hosts/$::fqdn/etc/10-usblock.rules",
    notify  => Exec['puppet_trigger_subsystem'],
    notify  => Exec['puppet_trigger_devices'],
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
   
