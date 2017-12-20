ansible aixServer -vvv -u ansible -s -m copy -a "src=/home/tmpusr/aixSvMon.sh dest=/root/aixSvMon.sh owner=root group=root mode=0755"

ansible aixServer -vvv -u ansible -s -m shell -a "/aixSvMon.sh > aixSvMon.log"


ansible -i ./hosts drcbank_aix -u ansible -s -m cron -a "name='collect nmon' minute='0' hour='0' job='/zxyx/shell/nmon_collect.sh > /dev/null'"


ansible -i /etc/ansible/hosts drcbank_rhel6 -u ansible -s -m copy -a "src=/home/tmpusr/software/atop-2.2-3.sysv.x86_64.rpm dest=/tmp/atop-2.2-3.sysv.x86_64.rpm"

ansible -i /etc/ansible/hosts 192.168.3.111 -u ansible -s -m shell -a "rpm -ivh /tmp/atop-2.2-3.sysv.x86_64.rpm"

ansible -i /etc/ansible/hosts 192.168.3.111 -u ansible -s -m shell -a "sed -i -e 's;LOGPATH=/var/log/atop;LOGPATH=/tmp/zxyx/atop;g' -e 's/-mtime +28/-mtime +7/g' -e 's/INTERVAL=600/INTERVAL=60/g' /etc/atop/atop.daily"

 
 
ansible -i /etc/ansible/hosts 10.8.24.10  -u ansible -s -m copy -a "src=/home/tmpusr/software/atop-2.2-3.sysv.x86_64.rpm dest=/tmp/atop-2.2-3.sysv.x86_64.rpm"
 
ansible -i /etc/ansible/hosts 10.8.24.10 -u ansible -s -m shell -a "rpm -qa | grep atop || rpm -ivh /tmp/atop-2.2-3.sysv.x86_64.rpm"

ansible -i /etc/ansible/hosts 10.8.24.10 -u ansible -s -m shell -a "mkdir /tmp/zxyx/atop"
 
ansible -i /etc/ansible/hosts 10.8.24.10 -u ansible -s -m shell -a "sed -i -e 's;LOGPATH=/var/log/atop;LOGPATH=/tmp/zxyx/atop;g' -e 's/-mtime +28/-mtime +7/g' -e 's/INTERVAL=600/INTERVAL=60/g' /etc/atop/atop.daily"
 
 
 /mbappSrv01/logs/dgnslog
 
 0 7 * * * su - mbusr -c "/mbapp1srvlog/mv2nas.sh /mbappSrv01/logs/dgnslog /mbapp1srvlog/logs/dgnslog 20 > /mbapp1srvlog/mv2nas_dgnslog.log 2>/mbapp1srvlog/mv2nas_dgnslog.error"
 
 
 0 7 * * * su - mbusr -c "/mbapp2srvlog/mv2nas.sh /mbappSrv02/logs/dgnslog /mbapp2srvlog/logs/dgnslog 20 > /mbapp2srvlog/mv2nas_dgnslog.log 2>/mbapp2srvlog/mv2nas_dgnslog.error"
 
192.168.2.*
 
 sed -e 's#find $LOGPATH -name "'"atop_\*\'#find#g' /etc/atop/atop.daily
 
安装atop
ansible -i /etc/ansible/hosts 10.8.24.*  -u ansible -s -m copy -a "src=/home/tmpusr/software/atop-2.2-3.sysv.x86_64.rpm dest=/tmp/atop-2.2-3.sysv.x86_64.rpm"
 
ansible -i /etc/ansible/hosts 10.8.24.* -u ansible -s -m shell -a "rpm -qa | grep atop || rpm -ivh /tmp/atop-2.2-3.sysv.x86_64.rpm"

ansible -i /etc/ansible/hosts 10.8.24.* -u ansible -s -m shell -a "mkdir -p /tmp/zxyx/atop"
 
ansible -i /etc/ansible/hosts drcbank_rhel6 -u ansible -s -m shell -a "sed -e 's|find $LOGPATH -name 'atop_*' -mtime +10 -exec rm {} \;|find $LOGPATH -name 'atop_*' -mtime +10 -exec rm {} \;find $LOGPATH -name 'atop_*' -mtime +3 -exec gzip {} \;|g' /etc/atop/atop.daily"


ansible -i /etc/ansible/hosts drcbank_rhel6 -u ansible -s -m shell -a "cat /etc/atop/atop.daily | grep -i 'interval=\|logpath='"











ansible -i /etc/ansible/hosts 192.168.3.104  -u ansible -s -m copy -a "src=/home/tmpusr/atop.daily dest=/etc/atop/atop.daily owner=root group=root mode=0711"



 