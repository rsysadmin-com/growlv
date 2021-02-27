#!/bin/bash

# growlv.sh
#
# martinm@rsysadmin.com
#
# Usage as root:
#
#	# ./growlv size+units lv
#
#	input units:
#				b|B is bytes, 
#				s|S is sectors of 512 bytes, 
#				k|K is kilobytes, 
#				m|M is megabytes, 
#				g|G is gigabytes, 
#				t|T is terabytes,
#				p|P is petabytes, 
#				e|E is exabytes
#
#	example: ./growlv 200G 
#			this will add +200 GB to the root LV
#

usage() {
	echo "Usage: $(basename $0) size+units lv"
	cat << EOF
	
input units:
		b|B is bytes, 
		s|S is sectors of 512 bytes, 
		k|K is kilobytes, 
		m|M is megabytes, 
		g|G is gigabytes, 
		t|T is terabytes,
		p|P is petabytes, 
		e|E is exabytes
			
example: 
	./growlv.sh 200G root
	  this will add +200 GB to the root LV
	  
	  ./growlv.sh 10G var
	  this will add +10 GB to the var LV
	  
	If no LV is given, the root-lv will be used as default.
	
	 ./growlv.sh 50G
	 this will add +50 GB to the root LV
	 
EOF
	exit 1
}

function returnStatus {
    if [[ $? -eq 0 ]]
    then
        echo -e "[ PASS ]"
    else
        echo -e "[ FAIL ]"
    fi
}


if [[ $# -eq 0 ]]
then
	usage
fi


lv_size=$1
lv_seek=$2
if [ -z $lv_seek ]
then
	lv_seek="root"
fi

rawdisk=$(ls -l /dev/sd* | awk '{ print $10 }' | tail -1)
root_lv=$(lvs | grep $lv_seek | awk '{ print $2 }')
real_root_lv=$(lvs | grep root | awk '{ print $2 }')

if [ -z $root_lv ]
then
	echo "WARNING - Cannot find $lv_seek LV on this system !!!"
	echo -e "WARNING - These are the Logical Volumes available:\n"
	ls -1 /dev/mapper/* | grep $real_root_lv
	echo -e "\nBailing out...\n"
	
	exit
fi
lv_name="/dev/mapper/${root_lv}-${lv_seek}"
fstype=$(df -T | grep $lv_name | awk '{ print $2 }')

echo -e "\ngrowlv.sh"
echo -e "martinm@rsysadmin.com\n"

echo "== Setting filesystem type (silently)..."
(echo n; echo p; echo 1; echo ; echo ; echo t; echo 8e; echo w) | fdisk $rawdisk > /dev/null

echo -e "== Creating new PV...\c"
newdisk=$(ls -l /dev/sd* | awk '{ print $10 }' | tail -1)
pvcreate $newdisk > /dev/null
returnStatus

echo -e "== Extending $root_lv with $newdisk ...\c"
vgextend $root_lv $newdisk > /dev/null
returnStatus

echo -e "== Adding extra $lv_size GB to $lv_name...\c"
lvextend -L +$lv_size $lv_name > /dev/null
returnStatus

if [ $fstype == "xfs" ]
then
	echo -e "-- Nice, found an XFS...\c"
	xfs_growfs $lv_name > /dev/null > /dev/null
	returnStatus
else
	echo -e "-- OK, not XFS but it will do...\c"
	resize2fs $lv_name > /dev/null > /dev/null
	returnStatus
fi

echo -e "\nAll set.\n"
