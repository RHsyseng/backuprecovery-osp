#!/bin/bash

[[ ${USER} != stack ]] && {
	echo -e "\nYou must be logged in as the stack user to run this script.\n"
	exit
	}

. ~/stackrc
mkdir -p /home/stack/backups

cat << 'EOF' > /tmp/backup.$$
#!/bin/bash

hostname="$(`echo hostname` | cut -d "." -f1)"
current_date="$(`echo date '+%Y.%m.%d-%H.%M.%S'`)"
backup_filename="${hostname}-backup-${current_date}.tar.gz"
mkdir -p /home/heat-admin/backups

cd /home/heat-admin/backups

tar -zcvf ${backup_filename} \
    	/etc/nova \
    	/var/log/nova \
    	/var/lib/nova \
    	--exclude /var/lib/nova/instances \
    	/etc/glance \
    	/var/log/glance \
    	/var/lib/glance \
    	/etc/keystone \
    	/var/log/keystone \
    	/var/lib/keystone \
    	/etc/httpd \
    	/etc/cinder \
    	/var/log/cinder \
    	/var/lib/cinder \
    	/etc/heat \
    	/var/log/heat \
    	/var/lib/heat \
    	/var/lib/heat-config \
    	/var/lib/heat-cfntools \
    	/etc/rabbitmq \
    	/var/log/rabbitmq \
    	/var/lib/rabbitmq \
    	/etc/neutron \
    	/var/log/neutron \
    	/var/lib/neutron \
    	/etc/corosync \
    	/etc/haproxy \
    	/etc/logrotate.d/haproxy \
    	/var/lib/haproxy \
    	/etc/openvswitch \
    	/var/log/openvswitch \
    	/var/lib/openvswitch \
    	/etc/ceilometer \
    	/var/lib/redis \
    	/etc/sysconfig/memcached

sha256sum /home/heat-admin/backups/${backup_filename} > /home/heat-admin/backups/${backup_filename}.sha256

echo "CREATED BACKUP: ${backup_filename}"
EOF


ip=$(nova list --fields Networks | sed -n 's/.*ctlplane=\(.*\)\s.*/\1/p')


for i in $ip
do
	scp  /tmp/backup.$$ heat-admin@${i}:/tmp/backup.sh

	remote_file=$( ssh heat-admin@${i} "sudo chmod 755 /tmp/backup.sh; sudo /tmp/backup.sh" \
             	| sed -n 's/^CREATED BACKUP:\s*\(.*\)/\1/p' )

	scp heat-admin@${i}:/home/heat-admin/backups/${remote_file}* /home/stack/backups
done

rm -f /tmp/backup.$$
