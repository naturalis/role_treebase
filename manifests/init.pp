# == Class: role_treebase
#
# This role creates the necessary configuration for the Treebase webservice.
#
# === Parameters
#
# postgresql_dbname
#
# The database name, default: treebasedb
#
# postgresql_username
#
# Postgresql username, default: treebase_app
#
# postgresql_password
#
# Postgressql password, undefined. Make sure you set a password here.
#
# treebase_owner
#
# Owner of the treebase database objects, default: treebase_owner
#
# treebase_read
#
# Read-only account. Can be used when need a extra tomcat instance read from the database. default: treebase_read
#
# treebase_url
#
# Set the redirect here. If we connect to port 80 we get automatically forwarded to port 8080. default: treebase.org/treebase-web
#
# java_options
#
# set the java (memory) runtime options for tomcat 6, default "-Djava.awt.headless=true -Xms2048m -Xmx16384M"
#
# treebase_smtp
#
# Sent users their forgot password e-mails and notifications. default: smtp.nescent.org
#
# treebase_adminmail
#
# Administrators e-mail address. default: sysadmin: sysadmin@nescent.org
#
# purl_url
#
# purl (persistent_url). Default: http://purl.org/phylo/treebase/phylows/
#
# gitrepos
#
# Hash example:
# [ {'tomcat6' =>
#    {'reposource'   => 'git@github.com:naturalis/treebase-artifact.git',
#     'repokey'      => 'PRIVATE KEY here',
#    },
# },
# ]
#
# === Examples
# class { 'role_treebase' :
#  postgresql_dbname    => "treebasedb",
#  postgresql_username  => "treebase_app",
#  postgresql_password  => "changeme",
#  treebase_owner       => "treebase_owner",
#  treebase_read        => "treebase_read",
#  treebase_url         => "treebase.org/treebase-web",
#  treebase_smtp        => "smtp.nescent.org",
#  treebase_adminmail   => "sysadmin@nescent.org",
#  java_options         => "-Djava.awt.headless=true -Xms2048m -Xmx16384M",
#  purl_url             => "http://purl.org/phylo/treebase/phylows/",
#  gitrepos             =>
#  [ {'tomcat6' =>
#      {'reposource'   => 'git@github.com:naturalis/treebase-artifact.git',
#       'repokey'      => 'PRIVATE KEY here',
#      },
#   },
#  ],
#}
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
  $postgresql_dbname    = "treebasedb",
  $postgresql_username  = "treebase_app",
  $postgresql_password  = undef,
  $treebase_owner       = "treebase_owner",
  $treebase_read        = "treebase_read",
  $treebase_url         = undef,
  $treebase_smtp        = "smtp.nescent.org",
  $treebase_adminmail   = "sysadmin@nescent.org",
  $java_options         = "-Djava.awt.headless=true -Xms1024m -Xmx2048M -XX:+UseConcMarkSweepGC",
  $purl_url             = "http://purl.org/phylo/treebase/phylows/",
  $gitrepos             =
  [ {'tomcat6' =>
      {'reposource'   => 'git@github.com:naturalis/treebase-artifact.git',
       'repokey'      => 'PRIVATE KEY here',
      },
   },
  ],
  $webdirs              = ['/var/www/htdocs'],
  $rwwebdirs            = ['/var/www/htdocs/cache'],
  $instances            = {'treebase.naturalis.nl' => {
                          'serveraliases'     => '*.naturalis.nl',
                          'docroot'           => '/var/www/htdocs',
                          'directories'       => [{ 'path' => '/var/www/htdocs',
                          'options'           => '-Indexes +FollowSymLinks +MultiViews',
                          'allow_override'    => 'All'}],
                          'rewrites'          => [{ 'rewrite_rule' => ['^/treebase-web(.*)$ http://localhost:8080/treebase-web$1 [P]'] }],
                          'port'              => 80,
                          'serveradmin'       => 'webmaster@naturalis.nl',
                          'priority'          => 10,
                          },
                        },
) {
  # Install tomcat 6
  package { 'tomcat6':
    ensure        => installed,
  }
  # Install database
  class { 'postgresql::globals':
    manage_package_repo => true,
    version             => '8.4',
  }->
  class { 'postgresql::server': }
  # Create postgresql database and users
  postgresql::server::db { "${postgresql_dbname}":
    user          => "${postgresql_username}",
    password      => postgresql_password("${postgresql_username}", "${postgresql_password}"),
    require       => Class['postgresql::server'],
  }
  postgresql::server::role { "${treebase_owner}":
    createrole    => false,
    login         => false,
  }
  postgresql::server::role { "${treebase_read}":
    createrole    => false,
    login         => true,
  }
  #make webdirs
  file { $webdirs:
    ensure        => 'directory',
    mode          => '0750',
    owner         => 'root',
    group         => 'www-data',
    require       => Class['apache']
  }->
  file { $rwwebdirs:
    ensure        => 'directory',
    mode          => '0777',
    owner         => 'www-data',
    group         => 'www-data',
    require       => File[$webdirs]
  }
  # install php module php-gd
  php::module { [ 'gd','mysql','curl' ]: }

  php::ini { '/etc/php5/apache2/php.ini':
    memory_limit              => $php_memory_limit,
    upload_max_filesize       => $upload_max_filesize,
    post_max_size             => $post_max_size,
    max_execution_time        => $max_execution_time,
    max_input_vars            => $max_input_vars,
    max_input_time            => $max_input_time,
    session_gc_maxlifetime    => $session_gc_maxlifetime,
  }
 # Install apache and enable modules
  class { 'apache':
    default_mods              => true,
    mpm_module                => 'prefork',
    keepalive                 => $keepalive,
    max_keepalive_requests    => $max_keepalive_requests,
    keepalive_timeout         => $keepalive_timeout,
  }
  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::speling
  include apache::mod::proxy
  include apache::mod::proxy_http  
  # Install mod-jk
  package { 'libapache2-mod-jk':
    ensure        => installed,
    require       => Class['apache']
  }
  file { '/etc/libapache2-mod-jk/workers.properties':
    ensure        => file,
    mode          => '644',
    content       => template('role_treebase/workers.properties.erb'),
    require       => Package['libapache2-mod-jk']
  }
  file { '/etc/apache2/mods-available/jk.conf':
    ensure        => file,
    mode          => '644',
    content       => template('role_treebase/jk.conf.erb'),
    require       => Package['libapache2-mod-jk']
  }
  # Create Apache Vitual host
  create_resources('apache::vhost', $instances)
  # Deploy context.xml.default with our database settings
  file { '/var/lib/tomcat6/conf/Catalina/localhost/context.xml.default':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'tomcat6',
    mode          => '644',
    content       => template('role_treebase/context.xml.default.erb'),
  }
  # Deploy tomcat init script to support headless mesquite
  file { '/etc/init.d/tomcat6':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '755',
    content       => template('role_treebase/tomcat6-init.erb'),
    notify        => Service['tomcat6'],
  }
  # Deploy tomcat default to enable authbind
  file { '/etc/default/tomcat6':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '644',
    content       => template('role_treebase/tomcat6-etc.erb'),
    notify        => Service['tomcat6'],
  }
  # Deploy tomcat server.xml to listen on port 80
  file { '/var/lib/tomcat6/conf/server.xml':
    ensure        => file,
    owner         => 'root',
    group         => 'tomcat6',
    mode          => '644',
    content       => template('role_treebase/server.xml.erb'),
  }
  # Deploy redirect index.html
  file { '/var/www/htdocs/index.html':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '644',
    content       => template('role_treebase/index.html.erb')
  }
  # General repo settings
  class { 'role_treebase::repogeneral': }
  # Check out repositories
  create_resources('role_treebase::repo', $gitrepos)
  # make symlink to treebase-web
  file { '/var/lib/tomcat6/webapps/treebase-web':
    ensure        => 'link',
    target        => '/opt/git/tomcat6/treebase-web',
  }
  # make symlink to mesquite
  file { '/var/lib/tomcat6/mesquite':
    ensure        => 'link',
    target        => '/opt/git/tomcat6/mesquite',
  }
  # make symlink to treebase-web.war
  file { '/var/lib/tomcat6/webapps/treebase-web.war':
    ensure        => 'link',
    target        => '/opt/git/tomcat6/treebase-web.war',
  }
  # deploy log4j
  file {'/var/lib/tomcat6/lib/log4j-1.2.16.jar':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'root',
    mode          => '644',
    source        => "puppet:///modules/role_treebase/log4j-1.2.16.jar",
  }
  # deploy log4j properties
  file {'/var/lib/tomcat6/conf/log4j.properties':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'tomcat6',
    mode          => '644',
    source        => "puppet:///modules/role_treebase/log4j.properties",
  }
  # remove old logging properties
  file {'/var/lib/tomcat6/conf/logging.properties':
    ensure        => absent,
  }
  # make sure that the tomcat 6 services is running
  service { 'tomcat6':
    ensure        => running,
    enable        => true,
  }
}
