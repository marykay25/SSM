if [ -s /usr/bin/dpkg ]
	then
		dpkg -r ds-agent
	else	   
		rpm -e ds_agent
	fi

