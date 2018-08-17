#Custom script for starting Hyperledger Fabric network
#Author: Jordy Krul
#Company: Pulse Business Solutions
#Date: 12-7-2018

export PATH=${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

#Variabelen
CHANNEL_NAME="mainchannel"
LANGUAGE=golang
COMPOSE_FILE=docker-compose-cli.yaml
COMPOSE_FILE_COUCH=docker-compose-couch.yaml
COMPOSE_FILE_CAS=docker-compose-cas.yaml
CLI_TIMEOUT=3
CLI_DELAY=3


#Generate Org certificates using Cryptogen tool
function generateCerts (){
	which cryptogen
	if [ "$?" -ne 0 ]; then
	echo "cryptogen tool not found. exiting"
	exit 1
	fi
	echo
	echo "##########################################################"
	echo "##### Generate certificates using cryptogen tool #########"
	echo "##########################################################"

	if [ -d "crypto-config" ]; then
	rm -Rf crypto-config
	fi
	cryptogen generate --config=./crypto-config.yaml
	if [ "$?" -ne 0 ]; then
	echo "Failed to generate certificates..."
	exit 1
	fi
	echo
}

#Replace private keys in template for docker-compose.yaml
function replacePrivateKey () {
	OPTS="-i"
	# Copy the template to the file that will be modified to add the private key
	#cp docker-compose-e2e-template.yaml docker-compose-e2e.yaml
	cp docker-compose-cas-template.yaml docker-compose-cas.yaml

	# The next steps will replace the template's contents with the
	# actual values of the private key file names for the two CAs.
	CURRENT_DIR=$PWD

	#Private key org1
	cd crypto-config/peerOrganizations/org1.pulse.com/ca/
	PRIV_KEY=$(ls *_sk)
	cd "$CURRENT_DIR"
	sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cas.yaml

	#Private key org2
	cd crypto-config/peerOrganizations/org2.pulse.com/ca/
	PRIV_KEY=$(ls *_sk)
	cd "$CURRENT_DIR"
	sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-cas.yaml
}

# Generate orderer genesis block, channel configuration transaction and
# anchor peer update transactions
function generateChannelArtifacts() {
	which configtxgen
	if [ "$?" -ne 0 ]; then
		echo "configtxgen tool not found. exiting"
		exit 1
	fi
	if [ -d "channel-artifacts" ]; then
	rm -Rf channel-artifacts
	fi
	mkdir -p channel-artifacts

	echo "##########################################################"
	echo "#########  Generating Orderer Genesis block ##############"
	echo "##########################################################"
	# Note: For some unknown reason (at least for now) the block file can't be
	# named orderer.genesis.block or the orderer will fail to launch!
	configtxgen -profile PulseOrdererGenisis -outputBlock ./channel-artifacts/genesis.block
	if [ "$?" -ne 0 ]; then
		echo "Failed to generate orderer genesis block..."
		exit 1
	fi
	echo
	echo "#################################################################"
	echo "### Generating channel configuration transaction 'channel.tx' ###"
	echo "#################################################################"
	configtxgen -profile MainChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
	if [ "$?" -ne 0 ]; then
		echo "Failed to generate channel configuration transaction..."
		exit 1
	fi

	echo
	echo "#################################################################"
	echo "#######    Generating anchor peer update for Org1MSP   ##########"
	echo "#################################################################"
	configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
	if [ "$?" -ne 0 ]; then
		echo "Failed to generate anchor peer update for Org1MSP..."
		exit 1
	fi

	echo
	echo "#################################################################"
	echo "#######    Generating anchor peer update for Org2MSP   ##########"
	echo "#################################################################"
	configtxgen -profile MainChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
	if [ "$?" -ne 0 ]; then
		echo "Failed to generate anchor peer update for Org2MSP..."
		exit 1
	fi
}

#Start network
function networkUp () {
	# generate artifacts if they don't exist
	if [ ! -d "crypto-config" ]; then
		generateCerts
		replacePrivateKey
		generateChannelArtifacts
	fi

	COMPOSE_FILE_ADDITIONS=""
	COMPOSE_FILE_ADDITIONS="${COMPOSE_FILE_ADDITIONS} -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_CAS"
	echo COMPOSE_FILE_ADDITIONS

	CHANNEL_NAME=$CHANNEL_NAME TIMEOUT=$CLI_TIMEOUT DELAY=$CLI_DELAY LANG=$LANGUAGE docker-compose -p pulseirp -f ${COMPOSE_FILE} ${COMPOSE_FILE_ADDITIONS} up -d 2>&1
	if [ $? -ne 0 ]; then
		echo "ERROR !!!! Unable to start network"
		docker logs -f cli
		exit 1
	fi
	docker logs -f cli
}

while getopts "m:" opt; do
  case "$opt" in
    m)  MODE=$OPTARG
    ;;
  esac
done

if [ "${MODE}" == "up" ]; then
  networkUp
  elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateCerts
	replacePrivateKey
	generateChannelArtifacts
else 
  echo "No mode found"
  exit 1
fi

