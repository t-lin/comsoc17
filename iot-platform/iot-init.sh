#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "ERROR: Expecting a single parameter (name of the Edge region)"
    echo "Usage: ./iot-init.sh <edge_region_name>"
    exit 0
else
    EDGE_REGION=$1
    POSSIBLE_EDGES="EDGE-WT-1 EDGE-CT-1 EDGE-VC-1"

    # Ensure specified region is valid
    MATCH=0
    for i in $POSSIBLE_EDGES; do
        if [[ "${i}" == "${EDGE_REGION}" ]]; then
            MATCH=1
            break;
        fi
    done

    if [[ $MATCH == 0 ]]; then
        echo "ERROR: Unknown edge name provided"
        exit 0
    fi
fi

# Force user's region name variable to CORE (just in case they haven't already)
export OS_REGION_NAME=CORE

source /home/savitb/bin/functions
USER="$(whoami)"
KEY_NAME=${USER}key
SECGROUP_NAME=default

blue_desc_title "  Initializing all settings for ($USER)"

green_desc_title "1. Creating a keypair ($KEY_NAME) ..."
if [[ ! -f $HOME/.ssh/id_rsa.pub ]]; then
    command_desc "ssh-keygen -t rsa"
    echo -e "\n" | ssh-keygen -t rsa -N ""
else
    green_desc "An existing keypair was found, skipping create"
fi
AUTH_KEY=$(cat ~/.ssh/id_rsa.pub)

green_desc_title "2. Importing the key-pair ($KEY_NAME) to SAVI Testbed ..."
command_desc "nova keypair-add --pub_key $HOME/.ssh/id_rsa.pub $KEY_NAME"
UPLOADED_KEY=`nova keypair-list | grep $KEY_NAME`
if [[ ! -z "$UPLOADED_KEY" ]]; then
    # Key-pair was same name was found
    # Assume the key doesn't match: delete and re-upload
    nova keypair-delete $KEY_NAME
    sleep 1
fi
nova keypair-add --pub_key $HOME/.ssh/id_rsa.pub $KEY_NAME

green_desc_title "3. Creating a security group (${SECGROUP_NAME}) ..."
SECGROUP=`nova secgroup-list | grep $SECGROUP_NAME`
if [[ ! -z "$SECGROUP" ]]; then
    green_desc "Security Group $SECGROUP_NAME already exists; skipping create"
else
    command_desc "nova secgroup-create $SECGROUP_NAME \"$SECGROUP_NAME secgroup\""
    nova secgroup-create ${SECGROUP_NAME} "${SECGROUP_NAME} secgroup"
fi

green_desc_title "4. Adding rules to ($SECGROUP_NAME) in CORE and ${EDGE_REGION} ..."
yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} icmp -1 255 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} icmp -1 255 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} icmp -1 255 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 22 22 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 22 22 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 22 22 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} udp 1099 1099 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} udp 1099 1099 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} udp 1099 1099 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 1099 1099 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 1099 1099 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 1099 1099 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 9092 9092 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 9092 9092 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 9092 9092 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 5000 5010 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 5000 5010 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 5000 5010 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 9042 9042 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 9042 9042 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 9042 9042 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 5601 5601 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 5601 5601 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 5601 5601 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 2376 2377 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 2376 2377 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 2376 2377 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 9200 9200 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 9200 9200 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 9200 9200 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 4040 4040 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 4040 4040 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 4040 4040 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 8080 8099 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 8080 8099 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 8080 8099 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 5044 5044 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 5044 5044 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 5044 5044 0.0.0.0/0 2> /dev/null

yellow_desc "nova secgroup-add-rule ${SECGROUP_NAME} tcp 2181 2181 0.0.0.0/0"
nova secgroup-add-rule ${SECGROUP_NAME} tcp 2181 2181 0.0.0.0/0 2> /dev/null
nova --os-region-name ${EDGE_REGION} secgroup-add-rule ${SECGROUP_NAME} tcp 2181 2181 0.0.0.0/0 2> /dev/null


green_desc_title "5. Creating IoT controller VM in CORE ..."
NET_ID=`quantum net-list | grep $OS_TENANT_NAME-net | awk '{print $2}'`
command_desc "nova boot --flavor m1.small --image $2 --key_name $KEY_NAME --security_groups $SECGROUP_NAME --nic net-id=$NET_ID iot-controller"
nova boot --flavor m1.small --image comsoc-iot --key_name $KEY_NAME --security_groups $SECGROUP_NAME --nic net-id=$NET_ID iot-controller


