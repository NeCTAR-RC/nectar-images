#!/bin/bash -e

FILE=$1
if [ -z ${FILE} ]; then
    echo "Usage: $0 [JSONFILE]"
    exit 1
fi

# Find packer
if ! hash packer >/dev/null 2>&1; then
    echo "You need packer installed to use this script"
    exit 1
fi

# Find jq
if ! hash jq >/dev/null 2>&1; then
    echo "You need jq installed to use this script"
    exit 1
fi

# Base defaults
NAME=$(basename -s .json ${FILE})
BUILD_NUMBER=$(date "+%Y%m%d%H%M")
BUILD_NAME="${NAME}_build_${BUILD_NUMBER}"
OUTPUT_DIR=output-${NAME}
PACKER_WORKING_FILE=$(mktemp)
FACT_DIR=$OUTPUT_DIR/.facts
TAG_DIR=$OUTPUT_DIR/.tags

DEBUG=1

# Source build config
. "$(basename $0 .sh).cfg"

read_packer_var() {
    jq -r ".builders[0].${1}" $PACKER_WORKING_FILE
}

write_packer_var() {
    TMPFILE=$(mktemp)
    jq ".builders[0].${1} = \"${2}\"" $PACKER_WORKING_FILE > $TMPFILE
    mv $TMPFILE $PACKER_WORKING_FILE
}

read_fact() {
    cat $FACT_DIR/${1}
}

delete_image() {
	DELETE=1
    if [ $DEBUG ]; then
		read -r -p "Would you like to clean up the image $1? [y/N] " response
		[[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] || DELETE=0
	fi
    if [ $DELETE ]; then
        echo "Deleting image $1..."
        echo "--> openstack image delete $1"
        openstack image delete $1
    else
        echo "NOT deleting image $1..."
    fi
}

delete_instance() {
    echo "Saving log to ${OUTPUT_DIR}/${BUILD_NAME}-console.txt"
    openstack server show $1 > ${OUTPUT_DIR}/${BUILD_NAME}-console.txt
    openstack console log show $1 >> ${OUTPUT_DIR}/${BUILD_NAME}-console.txt

	DELETE=1
    if [ $DEBUG ]; then
		read -r -p "Would you like to clean up the instance $1? [y/N] " response
		[[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] || DELETE=0
	fi
    if [ $DELETE ]; then
        echo "Deleting instance $1..."
        echo "--> openstack server delete $1"
        openstack server delete $1
    else
        echo "NOT instance $1..."
    fi
}

cp $FILE $PACKER_WORKING_FILE
BUILDER_TYPE=$(read_packer_var type)

if [ -z "$OS_USERNAME" ]; then
    echo "Please load the OpenStack credentials for testing"
    exit 1
fi

# Test keypair is available
if [ -n "$TEST_SSH_KEY" ]; then
    KEY=$(openstack keypair show -f value -c name "$TEST_SSH_KEY")
    if [ -n "$KEY" ]; then
        echo "Found testing keypair: $KEY"
    else
        echo "Testing keypair $TEST_SSH_KEY not found"
        exit 1
    fi
fi

if [ -d ${OUTPUT_DIR} ]; then
    echo "Cleaning up existing output directory \"${OUTPUT_DIR}\"..."
    rm -fr ${OUTPUT_DIR}
fi

# Clean out any old Ansible facts/tags
rm -fr $FACT_DIR $TAG_DIR

if [ "${BUILDER_TYPE}" == "qemu" ]; then
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        write_packer_var headless true
    else
        write_packer_var headless false
        #sed -i 's/console=ttyS0,115200n8//g' $PACKER_WORKING_FILE
    fi

    write_packer_var vm_name "${BUILD_NAME}"
else
    write_packer_var image_name "${BUILD_NAME}"
    write_packer_var flavor "${BUILD_FLAVOUR}"
fi

echo "Building image ${NAME}..."
packer build $PACKER_WORKING_FILE
rm -f $PACKER_WORKING_FILE

IMAGE_NAME="$(read_fact nectar_name)"
if [ ! -z $ORGANISATION ]; then
    IMAGE_NAME="${ORGANISATION} ${IMAGE_NAME}"
fi

if [ "${BUILDER_TYPE}" == "openstack" ]; then
    echo "Downloading image ${NAME}..."
    mkdir ${OUTPUT_DIR}
    openstack image save --file ${OUTPUT_DIR}/${BUILD_NAME} $BUILD_NAME

    echo "Deleting fat image..."
    openstack image delete $BUILD_NAME
fi

echo "Shrinking image..."
qemu-img convert -c -o compat=0.10 -O qcow2 ${OUTPUT_DIR}/${BUILD_NAME} ${OUTPUT_DIR}/${BUILD_NAME}.qcow2
rm -f ${OUTPUT_DIR}/${BUILD_NAME}

echo "Creating image \"${IMAGE_NAME}\"..."
echo "--> openstack image create --disk-format qcow2 --container-format bare --file ${OUTPUT_DIR}/${BUILD_NAME}.qcow2 \"${IMAGE_NAME}\""
IMAGE_ID=$(openstack image create -f value -c id --disk-format qcow2 --container-format bare --file ${OUTPUT_DIR}/${BUILD_NAME}.qcow2 "${IMAGE_NAME}")
echo "Found image ID: ${IMAGE_ID}"
rm -f ${OUTPUT_DIR}/${BUILD_NAME}.qcow2

# Set extra properties from Ansible facts (see Ansible facts role)
if [ -d $FACT_DIR ]; then
    for FACT in $(ls $FACT_DIR); do
        VAL=$(cat $FACT_DIR/$FACT)
        echo "Setting property $FACT=$VAL"
        openstack image set --property $FACT=$"$VAL" $IMAGE_ID || true
    done
fi

# Set tags from Ansible facts (see Ansible facts role)
if [ -d $TAG_DIR ]; then
    for TAG in $(ls $TAG_DIR); do
        echo "Setting tag $TAG"
        openstack image set --tag $TAG $IMAGE_ID || true
    done
fi

if [ ! -z $BUILD_PROPERTY ]; then
    echo "Setting property $BUILD_PROPERTY=$BUILD_NUMBER"
    openstack image set --property $BUILD_PROPERTY="$BUILD_NUMBER" $IMAGE_ID || true
fi

if [ -z $TEST_SSH_KEY ]; then
    echo "No keypair provided, so not running tests."
    exit 0
fi

echo "Creating instance \"test_${NAME}_${BUILD_NUMBER}\"..."
[ -z $TEST_AZ ] || AZ_OPT="--availability-zone $TEST_AZ"
echo "--> openstack server create --image ${IMAGE_ID} --flavor ${TEST_FLAVOUR} ${AZ_OPT} --security-group ${TEST_SG} --key-name ${TEST_SSH_KEY} --wait \"${BUILD_NAME}\""
INSTANCE_ID=$(openstack server create -f value -c id --image ${IMAGE_ID} --flavor ${TEST_FLAVOUR} ${AZ_OPT} --security-group ${TEST_SG} --key-name ${TEST_SSH_KEY} "${BUILD_NAME}")
echo "Found instance ID: ${INSTANCE_ID}"

set +e

ATTEMPTS=20
ATTEMPT=1
echo -n "Waiting for instance to become ACTIVE"
while [ $ATTEMPT -le $ATTEMPTS ]; do
    echo -n '.'
    STATUS=$(openstack server show -f value -c status ${INSTANCE_ID})
    if [ "$STATUS" = "ERROR" ]; then
      echo -e "\nERROR: instance failed to reach ACTIVE state."
      delete_instance $INSTANCE_ID
      delete_image $IMAGE_ID
      exit 1
    fi
    [ "$STATUS" = "ACTIVE" ] && break
    if [ $ATTEMPT -eq $ATTEMPTS ]; then
      echo -e "\nERROR: reached maximum attempts ($ATTEMPTS)"
      delete_instance $INSTANCE_ID
      delete_image $IMAGE_ID
      exit 1
    fi
    ATTEMPT=$((ATTEMPT+1))
    sleep 10
done
echo

IP_ADDRESS=$(openstack server show -f value -c accessIPv4 ${INSTANCE_ID})
echo "Found instance IP address: $IP_ADDRESS"

# Discover which user account to use
if [ "${BUILDER_TYPE}" == "qemu" ]; then
    if echo "${NAME}" | grep -qi debian; then
        USER_ACCOUNT=debian
    elif echo "${NAME}" | grep -q ubuntu; then
        USER_ACCOUNT=ubuntu
    elif echo "${NAME}" | grep -q fedora; then
        USER_ACCOUNT=fedora
    else
        USER_ACCOUNT=ec2-user
    fi
else
    USER_ACCOUNT=$(jq -r '.builders[0].ssh_username' ${NAME}.json)
    # Default centos is different to what we use
    [ "$USER_ACCOUNT" = "centos" ] && USER_ACCOUNT=ec2-user
fi

# Sleep 60 seconds for instance boot to settle
echo "Waiting 60 seconds for instance to settle..."
sleep 60

ATTEMPT=1
echo -n "Checking for SSH connection $USER_ACCOUNT@$IP_ADDRESS"
while [ $ATTEMPT -le $ATTEMPTS ]; do
    echo -n '.'
    ssh -q -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$IP_ADDRESS exit 2>&1 >/dev/null
    [ $? -eq 0 ] && break
    if [ $ATTEMPT -eq $ATTEMPTS ]; then
      # One last attempt with output
      echo -e "\nERROR: reached maximum attempts ($ATTEMPTS)"
      ssh -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$IP_ADDRESS exit
      delete_instance $INSTANCE_ID
      delete_image $IMAGE_ID
      exit 1
    fi
    ATTEMPT=$((ATTEMPT+1))
    sleep 10
done
echo

# Sleep 60 seconds for instance boot to settle
echo "Waiting 60 seconds for instance to settle..."
sleep 60

echo "Running tests (ssh $USER_ACCOUNT@$IP_ADDRESS '/bin/bash /usr/nectar/run_tests.sh')..."
ssh -oBatchMode=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER_ACCOUNT@$IP_ADDRESS '/bin/bash /usr/nectar/run_tests.sh'

# Complete
delete_instance $INSTANCE_ID
delete_image $IMAGE_ID
