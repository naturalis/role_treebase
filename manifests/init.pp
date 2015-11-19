# == Class: role_treebase
#
# This role creates the necessary configuration for the Treebase webservice.
#
# === Parameters
# postgresql_dbname
# postgresql_username
# postgresql_password
# treebase_owner
# treebase_read
#
# === Examples
#
#  class { 'role_treebase':
#   postgresql_dbname   => "treebasedb",
#   postgresql_username => "treebase_app",
#   postgresql_password => "changeme",
#   treebase_owner      => "treebase_owner",
#   treebase_read       => "treebase_read",
#   treebase_url        => "localhost",
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
# FIXME: describe the parameters
# TODO: Add vcsrepo for deployment
class role_treebase (
  $postgresql_dbname    = "treebasedb",
  $postgresql_username  = "treebase_app",
  $postgresql_password  = undef,
  $treebase_owner       = "treebase_owner",
  $treebase_read        = "treebase_read",
  $treebase_url         = undef,
) {

  # Install tomcat 6
  package { 'tomcat6':
    ensure => installed,
  }

  # Install database
  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '8.4',
  }->
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
    owner   => 'tomcat6',
    group   => 'tomcat6',
    mode    => '644',
    content => template('role_treebase/context.xml.default.erb'),
  }
  # Deploy tomcat default to enable authbind
  file { '/etc/default/tomcat6':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    content => template('role_treebase/tomcat6.erb'),
  }
  # Deploy tomcat server.xml to listen on port 80
  file { '/var/lib/tomcat6/conf/server.xml':
    ensure  => file,
    owner   => 'root',
    group   => 'tomcat6',
    mode    => '644',
    content => template('role_treebase/server.xml.erb'),
  }
  # Deploy redirect index.html
  file { '/var/lib/tomcat6/webapps/ROOT/index.html':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    content => template('role_treebase/index.html.erb')
  }
}
