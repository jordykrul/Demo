/**
 * Initialize some test assets and participants useful for running a demo.
 * @param {pulse.nl.Init} init - the SetupDemo transaction
 * @transaction
 */
async function init(init) {  // eslint-disable-line no-unused-vars

  const factory = getFactory();
  const NS = 'pulse.nl';

  // create the transporter
  const transporter = factory.newResource(NS, 'Transporter', 'jan.janssen@247trans.nl');
  const transporterOrg = factory.newConcept(NS, 'Organisation');
  transporterOrg.name = '247trans';
  transporterOrg.country = 'Nederland';
  transporterOrg.city = 'Einhoven';
  transporter.organisation = transporterOrg;
  transporter.firstName = 'Jan';
  transporter.lastName = 'Janssen';

  // create the buyer
  const buyer = factory.newResource(NS, 'Buyer', 'jos.jossen@247buy.nl');
  const buyerOrg = factory.newConcept(NS, 'Organisation');
  buyerOrg.name = '247buy';
  buyerOrg.country = 'Nederland';
  buyerOrg.city = 'Venlo';
  buyer.organisation = buyerOrg;
  buyer.firstName = 'Jos';
  buyer.lastName = 'Jossen';

  // create the seller
  const seller = factory.newResource(NS, 'Seller', 'kim.kimmen@247sell.nl');
  const sellerOrg = factory.newConcept(NS, 'Organisation');
  sellerOrg.name = '247sell';
  sellerOrg.country = 'Nederland';
  sellerOrg.city = 'Heerlen';
  seller.organisation = sellerOrg;
  seller.firstName = 'Kim';
  seller.lastName = 'Kimmen';

  // create the contract
  const contract = factory.newResource(NS, 'Contract', 'CON_001');
  contract.transporter = factory.newRelationship(NS, 'Transporter', 'jan.janssen@247trans.nl');
  contract.seller = factory.newRelationship(NS, 'Seller', 'kim.kimmen@247sell.nl');
  contract.buyer = factory.newRelationship(NS, 'Buyer', 'jos.jossen@247buy.nl');
  const tomorrow = init.timestamp;
  tomorrow.setDate(tomorrow.getDate() + 1);
  contract.arrivalDateTime = tomorrow; // the shipment has to arrive tomorrow
  contract.unitPrice = 0.5; // pay 50 cents per unit
  contract.minQuality = 8.3;


  // create the shipment
  const shipment = factory.newResource(NS, 'Shipment', 'SHIP_001');
  shipment.material = 'METAL';
  shipment.status = 'CREATED';
  shipment.unitCount = 5000;
  shipment.contract = factory.newRelationship(NS, 'Contract', 'CON_001');

  // add the growers
  const growerRegistry = await getParticipantRegistry(NS + '.Transporter');
  await growerRegistry.addAll([transporter]);

  // add the importers
  const importerRegistry = await getParticipantRegistry(NS + '.Seller');
  await importerRegistry.addAll([seller]);

  // add the shippers
  const shipperRegistry = await getParticipantRegistry(NS + '.Buyer');
  await shipperRegistry.addAll([buyer]);

  // add the contracts
  const contractRegistry = await getAssetRegistry(NS + '.Contract');
  await contractRegistry.addAll([contract]);

  // add the shipments
  const shipmentRegistry = await getAssetRegistry(NS + '.Shipment');
  await shipmentRegistry.addAll([shipment]);
}