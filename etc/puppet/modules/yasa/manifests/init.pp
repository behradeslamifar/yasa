# site.pp must exist (puppet #15106, foreman #1708)
# node /.*\.cvak\.local/ {
  package { 'rsyslog':
    ensure => present,
  }
  
  file { '/etc/rsyslog.d/usblock.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    source  => "puppet:///files/hosts/$::hostname/etc/yasalog.conf",
    require => Package['rsyslog'],
  }
  
  file { '/etc/udev/rules.d/10-usblock.rules':
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => "puppet:///files/hosts/$::hostname/etc/10-usblock.rules",
  }
