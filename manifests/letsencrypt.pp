# == Define: role_treebase::letsencrypt
#
# === Authors
#
# Author Name <foppe.pieters@naturalis.nl>
#
#
class role_treebase::letsencrypt (
){

  class { ::letsencrypt:
    config => {
                email  => $role_treebase::letsencrypt_email,
                server => $role_treebase::letsencrypt_server,
              }
  }

  letsencrypt::certonly { 'letsencrypt_cert':
    domains       => [$role_treebase::letsencrypt_domain],
    manage_cron   => true,
  }


 # create ssl check script for usage with monitoring tools ( sensu )
  file {'/usr/local/sbin/sslchk.sh':
    ensure        => 'file',
    mode          => '0777',
    content       => template('role_treebase/sslchk.sh.erb')
  }

 # export check so sensu monitoring can make use of it
  @sensu::check { 'Check SSL expire date' :
    command => '/usr/local/sbin/sslchk.sh',
    tag     => 'central_sensu',
  }


}
