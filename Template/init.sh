composer card create -p connection-org1-only.json -u PeerAdmin -c crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem -k crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/09db3cac0c7fbc5858627cf02605e819281433a0f5d068ad7c6646846f7e99e6_sk -r PeerAdmin -r ChannelAdmin
composer card import -f PeerAdmin@byfn-network-org1-only.card

composer card create -p connection-org1.json -u PeerAdmin -c crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem -k crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/09db3cac0c7fbc5858627cf02605e819281433a0f5d068ad7c6646846f7e99e6_sk -r PeerAdmin -r ChannelAdmin
composer card import -f PeerAdmin@byfn-network-org1.card

composer card create -p connection-org2-only.json -u PeerAdmin -c crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem -k crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/7d024d4c183e3c7ea6a7ebc2e0cc5d7b58e09a1044c20a075f955c1c3a32cab1_sk -r PeerAdmin -r ChannelAdmin
composer card import -f PeerAdmin@byfn-network-org2-only.card

composer card create -p connection-org2.json -u PeerAdmin -c crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts/Admin@org2.example.com-cert.pem -k crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/7d024d4c183e3c7ea6a7ebc2e0cc5d7b58e09a1044c20a075f955c1c3a32cab1_sk -r PeerAdmin -r ChannelAdmin
composer card import -f PeerAdmin@byfn-network-org2.card

composer runtime install -c PeerAdmin@byfn-network-org1-only -n tutorial-network
composer runtime install -c PeerAdmin@byfn-network-org2-only -n tutorial-network

composer identity request -c PeerAdmin@byfn-network-org1-only -u admin -s adminpw -d alice
composer identity request -c PeerAdmin@byfn-network-org2-only -u admin -s adminpw -d bob


composer network start -c PeerAdmin@byfn-network-org1 -a tutorial-network.bna -o endorsementPolicyFile=endorsement-policy.json -A alice -C alice/admin-pub.pem -A bob -C bob/admin-pub.pem


composer card create -p connection-org1.json -u alice -n tutorial-network -c alice/admin-pub.pem -k alice/admin-priv.pem
composer card import -f alice@tutorial-network.card
composer network ping -c alice@tutorial-network


composer card create -p connection-org2.json -u bob -n tutorial-network -c bob/admin-pub.pem -k bob/admin-priv.pem
composer card import -f bob@tutorial-network.card
composer network ping -c bob@tutorial-network