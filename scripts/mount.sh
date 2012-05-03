#!/bin/sh

home=/Users/AChitale/work
mount -t smbfs //achitale@subzero.ariba.com/abperf ${home}/setup/mnts/subzero
mount -t smbfs //achitale@amana.ariba.com/idcrc ${home}/setup/mnts/amana   ## rcmirror/
mount -t smbfs //achitale@in-blrfs1.ariba.com/Software ${home}/setup/mnts/in-blrfs1
mount -t nfs maytag.ariba.com:export ${home}/setup/mnts/maytag            ## /home/rc/archive/builds
