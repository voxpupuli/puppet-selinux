# selinux

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Defined Types](#defined-types)
7. [Development - Guide for contributing to the module](#development)
8. [Authors](#authors)

## Overview

This class manages SELinux on RHEL based systems.

## Requirements

* Puppet-3.x or later
* Facter 1.7.0 or later
* Ruby-1.9.3 or later (Support for Ruby-1.8.7 is not guaranteed. YMMV).

## Module Description

This module will configure SELinux and/or deploy SELinux based modules to running system.

Requires puppetlabs/stdlib
[https://github.com/puppetlabs/puppetlabs-stdlib]

## Usage

Parameters:

 * `$mode` (enforced|permissive|disabled) - sets the operating state for SELinux.
 * `$type` (targeted|minimum|mls) - sets the enforcement type.
 * `$manage_package` (boolean) - Whether or not to manage the SELinux management package.
 * `$package_name` (string) - sets the name of the selinux management package.

## Reference

### Basic usage

```puppet
include selinux
```

This will include the module and allow you to use the provided defined types, but will not modify existing SELinux settings on the system.

### More advanced usage

```puppet
class { selinux:
  mode => 'enforcing',
  type => 'targeted',
}
```

This will include the module and manage the SELinux mode (possible values are `enforcing`, `permissive`, and `disabled`) and enforcement type (possible values are `target`, `minimum`, and `mls`). Note that disabling SELinux requires a reboot to fully take effect. It will run in `permissive` mode until then.

### Deploy a custom module

```puppet
selinux::module { 'resnet-puppet':
  ensure => 'present',
  source => 'puppet:///modules/site_puppet/site-puppet.te',
}
```

### Set a boolean value

```puppet
selinux::boolean { 'puppetagent_manage_all_files': }
```

## Defined Types
* `boolean` - Set seboolean values
* `fcontext` - Define fcontext types and equals values
* `module` - Manage an SELinux module
* `permissive` - Set a context to `permissive`.
* `port` - Set selinux port context policies


## Development

## Authors
James Fryman <james@fryman.io>
