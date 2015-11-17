# == Class: role_treebase
#
# This role creates the necessary configuration for the Treebase webservice.
#
# === Parameters
# FIXME: describe the parameters
# postgresql_dbname
# postgresql_username
# postgresql_password
# treebase_owner
# treebase_read
#
# === Examples
#
#  class { 'role_treebase':
#   postgresql_dbname   => "treebase",
#   postgresql_username => "treebase_app",
#   postgresql_password => "changeme",
#   treebase_owner      => "treebase_owner",
#   treebase_read       => "treebase_read",
#  }
#
# === Authors
#
# Authors: Foppe Pieters <foppe.pieters@naturalis.nl>
#          Pim Polderman <info@pimpolderman.nl>
#
# === Copyright
#
# Copyright 2015 Naturalis
#
class role_treebase (
  $postgresql_dbname   = "treebase",
  $postgresql_username = undef,
  $postgresql_password = undef,
  $treebase_owner     = "treebase_owner",
  $treebase_read      = "treebase_read",
) {

  package { 'tomcat6':
    ensure => installed,
  }

  class { 'postgresql::server': }

  postgresql::server::db { "${postgresql_dbname}":
    user     => "${postgresql_username}",
    password => postgresql_password("${postgresql_username}", "${postgresql_password}"),
    require => Class['postgresql::server'],
  }
  postgresql::server::role { "${treebase_owner}":
    createrole    => false,
    login         => false,
  }
  postgresql::server::role { "${treebase_read}":
    createrole    => false,
    login         => true,
  }
}
