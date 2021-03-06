#!/usr/bin/python
####################STUFF TO CALCULATE MONTHLY VALUES########################## 
def m(values):  
    size = len(values)  
    summ = 0.0  
    for n in range(0, size):  
        summ += values[n]  
    return summ / size;  
  
# Calculate standard deviation  
def SD(values, mean):
    from math import sqrt  
    size = len(values)  
    summ = 0.0  
    for n in range(0, size):  
        summ += sqrt((values[n] - mean)**2)  
    return sqrt((1.0/(size-1))*(summ/size))  
    
def fulllist(nf,method,field,grepv):
    from subprocess import Popen
    from subprocess import PIPE
    from glob import glob
    arrayfield=[]
# import needs to be   method='-r'
#    mean=''
    sarlist = glob("/var/log/sa/sa[0123]*")
    for newfile in sarlist:                                   
        output=Popen(["sar",method, "-f", newfile], stdout=PIPE).communicate()[0]
        for line in output.split('\n'):
            if line == '' or 'Average' in line or grepv in line or 'Linux' in line or 'RESTART' in line:  
                pass
            else:
		nf = line.split()
		if field == '0':
		    newfield=nf[0]
		if field == '1':
		    newfield=nf[1]
                if field == '2':
		    newfield=nf[2]
                if field == '3':
		    newfield=nf[3]
		if field == '4':
		    newfield=nf[4]
		if field == '5':
		    newfield=nf[5]
		if field == '6':
		    newfield=nf[6]
                if field == '7':
		    newfield=nf[7]
                if field == '8':
		    newfield=nf[8]
		if field == '9':
		    newfield=nf[9]
		if field == '10':
		    newfield=nf[10]
		if field == '11':
		    newfield=nf[11]
                if field == '12':
		    newfield=nf[12]
                if field == '13':
		    newfield=nf[13]
		if field == '14':
		    newfield=nf[14]
                arrayfield.append(float(newfield))
    return arrayfield
#######################END MONTHLY CALCULATION VALUES########################
                    
def singlelist(nf,method,field,time,ampm,grepv):
    from datetime import datetime
    from subprocess import Popen
    from subprocess import PIPE
    output=Popen(["sar",method], stdout=PIPE).communicate()[0]
    date=datetime.now()
    date=str(date).split()[0]
    listtimeval=[]
    for line in output.split('\n'):
        if line == '' or 'Average' in line or grepv in line or 'Linux' in line or 'RESTART' in line:
            pass
        else:
            nf = line.split()
	    if field == '0':
            	newfield=nf[0]
            if field == '1':
                newfield=nf[1]
            if field == '2':
                newfield=nf[2]
            if field == '3':
                newfield=nf[3]
            if field == '4':
                newfield=nf[4]
            if field == '5':
                newfield=nf[5]
            if field == '6':
                newfield=nf[6]
            if field == '7':
                newfield=nf[7]
            if field == '8':
                newfield=nf[8]
            if field == '9':
                newfield=nf[9]
            if field == '10':
                newfield=nf[10]
            if field == '11':
                newfield=nf[11]
            if field == '12':
                newfield=nf[12]
            if field == '13':
                newfield=nf[13]
            if field == '14':
                newfield=nf[14]
            if time == '0':
                newtime=nf[0]
            if time == '1':
                newtime=nf[1]
            if time == '2':
                newtime=nf[2]
            if time == '3':
                newtime=nf[3]
            if time == '4':
                newtime=nf[4]
            if time == '5':
                newtime=nf[5]
            if time == '6':
                newtime=nf[6]
            if time == '7':
                newtime=nf[7]
            if time == '8':
                newtime=nf[8]
            if time == '9':
                newtime=nf[9]
            if time == '10':
                newtime=nf[10]
            if time == '11':
                newtime=nf[11]
            if time == '12':
                newtime=nf[12]
            if time == '13':
                newtime=nf[13]
            if time == '14':
                newtime=nf[14]
	    if ampm == '0':
                newampm=nf[0]
            if ampm == '1':
                newampm=nf[1]
            if ampm == '2':
                newampm=nf[2]
            if ampm == '3':
                newampm=nf[3]
            if ampm == '4':
                newampm=nf[4]
            if ampm == '5':
                newampm=nf[5]
            if ampm == '6':
                newampm=nf[6]
            if ampm == '7':
                newampm=nf[7]
            if ampm == '8':
                newampm=nf[8]
            if ampm == '9':
                newampm=nf[9]
            if ampm == '10':
                newampm=nf[10]
            if ampm == '11':
                newampm=nf[11]
            if ampm == '12':
                newampm=nf[12]
            if ampm == '13':
                newampm=nf[13]
            if ampm == '14':
                newampm=nf[14]
            listtimeval.append((newtime + " "+ newampm + "," + newfield).split(','))
    updatelist= [ [str(date) + " " +x[0],x[1]] for x in listtimeval]
    return updatelist

def fields(method):
    if method == '-r':
            nf = ('','','','','','','','','')
    if method == '-q':
            nf = ('','','','','','','')
    if method == '-u':
            nf = ('','','','','','','','')
    return nf    

def test(val,compmath,logic):
    import subprocess
    from datetime import datetime, timedelta
    from os import popen
    min_to_sub=1
    min_to_add=1
    files=[]
    for x in val:
        if logic == 'add':
            if float(x[1]) > compmath:
#                print "Value in sar for today: " + str(x[1])
#                print "Monthly Average Plus the SD: " + str(compmath)
                dt=datetime.strptime(x[0],"%Y-%m-%d %I:%M:%S %p")
		edt=dt+timedelta(minutes=min_to_add)
		bdt=dt-timedelta(minutes=min_to_sub)
                bdt=bdt.strftime("%Y-%m-%d %I:%M:%S %p")
                edt=edt.strftime("%Y-%m-%d %I:%M:%S %p")
                o=popen("find /var/log/rs-sysmon/ -newermt '%s' \! -newermt '%s' 2>/dev/null | grep -v '/var/log/rs-sysmon$'" % (bdt,edt))
                for i in o.readlines():
                    files.append(i.rstrip('\n'))
            elif float(x[1]) < compmath:
                pass
        if logic == 'sub':
            if float(x[1]) < compmath:
#                print "Value in sar for today: " + str(x[1])
#                print "Monthly Average minus the SD: " + str(compmath)
                dt=datetime.strptime(x[0],"%Y-%m-%d %I:%M:%S %p")
		edt=dt+timedelta(minutes=min_to_add)
		bdt=dt-timedelta(minutes=min_to_sub)
                bdt=bdt.strftime("%Y-%m-%d %I:%M:%S %p")
                edt=edt.strftime("%Y-%m-%d %I:%M:%S %p")
                o=popen("find /var/log/rs-sysmon/ -newermt '%s' \! -newermt '%s' 2>/dev/null | grep -v '/var/log/rs-sysmon$'" % (bdt,edt))
                for i in o.readlines():
                    files.append(i.rstrip('\n'))
            elif float(x[1]) > compmath:
                pass
    return files

def comp(logic,mean,x):
    if logic == 'add':
        compmath=mean+x+x+x+x+x
    if logic == 'sub':
        compmath=mean-x-x-x-x-x
    return compmath

def printfiles(files,filestoprint,grepbegin,grepend):
    for x in files:
        cpu=[]
        if filestoprint in x:
            with open(x) as f:
                in_cpu=False
                lineno=0
                for line in f:
                    line=line.strip()
		    if lineno == 0:
                        cpu.append(line)
                        lineno=lineno + 1
                    elif grepbegin in line:
                        in_cpu=True
                        cpu.append(line)
                        lineno=lineno + 1
                    elif grepend in line:
                        lineno=lineno + 1
                        break
                    elif in_cpu:
                        lineno=lineno + 1
                        cpu.append(line)
            for x in cpu:
                 print x
        
def mempercent():
    method='-r' #METHON IN SAR
    nf=fields(method)
    field='4'  # COLUMN THAT WE ARE WORKING WITH
    time='0'
    ampm='1'
    grepv='kbmemused'
    arrayfield=fulllist(nf,method,field,grepv)
    mean=m(arrayfield)
    x=SD(arrayfield,mean)
    logic='add' #determine wheather you are adding average plus sd or subtracting average minus sd
    compmath=comp(logic,mean,x) #set the compmath variable which is the value we are testing against
    val=singlelist(nf,method,field,time,ampm,grepv)#get list of todays dates/times and values of the column
    files=test(val,compmath,logic) #take the list, the value we are testing against, and wheather we are adding or subtracting the compmath value to/from val
    filestoprint='resources'
    grepbegin='Top 10 memory using processes'
    grepend='blahnothinthere'
    printfiles(files,filestoprint,grepbegin,grepend)

def cpuidle():
    method='-u'
    nf=fields(method)
    field='8'
    time='0'
    ampm='1'
    grepv='CPU'
    arrayfield=fulllist(nf,method,field,grepv)
    mean=m(arrayfield)
    x=SD(arrayfield,mean)
    logic='sub'
    compmath=comp(logic,mean,x)
    val=singlelist(nf,method,field,time,ampm,grepv)
    files=test(val,compmath,logic)
    filestoprint='resources'
    grepbegin='Top 10 cpu using processes'
    grepend='Top 10 memory using processes'
    printfiles(files,filestoprint,grepbegin,grepend)




mempercent()
cpuidle()
