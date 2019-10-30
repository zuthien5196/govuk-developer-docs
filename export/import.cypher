//
//MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r;

// Create Applications
//USING PERIODIC COMMIT
//LOAD CSV WITH HEADERS FROM 'file:///app_nodes.csv' AS line
//FIELDTERMINATOR '\t'
//MERGE (o:Application {name: line.app_name, puppet_name: line.puppet_name, doc_url: line.doc_url})
//;

// Create AWS Machines
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///aws_machine_nodes.csv' AS line
FIELDTERMINATOR '\t'
MERGE (o:AWSMachine {node_class: line.node_class})
;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///app_to_aws_machines_edgelist.csv' AS line
FIELDTERMINATOR '\t'
MATCH (app:Application { name: line.app_name}), (aws_machine:AWSMachine { node_class: line.node_class})
CREATE (aws_machine)-[:HOSTS]->(app)
;

// Create Carrenza Machines
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///carrenza_machine_nodes.csv' AS line
FIELDTERMINATOR '\t'
MERGE (o:CarrenzaMachine {node_class: line.node_class})
;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM 'file:///app_to_carrenza_machines_edgelist.csv' AS line
FIELDTERMINATOR '\t'
MATCH (app:Application { name: line.app_name}), (carrenza_machine:CarrenzaMachine { node_class: line.node_class})
CREATE (carrenza_machine)-[:HOSTS]->(app)
;

