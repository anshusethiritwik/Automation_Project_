name="ritwik"
s3_bucket="upgradritwik"

apt update -y

if [[ apache2 != $(dpkg --get-selections apache2| awk '{print $1}') ]];
then
        echo "Apache insatlled"
else
        apt install  apache2 -y
fi

if [ $(systemctl status apache2 | grep -v grep | grep 'apache2 is running' | wc -l) -gt 0 ];
then
        echo "running"
else
        systemctl start apache2
fi

enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]];
then
        echo "enabled"
else
        systemctl status apache2
fi


sudo apt install awscli -y
if [ $? -eq 0 ];
then
        echo "AWS CLI installed"
else
        echo "not installed"
        exit 1
fi


timestamp=$(date '+%d%m%Y-%H%M%S')
echo ${timestamp}

cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log

if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]];
then
        aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi
invpath="/var/www/html"
if [[ ! -f ${invpath}/inventory.html ]];
then
        echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${invpath}/inventory.html
fi

if [[ -f ${invpath}/inventory.html ]];
then
        size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
        echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${invpath}/inventory.html
fi

if [[ ! -f /etc/cron.d/automation ]];
then
        echo "* * * * * root/root/automation.sh" >> /etc/cron.d/automation
fi

