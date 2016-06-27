# == Class: role_treebase
#
# This role creates the necessary configuration for the Treebase webservice.
#
# === Parameters
#
# postgresql_dbname:
# The database name, default: treebasedb
#
# postgresql_username:
# Postgresql username, default: treebase_app
#
# postgresql_password:
# Postgressql password, undefined. Make sure you set a password here.
#
# treebase_owner:
# Owner of the treebase database objects, default: treebase_owner
#
# treebase_read:
# Read-only account. Can be used when need a extra tomcat instance read from the database. default: treebase_read
#
# treebase_url:
# Set the redirect here. If we connect to port 80 we get automatically forwarded to port 8080. default: treebase.org/treebase-web
#
# java_options:
# set the java (memory) runtime options for tomcat 6, default "-Djava.awt.headless=true -Xms2048m -Xmx16384M"
#
# treebase_smtp:
# Sent users their forgot password e-mails and notifications. default: smtp.nescent.org
#
# treebase_adminmail:
# Administrators e-mail address. default: sysadmin: sysadmin@nescent.org
#
# purl_url:
# purl (persistent_url). Default: http://purl.org/phylo/treebase/phylows/
#
# gitrepos:
# Hash example:
# [ {'tomcat6' =>
#    {'reposource'   => 'git@github.com:naturalis/treebase-artifact.git',
#     'repokey'      => 'PRIVATE KEY here',
#    },
# },
# ]
#
# webdirs:
# Directory for website. Default: /var/www/htdocs
#
# instances:
# Vhost configuration to redirect to https and proxy to tomcat webapp
#
# keepalive                 = 'Off',
# max_keepalive_requests    = '150',
# keepalive_timeout         = '1500',
# timeout                   = '3600',
# letsencrypt_path          = '/opt/letsencrypt',
# letsencrypt_repo          = 'git://github.com/letsencrypt/letsencrypt.git',
# letsencrypt_version       = 'v0.1.0',
# letsencrypt_live          = '/etc/letsencrypt/live/treebase.org/cert.pem',
# letsencrypt_email         = 'aut@naturalis.nl',
# letsencrypt_domain        = 'treebase.org',
# letsencrypt_server        = 'https://acme-staging.api.letsencrypt.org/directory
#
#
#
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
  $postgresql_dbname         = "treebasedb",
  $postgresql_username       = "treebase_app",
  $postgresql_password       = undef,
  $postgresql_version        = '9.3',
  $remote_address            = undef,
  $treebase_owner            = "treebase_owner",
  $treebase_read             = "treebase_read",
  $treebase_url              = "treebase.org",
  $treebase_smtp             = "smtp-relay.gmail.com",
  $treebase_adminmail        = "admin@treebase.org",
  $java_Xms                  = "1024m",
  $java_Xmx                  = "4096m",
  $java_MaxPermSize          = "1024m",
  $purl_url                  = "http://purl.org/phylo/treebase/phylows/",
  $gitrepos                  =
  [ {'tomcat6' =>
      {'reposource'   => 'git@github.com:naturalis/treebase-artifact.git',
       'repokey'      => 'PRIVATE KEY here',
      },
   },
  ],
  $webdirs                   = ['/var/www/htdocs'],
  $instances                 = {'treebase.org-nonssl' => {
                                 'serveraliases'        => '*.treebase.org',
                                 'docroot'              => '/var/www/htdocs',
                                 'directories'          => [{ 'path' => '/var/www/htdocs',
                                 'options'              => '-Indexes +FollowSymLinks +MultiViews',
                                 'allow_override'       => 'All'}],
                                 'rewrites'             => [{'rewrite_rule' => ['^/?(.*) https://%{SERVER_NAME}/$1 [R,L]']}],
                                 'port'                 => 80,
                                 'serveradmin'          => 'admin@treebase.org',
                                 'priority'             => 10,
                                 },
                                 'treebase.org' => {
                                 'serveraliases'        => '*.treebase.org',
                                 'docroot'              => '/var/www/htdocs',
                                 'directories'          => [{ 'path' => '/var/www/htdocs',
                                 'options'              => '-Indexes +FollowSymLinks +MultiViews',
                                 'allow_override'       => 'All'}],
                                 'custom_fragment'      => '<Location /treebase-web/monitoring>
                                                            AuthType Basic
                                                            AuthName "Treebase Web Monitoring"
                                                            AuthUserFile /var/www/.monitoring-htauth
                                                            Require valid-user
                                                            </Location>
                                                            ProxyTimeout 3604',
                                 'rewrites'             => [{'rewrite_rule' => ['^/treebase-web(.*)$ http://treebase.org:8080/treebase-web$1 [P]']},
                                                            {'rewrite_cond' => ['%{HTTP_USER_AGENT}  ^.*Baiduspider.*$'],
                                                             'rewrite_rule' => ['- [F]'],},],
                                 'proxy_pass'           => [{'path'         => '/', 'url' => 'http://treebase.org:8080/'},],
                                 'port'                 => 443,
                                 'serveradmin'          => 'admin@treebase.org',
                                 'priority'             => 10,
                                 'ssl'                  => true,
                                 'ssl_cert'             => '/etc/letsencrypt/live/treebase.org/cert.pem',
                                 'ssl_key'              => '/etc/letsencrypt/live/treebase.org/privkey.pem',
                                 'ssl_chain'            => '/etc/letsencrypt/live/treebase.org/chain.pem',
                                 'additional_includes'  => '/etc/letsencrypt/options-ssl-apache.conf',
                                 },
                               },
  $monitoring_pass           = undef,
  $keepalive                 = 'Off',
  $max_keepalive_requests    = '150',
  $keepalive_timeout         = '1500',
  $timeout                   = '3600',
  $cron_restart              = true,
  $dev_server                = false,
  $letsencrypt_path          = '/opt/letsencrypt',
  $letsencrypt_repo          = 'git://github.com/letsencrypt/letsencrypt.git',
  $letsencrypt_version       = 'v0.1.0',
  $letsencrypt_live          = '/etc/letsencrypt/live/treebase.org/cert.pem',
  $letsencrypt_email         = 'aut@naturalis.nl',
  $letsencrypt_domain        = 'treebase.org',
  $letsencrypt_server        = 'https://acme-staging.api.letsencrypt.org/directory', #https://acme-v01.api.letsencrypt.org/directory
) {
  # Install database
  class { 'postgresql::globals':
    manage_package_repo           => true,
    version                       => "${$postgresql_version}",
  }->
  class { 'postgresql::server': }
  # add postgresql config from pgtune
  postgresql::server::config_entry {'default_statistics_target': value => '100'}
  postgresql::server::config_entry {'checkpoint_completion_target': value => '0.9'}
  postgresql::server::config_entry {'effective_cache_size': value => '11GB'}
  postgresql::server::config_entry {'work_mem': value => '80MB'}
  postgresql::server::config_entry {'wal_buffers': value => '16MB'}
  postgresql::server::config_entry {'checkpoint_segments': value => '32'}
  postgresql::server::config_entry {'shared_buffers': value => '3840MB'}
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
  # setup access rule for external ssl access
  postgresql::server::pg_hba_rule { 'allow ssl access to database':
  description        => "Open up postgresql for ssl access",
  type               => 'host',
  database           => '${postgresql_dbname}',
  user               => '${postgresql_username}',
  address            =>  $remote_address,
  auth_method        => 'md5',
  postgresql_version => '${$postgresql_version}',
}
  # Install tomcat 6
  package { 'tomcat6':
    ensure        => installed,
  }
  # make sure that the tomcat 6 services is running
  service { 'tomcat6':
    ensure        => running,
    enable        => true,
  }
  # Deploy context.xml.default with our database settings
  file { '/var/lib/tomcat6/conf/Catalina/localhost/context.xml.default':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'tomcat6',
    mode          => '0644',
    content       => template('role_treebase/context.xml.default.erb'),
    require       => Package['tomcat6'],
    notify        => Service['tomcat6'],
  }
  # Deploy tomcat init script to support headless mesquite
  file { '/etc/init.d/tomcat6':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0755',
    content       => template('role_treebase/tomcat6-init.erb'),
    notify        => Service['tomcat6'],
  }
  # Deploy tomcat default to enable authbind
  file { '/etc/default/tomcat6':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0644',
    content       => template('role_treebase/tomcat6-etc.erb'),
    notify        => Service['tomcat6'],
  }
  # Deploy tomcat server.xml to listen on port 80
  file { '/var/lib/tomcat6/conf/server.xml':
    ensure        => file,
    owner         => 'root',
    group         => 'tomcat6',
    mode          => '0644',
    content       => template('role_treebase/server.xml.erb'),
    require       => Package['tomcat6'],
    notify        => Service['tomcat6'],
  }
  # Deploy redirect index.html
  file { '/var/lib/tomcat6/webapps/ROOT/index.html':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0644',
    content       => template('role_treebase/index.html.erb'),
    require       => Package['tomcat6'],
  }
  #make webdirs for apache
  file { $webdirs:
    ensure        => 'directory',
    mode          => '0750',
    owner         => 'root',
    group         => 'www-data',
    require       => Class['apache']
  }
  # Install letsencrypt cert
  class { 'role_treebase::letsencrypt': }
  # Install apache and enable modules
  class { 'apache':
    default_mods              => true,
    mpm_module                => 'prefork',
    keepalive                 => $keepalive,
    max_keepalive_requests    => $max_keepalive_requests,
    keepalive_timeout         => $keepalive_timeout,
    require                   => Class['role_treebase::letsencrypt']
  }
  # install apache mods
  class { 'apache::mod::rewrite': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::expires': }
  class { 'apache::mod::proxy': }
  class { 'apache::mod::proxy_http': }
  class { 'apache::mod::cache': }
  class { 'apache::mod::ssl': }
  # Create Apache Virtual host
  create_resources('apache::vhost', $instances)
  # mod_cache_disk is not so easy to enable
  apache::mod {'cache_disk':}
  # make config  for mod_cache_disk
  file { '/etc/apache2/mods-available/cache_disk.conf':
    ensure        => file,
    mode          => '0644',
    content       => template('role_treebase/cache_disk.conf.erb'),
    require       => Class['apache']
  }
  # make symlink to enable mod_cache_disk
  file { '/etc/apache2/mods-enabled/cache_disk.conf':
    ensure        => 'link',
    target        => '/etc/apache2/mods-available/cache_disk.conf',
    owner         => 'root',
    group         => 'root',
    require       => Class['apache'],
  }
   # Deploy apache2 default to configure htcacheclean
  file { '/etc/default/apache2':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0644',
    content       => template('role_treebase/apache2-etc.erb'),
    notify        => Service['apache2'],
  }
  # Deploy htpasswd to protect monitoring part
  file { '/var/www/.monitoring-htauth':
    ensure        => file,
    owner         => 'root',
    group         => 'root',
    mode          => '0644',
    require       => File[$webdirs],
    content       => template('role_treebase/monitoring-htauth.erb'),
    notify        => Service['apache2'],
  }
  # General repo settings
  class { 'role_treebase::repogeneral': }
  # Check out the repository
  create_resources('role_treebase::repo', $gitrepos)
  # make symlink to treebase-web
  file { '/var/lib/tomcat6/webapps/treebase-web':
    ensure        => 'link',
    target        => '/opt/git/tomcat6/treebase-web',
    require       => Package['tomcat6'],
  }
  # make symlink to mesquite
  file { '/var/lib/tomcat6/mesquite':
    ensure        => 'link',
    target        => '/opt/git/tomcat6/mesquite',
    require       => Package['tomcat6'],
  }
  # make symlink to treebase-web.war
  file { '/var/lib/tomcat6/webapps/treebase-web.war':
    ensure        => 'link',
    target        => '/opt/git/tomcat6/treebase-web.war',
    require       => Package['tomcat6'],
  }
  # make symlink to treebase.log
  file { '/var/lib/tomcat6/treebase.log':
    ensure        => 'link',
    target        => '/var/log/tomcat6/treebase.log',
    owner         => 'tomcat6',
    group         => 'tomcat6',
    require       => Package['tomcat6'],
  }->
  # Deploy treebase.log
  file { '/var/log/tomcat6/treebase.log':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'tomcat6',
    mode          => '0644',
    require       => Package['tomcat6'],
  } # Deploy apache2 default to configure htcacheclean
  # add logrotate to the log file
  file { '/etc/logrotate.d/logrotate_treebase':
     content      => template('role_treebase/logrotate_treebase.erb'),
     mode         => '0644',
   }
   # make lib dir
  file { '/var/lib/tomcat6/lib':
    ensure        => 'directory',
    mode          => '0755',
    owner         => 'tomcat6',
    group         => 'tomcat6',
    require       => Package['tomcat6'],
  }
  # deploy log4j in the lib dir
  file {'/var/lib/tomcat6/lib/log4j-1.2.16.jar':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'root',
    mode          => '0644',
    source        => "puppet:///modules/role_treebase/log4j-1.2.16.jar",
    require       => Package['tomcat6'],
    notify        => Service['tomcat6'],
  }
  # deploy log4j properties
  file {'/var/lib/tomcat6/conf/log4j.properties':
    ensure        => file,
    owner         => 'tomcat6',
    group         => 'tomcat6',
    mode          => '0644',
    source        => "puppet:///modules/role_treebase/log4j.properties",
    require       => Package['tomcat6'],
    notify        => Service['tomcat6'],
  }
  # remove old logging properties
  file {'/var/lib/tomcat6/conf/logging.properties':
    ensure        => absent,
    require       => [Package['tomcat6'],File['/var/lib/tomcat6/conf/log4j.properties']],
    notify        => Service['tomcat6'],
  }
  if ($cron_restart == true)
  {
    # script to restart when http header (sensu check) is not found
    file { '/usr/sbin/restart_on_sensu_http_check':
      ensure      => file,
      owner       => 'root',
      group       => 'root',
      mode        => '0755',
      content     => template('role_treebase/restart_on_sensu_http_check.erb'),
      require     => Service['tomcat6'],
    }
    # make cronjob to run every 5 minutes
    cron { 'restart_on_sensu_http_check':
      command     => '/usr/sbin/restart_on_sensu_http_check',
      user        => root,
      minute      => '*/5',
    }
    # 2nd script to restart when cpu load (sensu check) is excessive
    file { '/usr/sbin/restart_on_sensu_load_check':
      ensure      => file,
      owner       => 'root',
      group       => 'root',
      mode        => '0755',
      content     => template('role_treebase/restart_on_sensu_load_check.erb'),
      require     => Service['tomcat6'],
    }
    # make cronjob to run every 5 minutes
    cron { 'restart_on_sensu_load_check':
      command     => '/usr/sbin/restart_on_sensu_load_check',
      user        => root,
      minute      => '*/5',
    }
    # add logrotate to the log file
    file { '/etc/logrotate.d/logrotate_load':
       content    => template('role_treebase/logrotate_load.erb'),
       mode       => '0644',
     }
  }
  if ($dev_server == true)
  {
    # script to copy database dump
    file { '/usr/sbin/copy-database':
      ensure      => file,
      owner       => 'root',
      group       => 'root',
      mode        => '0755',
      content     => template('role_treebase/copy-database.erb'),
      require     => Service['postgresql'],
    }
    # make cronjob to run rsync every 6 hours
    cron { 'copy-database':
      command     => '/usr/sbin/copy-database',
      user        => ubuntu,
      minute      => '*/10',
    }
    # script to drop tables and import new dump
    file { '/usr/sbin/restore-database':
      ensure      => file,
      owner       => 'root',
      group       => 'root',
      mode        => '0755',
      content     => template('role_treebase/restore-database.erb'),
      require     => Service['postgresql'],
    }
    # make cronjob to run every 12 hours
    cron { 'restore-database':
      command     => '/usr/sbin/restore-database',
      user        => postgres,
      minute      => '0',
      hour        => '*/12',
    }
    # add logrotate to the log file
    file { '/etc/logrotate.d/logrotate_restore':
       content    => template('role_treebase/logrotate_restore.erb'),
       mode       => '0644',
     }
  }
}
