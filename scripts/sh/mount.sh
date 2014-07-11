#!/bin/sh

mount -t smbfs //achitale@amana.ariba.com/idcrc /mnts/idcrc 
mount -t smbfs //achitale@maytag.ariba.com/export/home/rc /mnts/rc
mount -t smbfs //achitale@maytag.ariba.com/export/home/achitale /mnts/ajnfs
mount -t smbfs //achitale@achitale2.dhcp.blr6.sap.corp/share /mnts/windows ## windows d:/achitale/shared
mount -t smbfs //i079016@INLM50857003A.dhcp.blr6.sap.corp/i079016 /mnts/macmini ## MAC mini
