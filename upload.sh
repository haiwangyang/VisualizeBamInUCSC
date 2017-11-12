#!/bin/bash
ftp -nv helix.nih.gov <<!
user anonymous
prompt off
bin
cd /pub/temp
mput $1
close
!
