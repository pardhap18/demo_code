#!/bin/bash
# Name: archival-organization.sh
# Description: creates Yearly/Monthly Directories for archiving files/dirs.

# Set base Structure
BASEDEST=/home/user/test
# Set Level of organization wanted
#
YEAR=`date +%Y`
MONTH=`date +%m`
#DAY=`date +%d`  
#TIME=`date +%k%M`
#
# Create Directory Structure, Set Destination.
#
mkdir -p $BASEDEST/$YEAR/$MONTH/
DESTINATION=$BASEDEST/$YEAR/$MONTH/
# Set Current file Directory tO be archived
#
MAIN=/home/jake/archive_temp/*
# Archive Command
#
/usr/bin/rsync -ar --remove-source-files $MAIN $DESTINATION
