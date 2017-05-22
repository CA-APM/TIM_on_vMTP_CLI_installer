# TIM_on_vMTP_CLI_Installer rel1.1-b7

**Purpose**: Enables an admin user to perform a command line installation of the TIM for MTP on a vMTP installation  
  _by Mertin, Joerg_

The installerScript.sh will install the regular TIM for MTP .image files
through the command line onto a vMTP installation

## Supported APM versions
So far - the installerScript has been tested with TIM for MTP versions
10.5.0 and 10.5.1. However, as this script uses the "official"
scripts, other versions should work too.

## Installation Instructions

#### Prerequisites

User must have root-rights (sudo will do).
From the CA support Download site, download the corresponding TIM
Version that is to be installed (file format will be
GEN02164348E.tar), and extract the CentOS 6.x files required for
installation.

- tim-mtp-Linux-el6-x64-[apm-version].image
- tim-mtp-requisites-Linux-el6-x64-[apm-version].image


#### Limitations

The script will only work on vMTP (10.6, 11.0.x)!


#### Actions

the functionality of the script is defined by the invoqed action

- install: Will install pre-requisits and tim software. The CLI
  installer will not install the system nor the installonce packages.

- remove: will remove all instances of TIM and files, except the basic
installonce files that are installed with the MTP, so one can
re-install the TIM without needing the installonce files. The existing
TIM configuration files will be left in place.

- check: Will list the installed tim for mtp packages


#### Installation

Place all the required files into the same directory.
Example would be:
```
[root@localhost CLI_TIM_10.5.1]# ls -p
installerScripts.sh
tim-mtp-Linux-el6-x64-10.5.1.8.990101-b62c8d4e85e5ab5a33aef03fee0bbb86dfc7774d.image
tim-mtp-requisites-Linux-el6-x64-10.5.1.8.990101-b62c8d4e85e5ab5a33aef03fee0bbb86dfc7774d.image
```

then execute the installer-script with install (for installing the TIM
files), with remove (for removing the TIM files) ro with check (to
list the detected tim for mtp components).
```
$ sudo ./installerScripts.sh 
[sudo] password for jmertin: 


===============================================================================
== 2017-05-19 @ 18:00:51 root@titan - installerScripts.sh version 1.1-b5 ======
===============================================================================

 Usage: ./installerScripts.sh [ACTION]

 ACTION:
     install  - installs the TIM software on a vMTP
     remove   - removes the installed TIM from the vMTP
     check    - List installed TIM for MTP components

     For the installation, the script needs the files:
     - tim-mtp-requisites-Linux-el6-x64-*.image
     - tim-mtp-Linux-el6-x64-*.image

     downloaded from the CA Support/Download section and
     placed in the same folder as the installerScripts.sh

 Restrictions:
     It will not install the machine-settings nor the system-settings image!
     It will only install on vMTP 10.6 or 11.x!

FATAL:  An error occured in "installerScripts()". Bailing out...
ERRMSG: *** Error - No action provided!
```





## License
This field pack is provided under the [Eclipse Public License, Version
1.0](https://github.com/CA-APM/fieldpack.apm-scripts/blob/master/LICENSE).

## Support
This document and associated tools are made available from CA
Technologies as examples and provided at no charge as a courtesy to
the CA APM Community at large. This resource may require modification
for use in your environment. However, please note that this resource
is not supported by CA Technologies, and inclusion in this site should
not be construed to be an endorsement or recommendation by CA
Technologies. These utilities are not covered by the CA Technologies
software license agreement and there is no explicit or implied
warranty from CA Technologies. They can be used and distributed freely
amongst the CA APM Community, but not sold. As such, they are
unsupported software, provided as is without warranty of any kind,
express or implied, including but not limited to warranties of
merchantability and fitness for a particular purpose. CA Technologies
does not warrant that this resource will meet your requirements or
that the operation of the resource will be uninterrupted or error free
or that any defects will be corrected. The use of this resource
implies that you understand and agree to the terms listed herein.

Although these utilities are unsupported, please let us know if you
have any problems or questions by adding a comment to the CA APM
Community Site area where the resource is located, so that the
Author(s) may attempt to address the issue or question.

Unless explicitly stated otherwise this field pack is only supported
on the same platforms as the regular APM Version. See [APM
Compatibility Guide](http://www.ca.com/us/support/ca-support-online/product-content/status/compatibility-matrix/application-performance-management-compatibility-guide.aspx).



### Support URL
https://github.com/CA-APM/TIM_on_vMTP_CLI_installer/issues


## Categories
Reporting Server Monitoring
