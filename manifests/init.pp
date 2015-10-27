# == Class: role_treebase
#
# Full description of class role_treebase here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'role_treebase':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class role_treebase (
  $console_listen_ip   = '127.0.0.1',
  $wildfly_debug       = false,
  $wildfly_xmx         = '1024m',
  $wildfly_xms         = '256m',
  $wildlfy_maxpermsize = '512m',
  $install_java        = true,
  $postgresql_dbname   = "treebase_db",
  $postgresql_username,
  $postgresql_password,
){
  class { 'wildfly':
    admin_password          => 'treebase',
    admin_user              => 'treebase',
    deployment_dir          => '/opt/wildfly_deployments',
    install_java            => $install_java,
    bind_address_management => $console_listen_ip,
    debug_mode              => $wildfly_debug,
    xmx                     => $wildfly_xmx,
    xms                     => $wildfly_xms,
    maxpermsize             => $wildlfy_maxpermsize,
  }
  file {'/opt/wildfly_deployments':
    ensure => directory,
    mode   => '0777',
  }

  class { 'postgresql::server': }

  postgresql::server::db { "${postgresql_dbname}":
    user     => "${postgresql_username}",
    password => postgresql_password("${postgresql_username}", "${postgresql_password}"),
    require => Class['postgresql::server'],
  }
}
