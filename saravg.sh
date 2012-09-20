#!/bin/bash
SARAVG(){
for avg in $(for file in $(ls /var/log/sa/sa[0123]*); do echo $file; done); do sar -$1 -f $avg| tail -1; done | awk '{totavg+=$'$2'} END {printf "%.3f", totavg/NR}'
}

cat << !

Select what option you would like the sar average for the month:

a.  %memused(taken for sar -r)
b.  kbmemfree(taken from sar -r)
c.  %user(taken from sar -u)
d.  %system(taken from sar -u)
e.  %iowait(taken from sar -u)
f.  %idle(taken from sar -u)
g.  pgpgin/s(taken from sar -B)
h.  pgpgout/s(taken from sar -B)
i.  majflt/s(taken from sar -B)
j.  ldavg-1(taken from sar -q)
k.  ldavg-15(taken from sar -q)
q.  quit
!

read -p "Please select an option to report on:" option

case $option in
	a) 
		echo -n "The average percentage memory used is: "
		SARAVG r 4
		echo "%"
		;;
	b)
		echo -n "The average kb of memory free is: "
		SARAVG r 2
		echo "kb"
		;;
	c)
		echo -n "The average USER CPU is: "
		SARAVG u 3
		echo "%"
		;;
	d)	
		echo -n "The average SYSTEM CPU is: " 
		SARAVG u 5
		echo "%"
		;;	
	e)	
		echo -n "The average IOWAIT is: "
		SARAVG u 6
		echo "%"
		;;
	f)	
		echo -n "The average IDLE % is : "
		SARAVG u 8
		echo "%"
		;;	
	g)	
		echo -n "The average pagein per second: " 
		SARAVG B 2
		echo "/s"
		;;
	h)
		echo -n "The average pageout per second: "
		SARAVG B 3
		echo "/s"
		;;
	i)
		echo -n "The averge number of Major faults(disk access) per second: "
		SARAVG B 5
		echo "/s"
		;;
	j)	
		echo -n "The average single minute load average value is: "
		SARAVG q 4
		echo
		;;	
	k)
		echo -n "The average fifteen minute load average value is: " 	
		SARAVG q 6
		echo
		;;
	q|Q)
		echo "quitting..."
		exit 0
		;;
	*)
		echo "You did not select a valid option... goodbye"
		;;
esac


