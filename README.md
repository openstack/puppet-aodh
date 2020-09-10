Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/tc/badges/puppet-aodh.svg)](https://governance.openstack.org/tc/reference/tags/index.html)

<!-- Change things from this point on -->

AODH
====

#### Table of Contents

1. [Overview - What is the AODH module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with AODH](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Repository - The project source code repository](#repository)
8. [Contributors - Those with commits](#contributors)
9. [Release Notes - Release notes for the project](#release-notes)

Overview
--------

The AODH module is a part of [OpenStack](https://opendev.org/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects not part of the core software.  The module its self is used to flexibly configure and manage the Alarming service for OpenStack.

Module Description
------------------

The AODH module is a thorough attempt to make Puppet capable of managing the entirety of AODH.  This includes manifests to provision region specific endpoint and database connections.  Types are shipped as part of the AODH module to assist in manipulation of configuration files.

Setup
-----

**What the AODH module affects**

* [AODH](https://docs.openstack.org/aodh/latest/), the Alarming service for OpenStack.

### Installing AODH

    puppet module install openstack/aodh

### Beginning with AODH

To utilize the AODH module's functionality you will need to declare multiple resources.  This is not an exhaustive list of all the components needed, we recommend you consult and understand the [core OpenStack](https://docs.openstack.org) documentation.

Implementation
--------------

### AODH

AODH is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

Limitations
------------

* All the AODH types use the CLI tools and so need to be ran on the AODH node.

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://docs.openstack.org/puppet-openstack-guide/latest/

Repository
----------

* https://opendev.org/openstack/puppet-aodh/

Contributors
------------

* https://github.com/openstack/puppet-aodh/graphs/contributors

Release Notes
-------------

* https://docs.openstack.org/releasenotes/puppet-aodh/
