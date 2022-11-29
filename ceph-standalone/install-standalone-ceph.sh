#!/bin/bash
set -e
###################### Variable Setting ######################

ip_addr="192.168.51.16"
hostname="ceph"

##############################################################

echo -e "\nStep1. Set hostname"
echo "============================================================================="
hostnamectl set-hostname ${hostname}
echo "${ip_addr} ${hostname}" >> /etc/hosts


echo -e "\nStep2. Install epel"
echo "============================================================================="
yum install -y epel-release

echo -e "\nStep3. Install chrony"
echo "============================================================================="
yum install -y chrony
systemctl enable chronyd
systemctl start chronyd

echo -e "\nStep4. Disable Selinux"
echo "============================================================================="
setenforce 0
sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config

echo -e "\nStep5. Install python3"
echo "============================================================================="
yum install -y python39

echo -e "\nStep6. Install podman"
echo "============================================================================="
yum install -y podman

echo -e "\nStep7. Install ceph"
echo "============================================================================="
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm
sed -i "s/        'rhel': ('centos', 'el'),/        'rhel': ('centos', 'el'),\n        'rocky': ('centos', 'el'),/g" cephadm
chmod +x cephadm
./cephadm add-repo --release octopus
cp ./cephadm /usr/sbin
./cephadm install
./cephadm install ceph-common

echo -e "\nStep8. Set bootstrap node"
echo "============================================================================="
mkdir -p /etc/ceph
cephadm bootstrap --mon-ip ${ip_addr}
alias ceph="cephadm shell -- ceph"

echo -e "\nStep9. Add node to cluster"
echo "============================================================================="
ssh-copy-id -f -i /etc/ceph/ceph.pub root@${hostname}
ceph orch host add ${hostname}

echo -e "\nStep10. Set monitor node"
echo "============================================================================="
ceph orch apply mon 1
ceph orch host label add ${hostname} mon
ceph orch apply mon label:mon

echo -e "\nStep11. Set manager node"
echo "============================================================================="
ceph orch apply mgr 1
ceph orch host label add ${hostname} mgr
ceph orch apply mon label:mgr

echo -e "\nStep12. Set OSD Size to 1"
echo "============================================================================="
ceph config set global osd_pool_default_size 1
ceph config set global mon_warn_on_pool_no_redundancy false
ceph orch restart mgr

echo -e "\nStep13. Add Device to OSD"
echo "============================================================================="
ceph orch apply osd --all-available-devices
sleep 5

echo -e "\nStep14. Config rgw"
echo "============================================================================="
radosgw-admin realm create --rgw-realm=stalone_realm --default
radosgw-admin zonegroup create --rgw-zonegroup=stalone_zgroup --master --default
radosgw-admin zone create --rgw-zonegroup=stalone_zgroup --rgw-zone=stalone_zone --master --default
ceph orch apply rgw stalone_realm stalone_zgroup-1 --placement="1 $(hostname)"

echo -e "\nStep15. Set rgw Dashboard"
echo "============================================================================="
radosgw-admin user create --uid=dashboard --display-name=dashboard --system > /tmp/user-info

yum install -y jq

echo $(cat /tmp/user-info | jq '.keys|.[]|.access_key' | sed 's/\"//g') > /tmp/access.key
echo $(cat /tmp/user-info | jq '.keys|.[]|.secret_key' | sed 's/\"//g') > /tmp/secret.key

ceph dashboard set-rgw-api-access-key -i /tmp/access.key
ceph dashboard set-rgw-api-secret-key -i /tmp/secret.key
