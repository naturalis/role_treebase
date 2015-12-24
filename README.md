![Logo of Treebase](https://treebase.org/treebase-web/images/TreeBASE.png)
# role_treebase
#### Table of Contents :+1:

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with role_treebase](#setup)
    * [What role_treebase affects](#what-role_treebase-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This puppet module deploys the Treebase java application (excluding the databse) and creates the necessary configuration to run the application. You can see the application running at: [treebase.org](https://treebase.org)

## Module Description

The role::treebase class will bootstrap a Treebase ready environment.

## Setup

### What role_treebase affects

* Packages:
	- tomcat6  (WARNING: End of Life Q4 2016) :-(
	- postgresql
	- apache2
* Directory's:  
	- '/var/lib/tomcat6' will be overwritten with Treebase specific settings.
	- '/opt/letsencrypt' and '/etc/letsencrypt' will be created for ssl certificates.
* Database: postgresql database with 3 users (owner, read and app)

### Setup Requirements

* Dump from treebase database

### Installation

To install Treebase with Puppet:

* 1. Apply the role::treebase class to a server
* 2. Manually copy the database dump to the server
* 3. Change the password of the postgres user
```shell
   $ sudo -u postgres psql
   $ ALTER USER postgres WITH ENCRYPTED PASSWORD 'changeme';  
   $ \q
```
* 4. Import the postgres database (if there are errors do it another time).
```shell
   $ pg_restore -h localhost -U postgres -W <postgress_dump> -d treebasedb -v -c
```
* 5. Restart tomcat6.
```shell
   $ sudo service tomcat6 restart
```
* 6. Change the $letsencrypt_server from staging to production if needed:
```shell
    Staging: https://acme-staging.api.letsencrypt.org/directory
    Production: https://acme-v01.api.letsencrypt.org/directory
```

## Usage
```puppet
class role_treebase (
  $postgresql_dbname         = "treebasedb",
  $postgresql_username       = "treebase_app",
  $postgresql_password       = undef,
  $treebase_owner            = "treebase_owner",
  $treebase_read             = "treebase_read",
  $treebase_url              = "treebase.org",
  $treebase_smtp             = "smtp.nescent.org",
  $treebase_adminmail        = "sysadmin@nescent.org",
  $java_Xms                  = "512m",
  $java_Xmx                  = "1024m",
  $java_MaxPermSize          = "256m",
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
                                 'serveradmin'          => 'aut@naturalis.nl',
                                 'priority'             => 10,
                                 },
                                 'treebase.org' => {
                                 'serveraliases'        => '*.treebase.org',
                                 'docroot'              => '/var/www/htdocs',
                                 'directories'          => [{ 'path' => '/var/www/htdocs',
                                 'options'              => '-Indexes +FollowSymLinks +MultiViews',
                                 'allow_override'       => 'All'}],
                                 'rewrites'             => [{'rewrite_rule' => ['^/treebase-web(.*)$ http://treebase.org:8080/treebase-web$1 [P]']}],
                                 'proxy_pass'           => [{'path'         => '/', 'url' => 'http://treebase.org:8080/'},],
                                 'custom_fragment'      => 'ProxyTimeout 86500',
                                 'port'                 => 443,
                                 'serveradmin'          => 'aut@naturalis.nl',
                                 'priority'             => 10,
                                 'ssl'                  => true,
                                 'ssl_cert'             => '/etc/letsencrypt/live/treebase.org/cert.pem',
                                 'ssl_key'              => '/etc/letsencrypt/live/treebase.org/privkey.pem',
                                 'ssl_chain'            => '/etc/letsencrypt/live/treebase.org/chain.pem',
                                 'additional_includes'  => '/etc/letsencrypt/options-ssl-apache.conf',
                                 },
                               },
  $keepalive                 = 'Off',
  $max_keepalive_requests    = '150',
  $keepalive_timeout         = '1500',
  $timeout                   = '3600',
  $cron_restart              = true,
  $letsencrypt_path          = '/opt/letsencrypt',
  $letsencrypt_repo          = 'git://github.com/letsencrypt/letsencrypt.git',
  $letsencrypt_version       = 'v0.1.0',
  $letsencrypt_live          = '/etc/letsencrypt/live/treebase.org/cert.pem',
  $letsencrypt_email         = 'aut@naturalis.nl',
  $letsencrypt_domain        = 'treebase.org',
  $letsencrypt_server        = 'https://acme-staging.api.letsencrypt.org/directory'
```

## Reference
* "role_treebase" installs Postgresql, Tomcat6, Apache2 and deploys the Treebase webapp. Every 5 minutes there is a cron check that restarts tomcat if cpu load is excessive.
* "letsencrypt" installs letsencrypt, authenticates through port 443 and install a ssl certificate.

 These classes depend on the following modules:
  - [puppetlabs/vcsrepo](https://github.com/puppetlabs/puppetlabs-vcsrepo)
  - [puppetlabs/postgresql](https://github.com/puppetlabs/puppetlabs-postgresql)
  - [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

In production we are using more classes for helping us. ;)
  - [naturalis/puppet-role_backup](https://github.com/naturalis/puppet-role_backup) for automated backups (uses [burp](http://burp.grke.org/) as backup mechanism).
  - [naturalis/puppet-role_sensu](https://github.com/naturalis/puppet-role_sensu) for alerting and all kinds of checks.

## Limitations
Only supported/tested OS: ubuntu LTS 14.04

## Development
Feel free to submit pull requests.

## Authors
- Foppe Pieters <foppe.pieters@naturalis.nl>
- Pim Polderman <info@pimpolderman.nl>
