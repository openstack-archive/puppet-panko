Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/tc/badges/puppet-panko.svg)](https://governance.openstack.org/tc/reference/tags/index.html)

<!-- Change things from this point on -->

panko
=======

#### Table of Contents

1. [Overview - What is the panko module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with panko](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Beaker-Rspec - Beaker-rspec tests for the project](#beaker-rpsec)
7. [Development - Guide for contributing to the module](#development)
8. [Contributors - Those with commits](#contributors)
9. [Release Notes - Release notes for the project](#release-notes)
10. [Repository - The project source code repository](#repository)

Overview
--------

The panko module is a part of [OpenStack](https://opendev.org/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects not part of the core software.  The module its self is used to flexibly configure and manage the events service for OpenStack.

Module Description
------------------

The panko module is a thorough attempt to make Puppet capable of managing the entirety of panko.  This includes manifests to provision region specific endpoint and database connections.  Types are shipped as part of the panko module to assist in manipulation of configuration files.

Setup
-----

**What the panko module affects**

* [Panko](https://docs.openstack.org/panko/latest/), the events service for OpenStack.

### Installing panko

    panko is not currently in Puppet Forge, but is anticipated to be added soon.  Once that happens, you'll be able to install panko with:
    puppet module install openstack/panko

### Beginning with panko

To utilize the panko module's functionality you will need to declare multiple resources.

Implementation
--------------

### panko

panko is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

Limitations
------------

* All the panko types use the CLI tools and so need to be ran on the panko node.

Beaker-Rspec
------------

This module has beaker-rspec tests

To run the tests on the default vagrant node:

```shell
bundle install
bundle exec rake acceptance
```

For more information on writing and running beaker-rspec tests visit the documentation:

* https://github.com/puppetlabs/beaker-rspec/blob/master/README.md

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://docs.openstack.org/puppet-openstack-guide/latest/

Contributors
------------

* https://github.com/openstack/puppet-panko/graphs/contributors

Release Notes
-------------

* https://docs.openstack.org/releasenotes/puppet-panko

Repository
----------

* https://opendev.org/openstack/puppet-panko
