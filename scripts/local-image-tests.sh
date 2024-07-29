#!/bin/bash

## Colours
all_off="$(tput sgr0)"
bold="${all_off}$(tput bold)"
black="${bold}$(tput setaf 0)"
red="${bold}$(tput setaf 1)"
green="${bold}$(tput setaf 2)"
yellow="${bold}$(tput setaf 3)"
blue="${bold}$(tput setaf 4)"


DEBUG=

# Message helpers
msg() {
    printf "%s\n" "$1"
}
debug() {
    [ $DEBUG ] && printf "%s:: %s%s\n" "${black}" "$1" "${all_off}"
}
info() {
    printf "%s::%s %s%s\n" "${blue}" "${bold}" "$1" "${all_off}"
}
action() {
    printf "%s==>%s %s%s\n" "${green}" "${bold}" "$1" "${all_off}"
}
question() {
    printf "%s==>%s %s%s\n" "${yellow}" "${bold}" "$1" "${all_off}"
}
warn() {
    printf "%sWARNING%s %s%s\n" "${yellow}" "${bold}" "$1" "${all_off}"
}
error() {
    printf "%sERROR%s %s%s\n" "${red}" "${bold}" "$1" "${all_off}"
}
fatal() {
    printf "%sERROR%s %s%s\n" "${red}" "${bold}" "$1" "${all_off}"
    exit 1
}

for tool in openstack nc; do
    if ! hash $tool >/dev/null 2>&1; then
        fatal "You need '$tool' installed to use this script"
    fi
done

help_text() {
    # Display Help
    echo "Test script"
    echo
    echo "Syntax: $0 [-h|-d|-f file|-n name|-u user]"
    echo "options:"
    echo "  d  Debug mode."
    echo "  h  Print this Help."
    echo "  f  Image file."
    echo "  n  Image name."
    echo "  u  User to SSH for tests."
    echo
}

# Environment vars
: "${OS_AVAILABILITY_ZONE:=melbourne-qh2}"
: "${OS_SECGROUP:=image-build}"
: "${OS_FLAVOR:=m3.small}"
: "${OS_KEYNAME:=jenkins-image-testing}"

NAME=
IMAGE_FILE=
BASE_DIR=
FACT_DIR=
TAG_DIR=
USER_ACCOUNT=

# Globals
INSTANCE_ID=
IMAGE_ID=


# Args
while getopts ":hdf:n:u:" option; do
    case $option in
        h)
            help_text
            exit
        ;;
        d)
            DEBUG=1
        ;;
        f)
            IMAGE_FILE=$OPTARG
        ;;
        n)
            NAME=$OPTARG
        ;;
        u)
            USER_ACCOUNT=$OPTARG
        ;;
        \?)
            echo "Error: Invalid option"
            exit
        ;;
    esac
done
shift "$((OPTIND - 1))"

if [ $DEBUG ]; then
    info "Enabling debug mode"
fi

if [ -z "$IMAGE_FILE" ]; then
    fatal "Image file not given"
fi

if [ ! -f "$IMAGE_FILE" ]; then
      fatal "Image file '$IMAGE_FILE' not found"
fi

if [ -z "$OS_AUTH_URL" ]; then
    fatal "OpenStack credentials not loaded"
fi

# Set the base dir from the location of the image
if [ -z $BASE_DIR ]; then
    BASE_DIR=$(dirname "$IMAGE_FILE")
fi

# If name is not given, then extract it from the packer image path
# e.g. 'packer-debian-12' from builds/build_files/packer-debian-12
if [ -z $NAME ]; then
    NAME=${BASE_DIR##*/}
    info "Using build name: '$NAME'"
fi

# Test keypair is available
key=$(openstack keypair show -f value -c name "$OS_KEYNAME")
if [ -n "$key" ]; then
    info "Found keypair: '$key'"
else
    fatal "Testing keypair '$OS_KEYNAME' not found"
fi

# Test secgroup is available
sg=$(openstack security group show -f value -c name "$OS_SECGROUP" 2>&1)
if [ $? -eq 0 ]; then
    info "Found security group: '$sg'"
else
    fatal "Testing security group '$OS_SECGROUP' not found"
fi

# Set and test for the facts dir
FACT_DIR="$BASE_DIR/.facts"
[ -d $FACT_DIR ] || warn "Fact dir not found"

# Set and test for the tags dir
TAG_DIR="$BASE_DIR/.tags"
[ -d $TAG_DIR ] || warn "Tags dir not found"

# Discover user account from the facts dir
if [ -z $USER_ACCOUNT ]; then
    USER_ACCOUNT=$(cat $FACT_DIR/default_user)
fi
info "Using user account: '$USER_ACCOUNT'"

delete_image() {
    [ -n "$IMAGE_ID" ] || return  # No image ID set
    delete=1
    if [ $DEBUG ]; then
        read -r -p "Would you like to clean up the image '$1'? [y/N] " response
        [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] || delete=0
    fi
    if [ $delete -eq 1 ]; then
        action "Deleting image '$1'..."
        debug "openstack image delete $1"
        openstack image delete $1
        IMAGE_ID=
    else
        warn "Not deleting image $1..."
    fi
}

delete_instance() {
    [ -n "$INSTANCE_ID" ] || return  # No instance ID set
    if [ $DEBUG ]; then
        echo "Saving instance/server log to: '$BASE_DIR/console.txt'"
        openstack server show $1 > $BASE_DIR/console.txt
        openstack console log show $1 >> $BASE_DIR/console.txt
    fi
    delete=1
    if [ $DEBUG ]; then
        read -r -p "Would you like to clean up the instance '$1'? [y/N] " response
        [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] || delete=0
    fi
    if [ $delete -eq 1 ]; then
        action "Deleting instance '$1'..."
        debug "openstack server delete $1"
        openstack server delete $1
        INSTANCE_ID=
    else
        warn "Not deleting instance $1..."
    fi
}

# Function for cleanup on script exit
cleanup_on_exit() {
    delete_instance $INSTANCE_ID
    delete_image $INSTANCE_ID
}

# Trap for cleanup on script exit
trap 'cleanup_on_exit' EXIT

# Create the image
action "Creating image: '$NAME'..."
debug "openstack image create --disk-format qcow2 --container-format bare --file $IMAGE_FILE '$NAME'"
IMAGE_ID=$(openstack image create -f value -c id --disk-format qcow2 --container-format bare --file $IMAGE_FILE "$NAME")
info "Found image ID: '$IMAGE_ID'"

# Set extra properties from Ansible facts (see Ansible facts role)
if [ -d $FACT_DIR ]; then
    find $FACT_DIR -type f -printf "%f\n" | while read FACT; do
        read VAL < $FACT_DIR/$FACT
        info "Setting property: $FACT='$VAL'"
        openstack image set --property $FACT=$"$VAL" $IMAGE_ID || true
    done
fi

# Set tags from Ansible facts (see Ansible facts role)
if [ -d $TAG_DIR ]; then
    find $TAG_DIR -type f -printf "%f\n" | while read TAG; do
        info "Setting tag: '$TAG'"
        openstack image set --tag $TAG $IMAGE_ID || true
    done
fi

instance_name="test_${NAME}"
action "Creating instance '$instance_name'..."
debug "openstack server create --image $IMAGE_ID --flavor $OS_FLAVOR --availability-zone $OS_AVAILABILITY_ZONE --security-group $OS_SECGROUP --key-name $OS_KEYNAME --wait '$NAME'"
INSTANCE_ID=$(openstack server create -f value -c id --image $IMAGE_ID --flavor $OS_FLAVOR --availability-zone $OS_AVAILABILITY_ZONE --security-group $OS_SECGROUP --key-name $OS_KEYNAME --wait "$NAME" | xargs echo)  # xargs because of leading newline

if [ -z $INSTANCE_ID ]; then
    error "Instance ID not found!"
    delete_image $IMAGE_ID
    exit 1
else
    info "Found instance ID: '$INSTANCE_ID'"
fi

set +e

sleeptime=10
attempts=30
attempt=1
info "Waiting for instance to become ACTIVE..."
while [ $attempt -le $attempts ]; do
    STATUS=$(openstack server show -f value -c status $INSTANCE_ID)
    if [ "$STATUS" = "ERROR" ]; then
        error "Instance entered ERROR state!"
        delete_instance $INSTANCE_ID
        delete_image $IMAGE_ID
        exit 1
    fi
    if [ "$STATUS" = "ACTIVE" ]; then
        info "Instance became ACTIVE after $((sleeptime*attempt))s"
        break
    fi
    if [ $attempt -eq $attempts ]; then
        error "Instance failed to become ACTIVE after 5 mins ($STATUS)"
        delete_instance $INSTANCE_ID
        delete_image $IMAGE_ID
        exit 1
    fi
    sleep 10
    debug "Instance status is: $STATUS ($attempt/$attempts)"
    attempt=$((attempt+1))
done

# Find IP address of instance
ip=$(openstack server show -f value -c accessIPv4 $INSTANCE_ID)
if [ -z $ip ]; then
    ip=$(openstack server show -f value -c addresses $INSTANCE_ID | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    if [ -z $ip ]; then
        error "Instance IP not found!"
        delete_instance $INSTANCE_ID
        delete_image $IMAGE_ID
        exit 1
    fi
else
    info "Found instance IP address: '$ip'"
fi

if [[ "$NAME" =~ indows ]]; then
    READY_MESSAGE='Stopping Cloudbase-Init service'
else
    READY_MESSAGE='Cloud-init.*finished at'
fi

# Poll for instance boot to complete
sleeptime=30
attempts=20
attempt=1
info "Waiting for instance to finish boot..."
while [ $attempt -le $attempts ]; do
    openstack console log show $INSTANCE_ID | grep -Eoq "$READY_MESSAGE" 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        info "Boot finished in $((sleeptime*attempt))s"
        break
    fi
    if [ $attempt -eq $attempts ]; then
        # One last attempt with output
        error "Reached retry limit after 5 minutes"
        delete_instance $INSTANCE_ID
        delete_image $IMAGE_ID
        exit 1
    fi
    sleep $sleeptime
    debug "attempt $attempt/$attempts"
    attempt=$((attempt+1))
done

sleeptime=10
attempts=30
attempt=1
info "Checking for SSH port it open..."
while [ $attempt -le $attempts ]; do
    #ssh -q -oConnectTimeout=5 -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$ip exit 2>&1 >/dev/null
    nc -z -w5 $ip 22 2>&1 >/dev/null
    if [ $? -eq 0 ]; then
        info "SSH connection found in $((sleeptime*attempt))s"
        break
    fi
    if [ $attempt -eq $attempts ]; then
        # One last attempt with output
        error "Reached retry limit after 5 minutes"
        #ssh -oConnectTimeout=5 -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$ip exit
        nc -z -w5 -v $ip 22
        delete_instance $INSTANCE_ID
        delete_image $IMAGE_ID
        exit 1
    fi
    sleep $sleeptime
    debug "attempt $attempt/$attempts"
    attempt=$((attempt+1))
done

if [[ "$NAME" =~ indows ]]; then
    TEST_CMD='C:\ProgramData\Nectar\run_tests.cmd'
else
    TEST_CMD='/bin/bash /usr/nectar/run_tests.sh'
fi

action "Running instance tests..."
debug "ssh -oConnectTimeout=5 -oIdentitiesOnly=yes -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$ip '$TEST_CMD'"
ssh -oConnectTimeout=5 -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$ip "$TEST_CMD"

# Complete
delete_instance $INSTANCE_ID
delete_image $IMAGE_ID
