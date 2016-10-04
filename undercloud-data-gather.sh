#!/bin/bash

hostname="$(`echo hostname` | cut -d "." -f1)"
current_date="$(`echo date '+%Y.%m.%d-%H.%M.%S'`)"
backup_filename="${hostname}-backup-${current_date}.tar.gz"

mkdir -p /root/backups/undercloud-backups
cd /root/backups/undercloud-backups

tar -zcvf ${backup_filename} \
        /etc/my.cnf.d/server \
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
    	/etc/heat \
    	/var/log/heat \
    	/var/lib/heat \
    	/var/lib/heat-cfntools \
    	/etc/neutron \
    	/var/log/neutron \
    	/var/lib/neutron \
    	/etc/openvswitch \
    	/var/log/openvswitch \
    	/var/lib/openvswitch \
    	/etc/ceilometer \
    	/var/lib/ceilometer \
    	/var/log/ceilometer \
    	/etc/ironic \
    	/var/log/ironic \
    	/var/lib/ironic \
    	/srv/node \
    	/home/stack \
    	/etc/sysconfig/memcached

echo "CREATED BACKUP: ${backup_filename}"
