#!/bin/bash -e
#
#  Copyright (C) 2015 ScyllaDB
#  Modified by Itay Adler to fit for ComboAMI DSE setup.

print_usage() {
    echo "dse-raid-setup --disks /dev/hda,/dev/hdb... --raiddev /dev/md0 --update-fstab"
    echo "  --disks	specify disks for RAID"
    echo "  --raiddev	MD device name for RAID"
    echo "  --update-fstab update /etc/fstab for RAID"
    exit 1
}

RAID=/dev/md0
FSTAB=0
while [ $# -gt 0 ]; do
    case "$1" in
        "--disks")
            DISKS=`echo "$2"|tr -s ',' ' '`
            NR_DISK=$((`echo "$2"|grep , -o|wc -w` + 1))
            shift 2
            ;;
        "--raiddev")
            RAID="$2"
            shift 2
            ;;
        "--update-fstab")
            FSTAB=1
            shift 1
            ;;
        *)
            print_usage
            ;;
    esac
done

if [ "$DISKS" = "" ]; then
    print_usage
fi

for dsk in $DISKS; do
    if [ ! -b $dsk ]; then
        echo "$dsk is not found"
        exit 1
    fi
done

echo Creating RAID0 for DSE using $NR_DISK disk\(s\): $DISKS
if [ -e $RAID ]; then
    echo "$RAID is already using"
    exit 1
fi
if [ "`mount|grep /var/lib/cassandra`" != "" ]; then
    echo "/var/lib/cassandra is already mounted"
    exit 1
fi

. /etc/os-release
if [ "$NAME" = "Ubuntu" ]; then
    env DEBIAN_FRONTEND=noninteractive apt-get -y install mdadm xfsprogs
else
    yum -y install mdadm xfsprogs
fi
mdadm --create --verbose --force --run $RAID --level=0 -c256 --raid-devices=$NR_DISK $DISKS
blockdev --setra 65536 $RAID
mkfs.xfs $RAID -f
echo "DEVICE $DISKS" > /etc/mdadm.conf
mdadm --detail --scan >> /etc/mdadm.conf
if [ $FSTAB -ne 0 ]; then
    UUID=`blkid $RAID | awk '{print $2}'`
    echo "$UUID /var/lib/cassandra xfs noatime 0 0" >> /etc/fstab
fi
mount -t xfs -o noatime $RAID /var/lib/cassandra

mkdir -p /var/lib/cassandra/data
mkdir -p /var/lib/cassandra/logs
mkdir -p /var/lib/cassandra/commitlog
getent group cassandra >/dev/null || groupadd -r cassandra
getent passwd cassandra >/dev/null || \
useradd -d /usr/share/cassandra -g cassandra -M -r cassandra
sudo chown cassandra:cassandra /var/lib/cassandra/*
sudo chown cassandra:cassandra /var/lib/cassandra/
