#!/bin/ksh
###############################################################################
#
# This script is used to collect data for 
# 'MustGather: Performance, Hang or High CPU Issues on AIX'
#
# ./aixperf.sh [PID(s)_of_the_problematic_JVM(s)_separated_by_spaces]
#
SCRIPT_VERSION=2016.02.03
#
###############################################################################
#                        #
# Variables              #
#                        #
##########################
SCRIPT_SPAN=240          # How long the whole script should take. Default=240
JAVACORE_INTERVAL=30    # How often javacores should be taken. Default=120  
VMSTAT_INTERVAL=5        # How often vmstat data should be taken. Default=5
TPROF_SPAN=240            # How long tprof should collect data. Default=60
############################################################################### 
# * All values are in seconds.                                                  
# * All the 'INTERVAL' values should divide into the 'SCRIPT_SPAN' by a whole   
#   integer to obtain expected results.                                         
# * Setting any 'INTERVAL' too low (especially JAVACORE) can result in data     
#   that may not be useful towards resolving the issue.  This becomes a problem 
#   when the process of collecting data obscures the real issue.                
################################################################################
if [ $# -eq 0 ]
then
echo "$0 : Unable to find required PID argument.  Please rerun the script as follows:"
echo "$0 : ./aixperf.sh [PID(s)_of_the_problematic_JVM(s)_separated_by_spaces]"
exit 1
fi
##########################
# Create output files    #
#                        #
##########################
# Create the screen.out and put the current date in it.
echo > screen.out
date >> screen.out

# Starting up
print $(date) "MustGather>> aixperf.sh script starting..." | tee -a screen.out
print $(date) "MustGather>> Script version:  $SCRIPT_VERSION." | tee -a screen.out

# Display the PIDs which have been input to the script
for i in $*
do
	print $(date) "MustGather>> PROBLEMATIC_PID is:  $i" | tee -a screen.out
done

# Display the being used in this script
echo $(date) "MustGather>> SCRIPT_SPAN = $SCRIPT_SPAN" | tee -a screen.out
echo $(date) "MustGather>> JAVACORE_INTERVAL = $JAVACORE_INTERVAL" | tee -a screen.out
echo $(date) "MustGather>> VMSTAT_INTERVAL = $VMSTAT_INTERVAL" | tee -a screen.out
echo $(date) "MustGather>> TPROF_SPAN = $TPROF_SPAN" | tee -a screen.out

# Collect the user currently executing the script
echo $(date) "MustGather>> Collecting user authority data..." | tee -a screen.out
date > whoami.out
whoami >> whoami.out 2>&1
echo $(date) "MustGather>> Collection of user authority data complete." | tee -a screen.out
 
# Create some of the output files with a blank line at top
print $(date) "MustGather>> Creating output files..." | tee -a screen.out
echo > netstat.out
echo > vmstat.out
echo > ps.out
echo > tprof.out
print $(date) "MustGather>> Output files created:" | tee -a screen.out
print $(date) "MustGather>>      netstat.out" | tee -a screen.out
print $(date) "MustGather>>      vmstat.out" | tee -a screen.out
print $(date) "MustGather>>      ps.out" | tee -a screen.out
print $(date) "MustGather>>      tprof.out" | tee -a screen.out
################################################################################
#                       # 
# Start collection of:  # 
#  * netstat x2         # 
#  * ps x2              # 
#  * vmstat             # 
#  * tprof              #
#  * javacores          #
#                       # 
######################### 

# Collect the first netstat: date at the top, data, and then a blank line
print $(date) "MustGather>> Collecting the first netstat snapshot..." | tee -a screen.out
date >> netstat.out
netstat -an >> netstat.out 2>&1
echo >> netstat.out
print $(date) "MustGather>> First netstat snapshot complete." | tee -a screen.out

# Collect the first ps: date at the top, data, and then a blank line
print $(date) "MustGather>> Collecting the first ps snapshot..." | tee -a screen.out
date >> ps.out
ps avwwwg >> ps.out 2>&1
echo >> ps.out
print $(date) "MustGather>> First ps snapshot complete." | tee -a screen.out


# Start the colletion of vmstat data.
# It runs in the background so that other tasks can be completed while this runs.
print $(date) "MustGather>> Starting collection of vmstat data..." | tee -a screen.out
date >> vmstat.out
vmstat $VMSTAT_INTERVAL `expr $SCRIPT_SPAN / $VMSTAT_INTERVAL + 1` >> vmstat.out 2>&1 &
print $(date) "MustGather>> Collection of vmstat data started." | tee -a screen.out

# Start the collection of tprof data.
# It runs in the background so that other tasks can be completed while this runs.
print $(date) "MustGather>> Starting collection of tprof data..." | tee -a screen.out
date >> tprof.out
# Calculate TPROF_ARGS
# First, check if environment is SMT capable.  If so, proceed to next check; if not, set args without -R option
# Next, check if OS is 32 bit.  If so, set args without -R option (-R is not supported on 32 bit); if not, set args with -R option.
if  /usr/sbin/smtctl >/dev/null 2>&1; then
        KERTYPE=`getconf KERNEL_BITMODE`
        if [ "$KERTYPE" = 32 ]; then
                print $(date) "MustGather>> TPROF_ARGS set to -skex; SMT capable but 32 bit environment." | tee -a screen.out
				TPROF_ARGS="-skex"
        else
                print $(date) "MustGather>> TPROF_ARGS set to -Rskex; SMT capable and NOT a 32 bit environment." | tee -a screen.out
				TPROF_ARGS="-Rskex"
        fi
else
        print $(date) "MustGather>> TPROF_ARGS set to -skex; Not SMT capable." | tee -a screen.out
		TPROF_ARGS="-skex"
fi
LDR_CNTRL=MAXDATA=0x80000000 tprof $TPROF_ARGS sleep $TPROF_SPAN >> tprof.out 2>&1 &
print $(date) "MustGather>> Collection of tprof data started." | tee -a screen.out


# Start collection of javacores.
# Loop the appropriate number of times, pausing for the given amount of time, and iterate through each supplied PID.
n=1
m=`expr $SCRIPT_SPAN / $JAVACORE_INTERVAL`
while [ $n -le $m ]
do
	print $(date) "MustGather>> Collecting javacores..." | tee -a screen.out
	for i in $*
	do
		kill -3 $i >> screen.out 2>&1
		print $(date) "MustGather>> Collected a javacore for PID $i." | tee -a screen.out

	done
	print $(date) "MustGather>> Continuing to collect data for $JAVACORE_INTERVAL seconds..." | tee -a screen.out
	sleep $JAVACORE_INTERVAL
	n=`expr $n + 1`
done

# Collect the final javacore(s).
print $(date) "MustGather>> Collecting final javacore..." | tee -a screen.out
for i in $*
do
	kill -3 $i >> screen.out 2>&1
	print $(date) "MustGather>> Collected the final javacore for PID $i." | tee -a screen.out
done


# Collect the final ps
print $(date) "MustGather>> Collecting the final ps snapshot..." | tee -a screen.out
date >> ps.out
ps avwwwg >> ps.out 2>&1
print $(date) "MustGather>> Final ps snapshot complete." | tee -a screen.out

# Collect a final netstat
print $(date) "MustGather>> Collecting the final netstat snapshot..." | tee -a screen.out
date >> netstat.out
netstat -an >> netstat.out 2>&1
print $(date) "MustGather>> Final netstat snapshot complete." | tee -a screen.out
################################################################################
#                       # 
# Other data collection # 
#                       # 
######################### 
print $(date) "MustGather>> Collecting other data.  This may take a few moments..." | tee -a screen.out

/usr/sbin/emgr -lv3 > emgr-lv3.out 2>&1
oslevel -s > oslevel-s.out 2>&1
lslpp -la > lslpp-la.out 2>&1
instfix -i > instfix-i.out 2>&1
prtconf > prtconf.out 2>&1
lparstat -i > lparstat-i.out 2>&1
lsattr -El sys0 > lsattr.out 2>&1
df > df.out 2>&1
errpt -a > errpt.out 2>&1

print $(date) "MustGather>> Collected other data." | tee -a screen.out
################################################################################
#                       # 
# Compress & Cleanup    # 
#                       # 
######################### 
# Brief pause to make sure all data is collected.
print $(date) "MustGather>> Preparing for packaging and cleanup..." | tee -a screen.out
sleep 5

# Build a string to contain all the file names
FILES_STRING="netstat.out vmstat.out ps.out sleep.prof screen.out tprof.out emgr-lv3.out oslevel-s.out lslpp-la.out instfix-i.out prtconf.out lparstat-i.out lsattr.out whoami.out df.out errpt.out"

# Tar/GZip the output files together
print $(date) "MustGather>> Compress output files into aixperf_RESULTS.tar.gz"
tar -cvf aixperf_RESULTS.tar $FILES_STRING
gzip aixperf_RESULTS.tar

# Clean up the output files now that they have been tar/gz'd.
print $(date) "MustGather>> Remove the temporary output files as they have now been added to the aixperf_RESULTS.tar.gz file."
rm $FILES_STRING

print $(date) "MustGather>> Output files removed."
print $(date) "MustGather>> aixperf.sh script complete."
echo
print $(date) "MustGather>> Output files are contained within ---->   aixperf_RESULTS.tar.gz.   <----"
print $(date) "MustGather>> The javacores that were created are NOT included in the aixperf_RESULTS.tar.gz."
print $(date) "MustGather>> Check the <profile_root> for the javacores."
print $(date) "MustGather>> Be sure to submit aixperf_RESULTS.tar.gz, the javacores, and the server logs as noted in the MustGather."
################################################################################