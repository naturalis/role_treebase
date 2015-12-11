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
  $email         = $role_treebase::letsencrypt_email,
  $domain        = $role_treebase::letsencrypt_domain,
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
    notify      => Exec['install letsencrypt'],
  }
  #installing cert for apache
  exec { 'install letsencrypt':
    command     => "${path}/letsencrypt-auto certonly --apache -d ${domain} --email ${email} --agree-tos",
    creates     => $live,
    path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    refreshonly => true,
  }
}
