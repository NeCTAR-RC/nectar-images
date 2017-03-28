#!/bin/bash -e

FILE=$1
if [ -z ${FILE} ]; then
    echo "Usage: $0 [JSONFILE]"
    exit 1
fi

# Find packer
if hash packer >/dev/null 2>&1; then
    PACKER=packer
elif hash packer-io >/dev/null 2>&1; then
    PACKER=packer-io
else
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

# Source build config
. "$(basename $0 .sh).cfg"

read_val() {
  jq -r ".builders[0].${1}" $PACKER_WORKING_FILE
}

write_val() {
  TMPFILE=$(mktemp)
  jq ".builders[0].${1} = \"${2}\"" $PACKER_WORKING_FILE > $TMPFILE
  mv $TMPFILE $PACKER_WORKING_FILE
}

cp $FILE $PACKER_WORKING_FILE
BUILDER_TYPE=$(read_val type)

if [ -z $ORGANISATION ]; then
    IMAGE_NAME=${NAME}
else
    IMAGE_NAME="${ORGANISATION} ${NAME}"
fi

if [ "${OS_USERNAME}" != "${IMAGEBUILDER_USERNAME}" ]; then
    echo "Please load the OpenStack credentials for ${IMAGEBUILDER_USERNAME}"
    exit 1
fi

if ! ssh-add -l | grep -q "$TEST_SSH_KEY"; then
    echo "Please load $TEST_SSH_KEY testing SSH key to your agent"
    exit 1
fi

if [ -d ${OUTPUT_DIR} ]; then
    echo "Cleaning up existing output directory \"${OUTPUT_DIR}\"..."
    rm -fr ${OUTPUT_DIR}
fi

if [ "${BUILDER_TYPE}" == "qemu" ]; then
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        write_val headless true
    else
        write_val headless false
        #sed -i 's/console=ttyS0,115200n8//g' $PACKER_WORKING_FILE
    fi

    write_val vm_name "${BUILD_NAME}"
else
    write_val image_name "${BUILD_NAME}"
    write_val flavor "${BUILD_FLAVOUR}"
fi

echo "Building image ${NAME}..."
${PACKER} build $PACKER_WORKING_FILE
rm -f $PACKER_WORKING_FILE

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

if [ ! -z $BUILD_PROPERTY ]; then
    GLANCE_ARGS="--property ${BUILD_PROPERTY}=${BUILD_NUMBER}"
fi

if [ "$MAKE_PUBLIC" == "true" ] ; then
    GLANCE_ARGS="--public ${GLANCE_ARGS}"
fi

echo "Creating image \"${IMAGE_NAME}\"..."
echo "--> openstack image create --disk-format qcow2 --container-format bare --file ${OUTPUT_DIR}/${BUILD_NAME}.qcow2 ${GLANCE_ARGS} \"${IMAGE_NAME}\""
IMAGE_ID=$(openstack image create -f value -c id --disk-format qcow2 --container-format bare --file ${OUTPUT_DIR}/${BUILD_NAME}.qcow2 ${GLANCE_ARGS} "${IMAGE_NAME}")
echo "Found image ID: ${IMAGE_ID}"
rm -f ${OUTPUT_DIR}/${BUILD_NAME}.qcow2

# Any extra image build props - we use this for Murano
if [[ "$NAME" =~ "murano" ]]; then
    openstack image set --property murano_image_info="{\"title\": \"${IMAGE_NAME}\", \"type\": \"linux\"}" ${IMAGE_ID}
fi

echo "Creating instance \"test_${NAME}_${BUILD_NUMBER}\"..."
echo "--> openstack server create --image ${IMAGE_ID} --flavor ${TEST_FLAVOUR} --key-name ${TEST_SSH_KEY} \"${BUILD_NAME}\""
INSTANCE_ID=$(openstack server create -f value -c id --image ${IMAGE_ID} --flavor ${TEST_FLAVOUR} --key-name ${TEST_SSH_KEY} "${BUILD_NAME}")
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
      openstack image delete $IMAGE_ID
      openstack server delete $INSTANCE_ID
      exit 1
    fi
    [ "$STATUS" = "ACTIVE" ] && break
    if [ $ATTEMPT -eq $ATTEMPTS ]; then
      echo -e "\nERROR: reached maximum attempts ($ATTEMPTS)"
      #openstack image delete $IMAGE_ID
      echo "Deleting instance ${INSTANCE_ID}..."
      openstack server delete $INSTANCE_ID
      exit 1
    fi
    ATTEMPT=$((ATTEMPT+1))
    sleep 5
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
      #openstack image delete $IMAGE_ID
      openstack console log show $INSTANCE_ID > ${OUTPUT_DIR}/${BUILD_NAME}-console.txt
      echo "Deleting instance ${INSTANCE_ID}..."
      openstack server delete $INSTANCE_ID
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

echo "Deleting instance ${INSTANCE_ID}..."
openstack server delete $INSTANCE_ID
