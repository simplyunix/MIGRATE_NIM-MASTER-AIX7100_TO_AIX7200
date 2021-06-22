# NIM SERVER AIX71_TO_AIX72_MIGRATION

## Table of contents
* [General info](#general-info)

## General info
How to migrated AIX NIM Master from AIX7100 to AIX7200
## Author
Sasi Chand
SC - Expert, Technical lead, architect or any combination of those
## Technologies
Project is created with:
* [Virtual I/O servers VML]
* [NFS]
* [NIM command line]
## Notes
* [RTFM]

## Setup
The first step requires that you download the latest AIX 7.2 ISO images from the IBM
Entitled Software Support (ESS) website (http://www304.ibm.com/servers/eserver/ess/index.wss)
NOTE: Remember to unzip the .ZIP iso File - Wired this! Don't ask me why!

On the VIOS server
$ ls -ltr /var/vio/VMLibrary

- AIX_v7.2_BASE_Install_7200-05-02-2113_DVD_1.iso
- AIX_v7.2_BASE_Install_7200-05-02-2113_DVD_2.iso

- $ mkvopt -name base_AIX72_TL5_CD1 -file /var/vio/VMLibrary/AIX_v7.2_BASE_Install_7200-05-02-2113_DVD_1.iso
- $ mkvopt -name base_AIX72_TL5_CD2 -file /var/vio/VMLibrary/AIX_v7.2_BASE_Install_7200-05-02-2113_DVD_2.iso

$ lsrep
- base_AIX72_TL5_CD1                                         2141 None            ro
- base_AIX72_TL5_CD2                                         4100 None            ro

Your call to use the HMC GUI or VIOS CLI. Add a Optical device to the LPAR in this case vhost10 on kapnim

On the VIOS
- $ lsmap -all

VTD = vhost10

- $ loadopt -vtd vhost10 -disk base_AIX72_TL5_CD1

On the NIM Master
- # cfgmgr
- # lsdev -Cc cdrom
- # cd0 Available  Virtual SCSI Optical Served by VIO Server
- # mount /cdrom
- # cat /cdrom/OSLEVEL
    OSLEVEL=7.2.0.0

We are ready to migrate:
---------------------------------------------------------------
# Notes
- For the LPARS with less than 4GB of memory we need to tweak a few things
- A minimum current memory requirement for AIX 7 with 7200-05 is 2 GB.
- AIX 7 with 7200-05 creates a 512 MB paging space (in the /dev/hd6 directory) for all new and complete overwrite installations.
- AIX Version 7.2 requires a minimum of 20 GB of physical disk space for a default installation
- # commit [Commit to apply any Software]
- remove iFix's if any [emgr]

# Now the Actual Migration tasks starts here
#-----------------------------------------------
- Boot to sms
- To boot off the cdrom
- Choose normal Boot mode

1. Enter 1 to define the system console
2. Enter 1 for English install
3. Choose the correct disk
>>> 2 Change/Show Installation Settings and Install
Choose 1 System Settings
Choose 3 >>> 3 Migration Install
Here choose the correct disk

4. Migration install
Choose to continue Install Choose 0

5. On the VIOS load the CD/DVD2
$ loadopt -f disk base_AIX72_TL5_CD2 -vtd vhost10
6. Press Enter now and the Migration will continue
