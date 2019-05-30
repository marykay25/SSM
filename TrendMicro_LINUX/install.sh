#!/bin/bash
#
if [ -z "$BASH" ]
then
            exec /bin/bash "$0" "$@"
    fi


REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`

aws configure set region $REGION

ACTIVATIONURL=`aws ssm get-parameters --name DSMActivationURL  --query 'Parameters[*].Value' --output text`
MANAGERURL=`aws ssm get-parameters --name DSMManagerURL  --query 'Parameters[*].Value' --output text`
TENANTID=`aws ssm get-parameters --name DSMTenantID --query 'Parameters[*].Value' --output text`
TOKEN=`aws ssm get-parameters --name DSMTokenID --query 'Parameters[*].Value' --output text`

CURLOPTIONS='--silent --tlsv1.2'
linuxPlatform='';
isRPM='';

if type curl >/dev/null 2>&1; then
  curl $MANAGERURL/software/deploymentscript/platform/linuxdetectscriptv1/ -o /tmp/PlatformDetection $CURLOPTIONS --insecure

  if [ -s /tmp/PlatformDetection ]; then
      . /tmp/PlatformDetection
      platform_detect

      if [[ -z "${linuxPlatform}" ]] || [[ -z "${isRPM}" ]]; then
         echo Unsupported platform is detected
         logger -t Unsupported platform is detected
         false
      else
         echo Downloading agent package...
         if [[ $isRPM == 1 ]]; then package='agent.rpm'
         else package='agent.deb'
         fi
         curl $MANAGERURL/software/agent/$linuxPlatform -o /tmp/$package $CURLOPTIONS --insecure

         echo Installing agent package...
         if [[ $isRPM == 1 && -s /tmp/agent.rpm ]];
         then
           rpm -ihv /tmp/agent.rpm
         elif [[ -s /tmp/agent.deb ]];
         then
           dpkg -i /tmp/agent.deb
         else
           echo Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
           echo logger -t Failed to download the agent package. Please make sure the package is imported in the Deep Security Manager
           false
         fi
      fi
  else
     echo "Failed to download the agent installation support script."
     logger -t Failed to download the Deep Security Agent installation support script
     false
  fi
else 
  echo "Please install CURL before running this script."
  logger -t Please install CURL before running this script
  false
fi

if [ $TENANTID != "NONE" ]
  then
    tenant="tenantID:${TENANTID}"
    tenantpassword="token:${TOKEN}"
fi

sleep 15
/opt/ds_agent/dsa_control -r
/opt/ds_agent/dsa_control -a ${ACTIVATIONURL} ${tenant} ${tenantpassword}
