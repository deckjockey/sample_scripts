#!/bin/sh
RDIR=`dirname $0`

OUTPUT=$($1/java -cp $RDIR/jmxquery.jar org.nagios.JMXQuery -U service:jmx:rmi:///jndi/rmi://localhost:8089/jmxrmi -O java.lang:type=Threading -A ThreadCount -K "" | cut -d '=' -f2)
HEAPSIZE=`echo $OUTPUT`
echo "Thread Count=$HEAPSIZE"

OUTPUT=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -oP '\"region\"[[:space:]]*:[[:space:]]*\"\K[^\"]+')
REGIONNAME=`echo $OUTPUT`
echo "RegionName=$REGIONNAME"

OUTPUT=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCEID=`echo $OUTPUT`
echo "InstanceID=$INSTANCEID"

OUTPUT=$(aws --version)

echo "Running AWS cloudwatch command... "
OUTPUT=$(aws cloudwatch put-metric-data --metric-name CurrentThreadCount --namespace JMX --unit Count --value $HEAPSIZE --dimensions InstanceId=$INSTANCEID --region $REGIONNAME)
AWSCOMMAND=`echo $OUTPUT`
echo "AWS Cloudwatch PUT Command executed $AWSCOMMAND"
echo $(date)
