#!/bin/bash

MODE=""
IP=""
RESOURCE_GROUP=""
CLUSTER_NAME=""
MODE_FLAGS=0
USE_IP_LIST=0

usage() {
    echo "Usage: $?"
    echo "  -a add IP address"
    echo "  -r remove IP address"
    echo "  -i <IP address>"
    echo "  -g <Resource Group>"
    echo "  -n <Cluster Name>"
    echo "  -s <IP list>"
    echo ""
    echo "To add an IP address:"
    echo "  $? -a -i <IP address> -g <Resource Group> -n <Cluster Name>"
    echo ""
    echo "To remove an IP address:"
    echo "  $? -r -i <IP address> -g <Resource Group> -n <Cluster Name>"
    echo ""
    echo "Omitting the '-i' flag will use the current external IP address discovered using IP Chicken"
    echo ""
    echo "It is possible to replace '-i' with '-s' for adding IP addresses.  What '-s' does is replaces"
    echo "all the values with the specified list.  This can also be used to set the list to null, thus"
    echo "opening up the IP address range to all"
    exit 1
}

# remove an ip address from a list
subtract_ip()
{
    IP_TO_REMOVE=( $1 )
    IP_LIST=( $2 )
    OLDIFS="$IFS"
    IFS=$'\n'
    UPDATED_LIST=( $(grep -Fxv "${IP_TO_REMOVE[*]}" <<< "${IP_LIST[*]}") )
    IFS="$OLDIFS"
    echo "${UPDATED_LIST[*]}"
}

while getopts "ari:n:g:s:" OPTION; do
    case $OPTION in
    a)
        MODE="add"
        MODE_FLAGS=$((MODE_FLAGS+1))
        ;;
    r)
        MODE="remove"
        MODE_FLAGS=$((MODE_FLAGS+1))
        ;;
    i)
        IP=$OPTARG
        ;;
    s)
        IP_LIST=$OPTARG
	USE_IP_LIST=1
        ;;
    n)
        CLUSTER_NAME=$OPTARG
        ;;
    g)
        RESOURCE_GROUP=$OPTARG
        ;;
    esac
done

# make sure the basics are set
if [[ -z "$RESOURCE_GROUP" || -z "$CLUSTER_NAME" || ! $MODE_FLAGS -eq 1 ]]; then
    usage
fi

# ensure that both an IP address and IP list are not both passed in
if [ ! -z "$IP_LIST" ] && [ ! -z "$IP" ]; then
    echo "One can only use an IP or an IP list, not both"
    usage
fi

if [ $USE_IP_LIST -eq 0 ]; then
    # handle case where we are working with a single IP address
    if [ -z "$IP" ]; then
        IP=`curl -s https://ipchicken.com | egrep -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' | sort -u`
	IP="$IP/32"
    fi

    # current IP address LIST
    CURRENT_IP_ADDRESS_LIST=`az aks show -g jms-tst1-rg -n jmsfxclus | jq -c -r '.apiServerAccessProfile.authorizedIpRanges' | sed 's/\]//' | sed 's/\[//' | sed 's/"//g' | sed 's/,/ /g'`
    FILTERED_IP_ADDRESS_LIST=$(subtract_ip "$IP" "$CURRENT_IP_ADDRESS_LIST")
    if [ "$MODE" == "add" ]; then
        # handle adding the IP
        UPDATED_IP_ADDRESS_LIST="$FILTERED_IP_ADDRESS_LIST $IP"
    else
        UPDATED_IP_ADDRESS_LIST="$FILTERED_IP_ADDRESS_LIST"
    fi
    UPDATED_IP_ADDRESS_LIST=`echo $UPDATED_IP_ADDRESS_LIST | sed 's/ /,/g'`
else
    # use the specified IP address liit
    UPDATED_IP_ADDRESS_LIST="$IP_LIST"
fi

# update the list
az aks update --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --api-server-authorized-ip-ranges "$UPDATED_IP_ADDRESS_LIST" > /dev/null
if [ ! $? -eq 0 ]; then
    echo "error updating api server ip ranges"
    exit 1
fi
echo "API Server authorized IPs updated to - \"$UPDATED_IP_ADDRESS_LIST\""

exit 0

