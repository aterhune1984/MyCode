#!/bin/bash

DATE=`date +"%F-%T"`
LOGDIR=/var/log/rs-sysmon
HOURRETENTION=48


#
# ps.log
ps auxf > $LOGDIR/ps.log.$DATE

#
# mysql.log
mysql -t -e "show full processlist;" > $LOGDIR/mysql.log.$DATE

#
# netstat.log
netstat -an > $LOGDIR/netstat.log.$DATE

#
# resource.log
w > $LOGDIR/resource.log.$DATE
echo -e "\n\n\n" >> $LOGDIR/resource.log.$DATE
free >> $LOGDIR/resource.log.$DATE
echo -e "\n\n\n" >> $LOGDIR/resource.log.$DATE
/etc/init.d/httpd fullstatus >> $LOGDIR/resource.log.$DATE
echo -e "\n\n\n" >> $LOGDIR/resource.log.$DATE
top -bn 1 >> $LOGDIR/resource.log.$DATE


#
# Clean-up
tmpwatch --mtime $HOURRETENTION $LOGDIR
