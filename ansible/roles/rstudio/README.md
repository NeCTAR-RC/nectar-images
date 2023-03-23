## rstudio

[![Build Status](https://travis-ci.org/Oefenweb/ansible-rstudio.svg?branch=master)](https://travis-ci.org/Oefenweb/ansible-rstudio) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-rstudio-blue.svg)](https://galaxy.ansible.com/list#/roles/4954)

Set up (the latest version of) [RStudio (IDE)](https://www.rstudio.com/products/rstudio/download/) in Debian-like systems.

#### Requirements

* `r-base` (will not be installed)

#### Variables

* `rstudio_version` [default: `1.0.44`]: Version to install
* `rstudio_install` [default: `[]`]: Additional packages to install (e.g. `r-base`)

## Dependencies

None

## Recommended

* `ansible-r` ([see](https://github.com/Oefenweb/ansible-r))

#### Example

```yaml
---
- hosts: all
  roles:
    - rstudio
```

#### License

MIT

#### Author Information

Mischa ter Smitten

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Oefenweb/ansible-rstudio/issues)!
