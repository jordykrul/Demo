#!/bin/bash -eu
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# This script pulls docker images from the Dockerhub hyperledger repositories

# set the default Docker namespace and tag
IP=localhost:5000
DOCKER_NS=$IP
ARCH=x86_64
VERSION=1.2.0
BASE_DOCKER_TAG=x86_64-0.4.6

# set of Hyperledger Fabric images
FABRIC_IMAGES=(fabric-peer fabric-orderer fabric-ccenv fabric-ca fabric-kafka fabric-zookeeper fabric-couchdb fabric-tools)

for image in ${FABRIC_IMAGES[@]}; do
  echo "Pulling ${DOCKER_NS}/$image:${ARCH}-${VERSION}"
  docker pull ${DOCKER_NS}/$image
done
