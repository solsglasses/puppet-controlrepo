# Class: MOTD
#
#
class profile::base::motd {
  
  package { 'figlet': }

  if $::is_pe == true {
    $agent = 'Puppet Enterprise Agent'
    $puppet_service = 'pe-puppet'
    $classestxt = '/var/opt/lib/pe-puppet/classes.txt'
  }
  else {
    $agent = 'Puppet Agent'
    $puppet_service = 'puppet'
    $classestxt = '/var/lib/puppet/state/classes.txt'
  }

  if !$::vagrant {
    file { '/tmp/classes.tmp':
      source             => $classestxt,
      source_permissions => 'ignore',
    }
  }

  if !$app_role { $app_role = 'none' }
  if !$app_tier { $app_tier = 'none' }
  
  case $::osfamily {
    'Debian': {

      $disable_motds = [ '/etc/update-motd.d/10-help-text',
                          '/etc/update-motd.d/51-cloudguest', ]
      file { $disable_motds: mode => '0000', }

      $motdfile = '/etc/update-motd.d/60-puppet-motd'

    }
    default: { $motdfile = '/etc/profile.d/puppet-motd.sh' }
  }
  
  file { $motdfile:
    mode    => '0755',
    content => template('profile/motd/motd.sh.erb'),
    require => [ Package['figlet'], ],
  }

  file { '/etc/issue.net':
    mode    => '0644',
    content => template('profile/motd/issue.net.erb'),
  }

}