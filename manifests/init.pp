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

  # Install tomcat 6
  package { 'tomcat6':
    ensure => installed,
  }

  # Install database
  class { 'postgresql::server': }

  # Create postgresql database and users
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
  # Deploy context.xml.default with our database settings
  file { '/var/lib/tomcat6/conf/Catalina/localhost/context.xml.default':
    ensure  => file,
    onwer   => 'tomcat6',
    group   => 'tomcat6',
    mode    => '644',
    content => template('role_treebase/context.xml.default.erb'),
  }
}
