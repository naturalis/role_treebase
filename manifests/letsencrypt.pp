# == Define: role_treebase::letsencrypt
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
#
class role_treebase::letsencrypt (
  $path          = $role_treebase::letsencrypt_path,
  $repo          = $role_treebase::letsencrypt_repo,
  $version       = $role_treebase::letsencrypt_version,
  $live          = $role_treebase::letsencrypt_live,
){
  # install letsencrypt repo
  vcsrepo { $path:
    ensure      => present,
    provider    => git,
    source      => $repo,
    revision    => $version,
    notify      => Exec['initialize letsencrypt'],
  }
  #installing letsencrypt
  exec { 'initialize letsencrypt':
    command     => "${path}/letsencrypt-auto --agree-tos -h",
    refreshonly => true,
  }
  # install ini file
  file { "${path}/cli.ini":
    ensure      => file,
    mode        => '0644',
    owner       => 'root',
    group       => 'root',
    content     => template('role_treebase/cli.ini.erb'),
    require     => Exec['initialize letsencrypt'],
  }
  # install apache ssl config
  file { "/etc/letsencrypt/options-ssl-apache.conf":
    ensure      => file,
    mode        => '0644',
    owner       => 'root',
    group       => 'root',
    content     => template('role_treebase/options-ssl-apache.conf.erb'),
    require     => Exec['initialize letsencrypt'],
  }
  #installing cert and authenticate on port 443, before apache binds the port
  exec { 'install letsencrypt':
    command     => "${path}/letsencrypt-auto certonly --config ${path}/cli.ini",
    creates     => $live,
    path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    require     => File["${path}/cli.ini"]
  }
  # renew cert each month
  file { '/etc/cron.monthly/renew_cert':
    ensure        => file,
    mode          => '0644',
    owner         => 'root',
    group         => 'root',
    content       => template('role_treebase/renew_cert.erb'),
  }
}
