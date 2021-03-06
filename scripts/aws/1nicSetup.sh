#!/bin/bash

# Copyright 2016-2017 F5 Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

USAGE_SHORT="Usage: $0"
read -r -d '' USAGE_LONG << EOM
    Usage: $0
        -h|--help         Print this message and exit.
EOM

ARGS=`getopt -o h --long help -n $0 -- "$@"`
if [ $? -ne 0 ]; then
    echo $USAGE_SHORT
    exit
fi

eval set -- "$ARGS"

# Defaults
HELP=false

# Parse the command line arguments
while true; do
    case "$1" in
        -h|--help)
            HELP=true;
            shift ;;
        --)
            shift
            break;;
    esac
done

if [ $HELP = true ]; then
    echo "$USAGE_LONG"
    exit
fi

. ../util.sh

function get_cidr_block() {
    SUBNET_MASK=$(grep subnet-mask /var/lib/dhclient/dhclient.leases | tail -1 | awk '{print $3}' | sed -r 's/(.*);/\1/')
    eval $(ipcalc -np $MGMT_ADDR $SUBNET_MASK)
    GATEWAY_CIDR_BLOCK=$NETWORK/$PREFIX
}

if ! wait_mcp_running; then
    echo "mcpd not ready in time."
    exit 1
fi

if ! wait_for_management_ip; then
    echo "Could not get management ip."
    exit 1
fi

echo MGMT_ADDR: "$MGMT_ADDR"

# Get the Gateway info
# Centos 7 updated ifconfig format
OS_MAJOR_VERSION=$(get_os_major_version)
if [ $OS_MAJOR_VERSION -ge "7" ]; then
    GATEWAY_MAC=$(ifconfig eth0 | egrep ether | awk '{print tolower($2)}')
else
    GATEWAY_MAC=$(ifconfig eth0 | egrep HWaddr | awk '{print tolower($5)}')
fi
echo GATEWAY_MAC: "$GATEWAY_MAC"

get_cidr_block
echo GATEWAY_CIDR_BLOCK: "$GATEWAY_CIDR_BLOCK"

GATEWAY_NET=${GATEWAY_CIDR_BLOCK%/*}
echo GATEWAY_NET: "$GATEWAY_NET"

GATEWAY_PREFIX=${GATEWAY_CIDR_BLOCK#*/}
echo GATEWAY_PREFIX: "$GATEWAY_PREFIX"

GATEWAY=`echo $GATEWAY_NET | awk -F. '{ printf "%d.%d.%d.%d", $1, $2, $3, $4+1 }'`
echo GATEWAY: "$GATEWAY"

# Create the network
echo tmsh create net vlan internal interfaces add { 1.0 }
tmsh create net vlan internal interfaces add { 1.0 }

echo tmsh create net self "$MGMT_ADDR"/$GATEWAY_PREFIX vlan internal allow-service default
tmsh create net self "$MGMT_ADDR"/$GATEWAY_PREFIX vlan internal allow-service default

echo tmsh create sys folder /LOCAL_ONLY device-group none traffic-group traffic-group-local-only
tmsh create sys folder /LOCAL_ONLY device-group none traffic-group traffic-group-local-only

echo tmsh create net route /LOCAL_ONLY/default network default gw "$GATEWAY"
tmsh create net route /LOCAL_ONLY/default network default gw "$GATEWAY"

echo tmsh save sys config
tmsh save sys config

# Added for bug#664393
GW_SET=false
while [ $GW_SET == false ]
do
    if ! route -n|grep '^0.0.0.0.*internal$' &> /dev/null; then
        echo tmsh delete net route /LOCAL_ONLY/default
        tmsh delete net route /LOCAL_ONLY/default
        echo tmsh create net route /LOCAL_ONLY/default network default gw "$GATEWAY"
        tmsh create net route /LOCAL_ONLY/default network default gw "$GATEWAY"
        echo tmsh save sys config
        tmsh save sys config
    else
        GW_SET=true
    fi
    echo "GW_SET = $GW_SET"
done
