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

This puppet module creates the necessary configuration to deploy the Treebase java application.

## Module Description

The role::treebase class will bootstrap a Treebase ready environment.

## Setup

### What role_treebase affects

* Package: tomcat6  (WARNING: End of Life Q4 2016) :-(
* Directory: /var/lib/tomcat6 will be overwritten with Treebase specific settings.
* Database: postgresql database with 3 users (owner, read and app)

### Setup Requirements

* Treebase.tar.gz of tomcat_tb folder.
* Treebase.war (java artifact)

### Installation

To install Treebase with Puppet:

 1. Apply the role::treebase class to a server
 2. Manually copy the tomcat_tb/* to /var/lib/tomcat6/
 3. Change the password of the postgres user
```
   $ su - postgres
   $ psql
   $ ALTER USER postgres WITH ENCRYPTED PASSWORD 'changeme';  
``` 

 4. Import the postgres database
```
   $ pg_restore -h localhost -U postgres -W <postgress_dump> -d treebase_app -v -c
```   

 5. Restart tomcat6.

## Usage
class { 'role_treebase' :
  $postgresql_dbname    => "treebase",
  $postgresql_username  => "treebase_app",
  $postgresql_password  => "changeme",
  $treebase_owner       => "treebase_owner",
  $treebase_read        => "treebase_read",
  $treebase_url         => "10.42.1.222/treebase-web",
}

## Reference
role_treebase is the only class in this module. Depends on the following modules:

## Limitations
Only supported/tested OS: ubuntu LTS 14.04

## Development
Feel free to submit pull requests.

## TODO
* Add vscrepo to auto deploy treebase-web and war artifact.
