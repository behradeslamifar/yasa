class yasa 
{
  package { 'rsyslog':
    ensure => present,
  }
  
  service { 'rsyslog':
    ensure  => 'running',
    enable  => 'true',
    require => Package['rsyslog'],
  }
 
  file { ['/usr/lib/yasa','/usr/lib/yasa/sbin']:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    recurse => true,
  }  

  file { '/usr/lib/yasa/sbin/yasa':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    source  => "puppet:///modules/yasa/yasa",
    require => File['/usr/lib/yasa/sbin'],
  }
 
  file { '/etc/rsyslog.d/yasa.conf':
    notify  => Service['rsyslog'],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('yasa/yasa.conf.erb'),
    #source  => "puppet:///modules/yasa/hosts/$::fqdn/etc/yasalog.conf",
  }

 
  file { '/etc/udev/rules.d/10-yasa.rules':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => "puppet:///modules/yasa/hosts/$::fqdn/etc/10-yasa.rules",
    audit  =>  'content',
    notify => Exec['puppet_trigger_udev'],
  }

  exec { 'puppet_trigger_udev':
    command     => "/sbin/udevadm control --reload; /sbin/udevadm trigger -c add -t devices -s usb",
    subscribe   => File['/etc/udev/rules.d/10-yasa.rules'],
    #refreshonly => true,
  }

#    notify  => Exec['puppet_trigger_subsystem'],
#  exec { 'puppet_trigger_subsystem':
#    command     => "/sbin/udevadm trigger -c add -s usb",
#    subscribe   => Exec['puppet_trigger_udev'],
#    refreshonly => true,
#    notify  => Exec['puppet_trigger_devices'],
#  }
#
#  exec { 'puppet_trigger_devices':
#    command     => "/sbin/udevadm trigger -c add -t devices",
#    subscribe   => Exec['puppet_trigger_subsystem'],
#    refreshonly => true,
#  }
}
