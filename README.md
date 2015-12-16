# role_treebase

#### Table of Contents

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

This puppet module deploys the Treebase java application (excluding the databse) and creates the necessary configuration to run the application.

## Module Description

The role::treebase class will bootstrap a Treebase ready environment.

## Setup

### What role_treebase affects

* Package: tomcat6  (WARNING: End of Life Q4 2016) :-(
* Directory: /var/lib/tomcat6 will be overwritten with Treebase specific settings.
* Database: postgresql database with 3 users (owner, read and app)

### Setup Requirements

* Database dump

### Installation

To install Treebase with Puppet:

* 1. Apply the role::treebase class to a server
* 2. Manually copy the database dump to the server
* 3. Change the password of the postgres user
```
   $ sudo -u postgres psql
   $ ALTER USER postgres WITH ENCRYPTED PASSWORD 'changeme';  
   $ \q
```
* 4. Import the postgres database (if there are errors do it another time).
```
   $ pg_restore -h localhost -U postgres -W <postgress_dump> -d treebasedb -v -c
```
* 5. Restart tomcat6.
```
   $ sudo service tomcat6 restart
```
* 6. Change the $letsencrypt_server from staging to production if needed:
```
Staging: https://acme-staging.api.letsencrypt.org/directory
Production: https://acme-v01.api.letsencrypt.org/directory
```

## Usage
```
 class { 'role_treebase' :
  postgresql_dbname    => "treebasedb",
  postgresql_username  => "treebase_app",
  postgresql_password  => "change_me",
  treebase_owner       => "treebase_owner",
  treebase_read        => "treebase_read",
  treebase_url         => "treebase.org/treebase-web",
  treebase_smtp        => "smtp.example.com",
  treebase_adminmail   => "sysadmin@example.com",
  java_options         => "-Djava.awt.headless=true -Xms2048m -Xmx16384M",
  purl_url             => "http://purl.org/phylo/treebase/phylows/",
  gitrepos             =>
  [ {'tomcat6' =>
      {'reposource'   => 'git@github.com:naturalis/treebase-artifact.git',
       'repokey'      => 'PRIVATE KEY here',
      },
   },
  ],
}
```

## Reference
role_treebase is the only class in this module. Depends on the following modules:
  - puppetlabs/vcsrepo
  - puppetlabs/postgresql

## Limitations
Only supported/tested OS: ubuntu LTS 14.04

## Development
Feel free to submit pull requests.
