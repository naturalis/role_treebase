# == Define: role_treebase::letsencrypt
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
#
define role_treebase::letsencrypt ()
{
  # install letsencrypt cert
  vcsrepo { role_treebase::letsencrypt_path:
    ensure      => present,
    provider    => git,
    source      => $role_treebase::letsencrypt_repo,
    revision    => $role_treebase::letsencrypt_version,
    notify      => Exec['initialize letsencrypt'],
  }
  exec { 'initialize letsencrypt':
    command     => '${role_treebase::letsencrypt_path}/letsencrypt-auto --agree-tos -h',
    refreshonly => true,
    notify      => Exec['install letsencrypt'],
  }
  exec { 'install letsencrypt':
    command     => '${role_treebase::letsencrypt_path}/letsencrypt-auto certonly --apache -d ${role_treebase::letsencrypt_domain} --email ${role_treebase::letsencrypt_email} --agree-tos',
    creates     => $role_treebase::letsencrypt_live,
    path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    refreshonly => true,
  }
}
