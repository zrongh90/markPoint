mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.110:/rkdm_erwdp /rkdm/erwdp

mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.110:/rkdm_fbdc /rkdm/fbdc

mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.110:/rwms_custlist /rwms/custlist


11.8.8.111:/sapmnt     50.00     49.37    2%        4     1% /sapmnt
11.8.8.110:/sapmedia    100.00     99.37    1%        0     0% /sapmedia





mountDR.sh
#mountDR rkdm_erwdp
umount /rkdm/erwdp
mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.97:/rkdm_erwdp /rkdm/erwdp
sed -i 's/11.8.8.110/11.8.8.97/g' /etc/rc.local

#mountDR rkdm_fbdc
umount /rkdm/fbdc
mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.97:/rkdm_fbdc /rkdm/fbdc
sed -i 's/11.8.8.110/11.8.8.97/g' /etc/rc.local

#mountDR rwms_custlist
umount /rwms/custlist
mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.97:/rwms_custlist /rwms/custlist
sed -i 's/11.8.8.110/11.8.8.97/g' /etc/rc.local



mountLC.sh

#mountLC rkdm_erwdp
umount /rkdm/erwdp
mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.110:/rkdm_erwdp /rkdm/erwdp
sed -i 's/11.8.8.97/11.8.8.110/g' /etc/rc.local

#mountLC rkdm_fbdc
umount /rkdm/fbdc
mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.110:/rkdm_fbdc /rkdm/fbdc
sed -i 's/11.8.8.97/11.8.8.110/g' /etc/rc.local

#mountLC rwms_custlist
umount /rwms/custlist
mount -t nfs -o vers=3,proto=tcp,rsize=1048576,wsize=1048576,soft,timeo=10,intr,retrans=3,bg 11.8.8.110:/rwms_custlist /rwms/custlist
sed -i 's/11.8.8.97/11.8.8.110/g' /etc/rc.local







