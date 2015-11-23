# == Define: role_treebase::repo
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
#
define role_treebase::repo (
  $repouser         = $title,
  $repolocation     = '/opt/git',
  $reporevision     = 'master',
  $repoversion      = 'present',
  $repoowner        = 'tomcat6',
  $repogroup        = 'tomcat6',
  $reposource,
  $repokey,
)
{
# set local variable for template sshconfig.erb
$repokeyname = $repouser
# create user
  user { $repouser :
    ensure      => present,
    groups      => 'git',
    home        => "${userdir}/${repouser}",
    require     => Class['role_treebase::repogeneral']
  }
# create homedirectory
  file { "/${userdir}/${repouser}":
    ensure      => 'directory',
    owner       => $repouser,
    mode        => '0770',
    require     => User[$repouser]
  }
# Create .ssh directory
  file { "${userdir}/${repouser}/.ssh":
    ensure    => directory,
    owner     => $repouser,
  }->
# Create .ssh/repokey file
  file { "${userdir}/${repouser}/.ssh/${repouser}":
    ensure    => present,
    content   => $repokey,
    owner     => $repouser,
    mode      => '0600',
  }->
# Create sshconfig file
  file { "${userdir}/${repouser}/.ssh/config":
    ensure    => present,
    content   => template('role_treebase/sshconfig.erb'),
    owner     => $repouser,
    mode      => '0600',
  }->
# run known_hosts.sh for future acceptance of github key
  exec{ 'add_known_hosts' :
    command   => '/usr/local/sbin/known_hosts.sh',
    cwd       => "${userdir}/${repouser}/.ssh/",
    path      => '/sbin:/usr/bin:/usr/local/bin/:/bin/',
    provider  => shell,
    user      => $repouser,
    unless    => "test -f ${userdir}/${repouser}/.ssh/known_hosts",
    require   => Class['role_treebase::repogeneral']
  }->
# give known_hosts file the correct permissions
  file{ "${userdir}/${repouser}/.ssh/known_hosts":
    mode      => '0600',
    owner     => $repouser
  }->
# checkout using vcsrepo
  vcsrepo { "${repolocation}/${repouser}":
    ensure    => $repoversion,
    provider  => 'git',
    source    => $reposource,
    user      => $repouser,
    revision  => $reporevision,
    owner     => $repoowner,
    group     => $repogroup,
  }
}
