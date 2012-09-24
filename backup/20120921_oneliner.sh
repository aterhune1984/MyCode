#!/bin/bash

INET(){
hname=`hostname -s`;ifconfig | egrep -B1 "inet addr" | grep -v -B1 "127.0.0.1" |awk ' { if (/^eth|^bond/) print $1; else if(/inet addr/) print "- " $2 }' | sed ':a;N;$!ba;s/\n/ /g;s/addr://g;s/eth/\n'"$hname - "'eth/g;s/bond/\n'"$hname - "'bond/g;';
echo;
};

MEMUSAGE(){ 
bufmem=$(free -m | grep "buffers/cache" | awk '{print $4}');totmem=$(free -m | grep Mem: | awk '{print $2}');echo -n "Memory Usage:"; calc=$(echo "100 - ($bufmem / $totmem * 100)" | bc -l | cut -d. -f1); echo $calc% ; echo -n "Total memory: $totmem    buf/cache free: $bufmem";echo;
echo;
};


APACHE_CHECK() {
netstat -ntlp | grep [h]ttpd >/dev/null;
if [[ $? -eq 0 ]];then
httpd -l | grep prefork > /dev/null;
if [[ $? -eq 0 ]];then
sl=0;itter=1;i=0;echo "Please wait...";echo "" > /tmp/apachecalc.tmp;while [ $i -lt $itter ]; do SUM=0; COUNT=0; for x in `ps -ylC httpd | tail -n+3 |grep -v defun| awk '{print $8}'`; do SUM=$(( $SUM + $x )); COUNT=$(( $COUNT + 1 )); done; if [[ $COUNT -ne 0 ]]; then MEMPP=$(( $SUM / $COUNT / 1024 )); else MEMPP=0; fi; FREERAM=$(( `free | tail -2 | head -1 | awk '{print $4}'` / 1024 )); APACHERAM=$(( $SUM / 1024 )); APACHEMAX=$(( $APACHERAM + $FREERAM )); if [[ $MEMPP -ne 0 ]]; then echo $(( $APACHEMAX / $MEMPP )) >> /tmp/apachecalc.tmp; fi; i=$(( $i + 1 )); sleep $sl; done; echo "The Max Suggested Max_Clients:"; awk 'min=="" || $1 < min {min=$1} END{ print min}' /tmp/apachecalc.tmp; rm -f /tmp/apachecalc.tmp;
echo;
echo -n "Current MaxClients setting is:"
grep  ^MaxClients /etc/httpd/conf/httpd.conf | head -1  | awk '{print $2}';
echo;
echo "The number of apache children processes are:";ps -ef | grep [h]ttpd | grep -c [a]pache; echo "The number of root apache processes are:"; ps -ef | grep [h]ttpd | grep -c [r]oot;
echo;
echo "Apache was started on:";ps axo user,lstart,cmd | egrep -i 'started|[h]ttpd' | grep root | grep -v egrep; pid=$(ps axo pid,user,cmd | egrep -i 'started|[h]ttpd' | grep root | grep -v egrep| awk '{print $1}');user=$(cat /proc/$pid/loginuid);echo -n "The user that started apache last was: ";cat /etc/passwd | awk 'BEGIN {FS=":"} {print $3" "$1}' | grep "^$user" | awk '{print $2}' ; 
fi;
fi;
};

FTP_CHECK(){
netstat -ntlp | grep [f]tp > /dev/null;
if [[ $? -eq 0 ]]; then
echo "FTP server was started on:";ps axo user,lstart,cmd | egrep -i 'started|[f]tp' | grep root |grep [v]sftpd.conf | grep -v egrep; pid=$(ps axo pid,user,cmd | egrep -i 'started|[f]tp' | grep root | grep -v egrep| awk '{print $1}');user=$(cat /proc/$pid/loginuid);echo -n "The user that started the FTP server last was: ";cat /etc/passwd | awk 'BEGIN {FS=":"} {print $3" "$1}' | grep "^$user" | awk '{print $2}' ; 
fi;
echo;
};



ESTCON(){ 
for port in $(netstat -ntl |awk '{print $4}' |egrep ":80|:3306|:22|:21|:25|:443|:110"  | cut -d: -f2 | uniq); do echo "The top 5 offenders for port $port"; netstat -ant | grep ESTABLISHED | awk '$4 ~ /:'$port'$/ {print $5}' | perl -pe 's/^.*?(\d{1,3}(\.\d{1,3}){3}).*$/$1/' | sort | uniq -c | sort -n| tail -5 ;done;echo; 
};

CPUINFO(){ 
a=$(grep 'physical id' /proc/cpuinfo | sort -u | wc -l); b=$(grep 'core id' /proc/cpuinfo | sort -u | wc -l); c=$(echo "${a}*${b}" | bc); d=$(grep -c bogomips /proc/cpuinfo); echo -e "cpu sockets:\t\t$a \ncores per socket:\t$b \ntotal physical cores:\t$c \ntotal logical cores:\t$d"; echo -ne "hyperthreading:\t\t"; if [[ ${c} -eq 0 ]]; then echo 'N/A'; elif [[ ${c} -eq ${d} ]]; then echo 'OFF'; else echo 'ON'; fi;echo;
};

DISKSPACE(){
df | while read LINE; do
  if [ `echo $LINE | awk '{print NF}'` -eq 1 ]; then
    read NEXTLINE
    LINE="$LINE $NEXTLINE"
  fi
  echo $LINE
done | \
  grep -vE '^Filesystem|tmpfs|cdrom' | \
  awk '{print $4 " " $5 " " $6}' | \
  while read output; do 
    free=$(echo $output | awk '{print $1}')
    usep=$(echo $output | awk '{print $2}' | cut -d '%' -f1)
    fs=$(echo $output | awk '{print $3}')
    if [ $usep -gt 85 ]; then
      echo "$fs     $free free      $usep% used"
    fi
  done
echo
};

HIGHLOAD(){
echo;tot=$(grep -c bogomips /proc/cpuinfo);cur=$(awk '{print $1}' /proc/loadavg);toomuch=$(echo $cur / $tot | bc -l);if [[ $toomuch > 1.5 ]]; then echo "The load average is above 1.5* the number of cores, the top 10 CPU using processes are:"; ps -eo user,%cpu,%mem,rsz,args,pid,lstart|sort -rnk2|awk 'BEGIN {printf "%12s\t%s\t%s\t%s\t%s\n","USER","%CPU","%MEM","RSZ","COMMAND","PID","Started"}{printf "%12s\t%g'%'\t%g'%'\t%d MB\t%s\n",$1,$2,$3,$4/1024,$5}'|head -n10; else echo "Load is fine for this macine, Current is $cur";fi;echo;
}

LOGGEDIN(){
echo "Users logged in: ";echo -e 'User\tLOGIN@\tIDLE\tCOMMAND'; w -h|awk '{print $1"\t"$4"\t"$5"\t"$8}';echo;
};



IOPP(){
iousage=$(iostat | grep -A1 iowait | tail -1 | awk '{print $4}')
if [[ `echo $iousage` > 10 ]]; then 
echo "Please wait, collecting IO usage..."
echo '
#!/usr/bin/env perl
# This program is part of Aspersa (http://code.google.com/p/aspersa/)

=pod

=head1 NAME

iodump - Compute per-PID I/O stats for Linux when iotop/pidstat/iopp are not available.

=head1 SYNOPSIS

Prepare the system:

  dmesg -c
  /etc/init.d/klogd stop
  echo 1 > /proc/sys/vm/block_dump

Start the reporting:

  while true; do sleep 1; dmesg -c; done | perl iodump
  CTRL-C

Stop the system from dumping these messages:

  echo 0 > /proc/sys/vm/block_dump
  /etc/init.d/klogd start

=head1 AUTHOR

Baron Schwartz

=cut

use strict;
use warnings FATAL => '\'all\'';
use English qw(-no_match_vars);
use sigtrap qw(handler finish untrapped normal-signals);

my %tasks;

my $oktorun = 1;
my $line;
while ( $oktorun && (defined ($line = <>)) ) {
   my ( $task, $pid, $activity, $where, $device );
   ( $task, $pid, $activity, $where, $device )
      = $line =~ m/(\S+)\((\d+)\): (READ|WRITE) block (\d+) on (\S+)/;
   if ( !$task ) {
      ( $task, $pid, $activity, $where, $device )
         = $line =~ m/(\S+)\((\d+)\): (dirtied) inode \(.*?\) (\d+) on (\S+)/;
   }
   if ( $task ) {
      my $s = $tasks{$pid} ||= { pid => $pid, task => $task };
      ++$s->{lc $activity};
      ++$s->{activity};
      ++$s->{devices}->{$device};
   }
}

printf("%-15s %10s %10s %10s %10s %10s %s\n",
   qw(TASK PID TOTAL READ WRITE DIRTY DEVICES));
foreach my $task (
   reverse sort { $a->{activity} <=> $b->{activity} } values %tasks
) {
   printf("%-15s %10d %10d %10d %10d %10d %s\n",
      $task->{task}, $task->{pid},
      ($task->{'\'activity\''}  || 0),
      ($task->{'\'read\''}      || 0),
      ($task->{'\'write\''}     || 0),
      ($task->{'\''dirty'\''}     || 0),
      join('\', \'', keys %{$task->{devices}}));
}

sub finish {
   my ( $signal ) = @_;
   if ( $oktorun ) {
      print STDERR "# Caught SIG$signal.\n";
      $oktorun = 0;
   }
   else {
      print STDERR "# Exiting on SIG$signal.\n";
      exit(1);
   }
}
' > /home/rack/iousage.pl


dmesg -c > /dev/null
echo 1 > /proc/sys/vm/block_dump
sleep 5
dmesg | perl /home/rack/iousage.pl
echo 0 > /proc/sys/vm/block_dump
dmesg -c > /dev/null
rm -f /home/rack/iousage.pl;

else echo "IO usage is not high, current is $iousage";
fi
}






#MAIN PROGRAM STARTS HERE!

#Ask if you do not want to run the script
read -t 2 -p "Run the Diagnostic script? [Y/n]..." input
if [[ ! -z $input && $input == n ]]; then exit 0; fi



#check memory usage to see if this is okay
val=$(MEMUSAGE | grep % | cut -d: -f2 | cut -d% -f1);
if [[ $val -lt 98 ]]; then
INET;MEMUSAGE;HIGHLOAD;IOPP;APACHE_CHECK;FTP_CHECK;ESTCON;CPUINFO;DISKSPACE;LOGGEDIN;
fi;
