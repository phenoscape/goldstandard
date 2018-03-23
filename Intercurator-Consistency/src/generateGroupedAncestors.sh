# Add relations classes
javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/AddRelationClasses.java
java -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/AddRelationClasses

# Querying for superclasses using the Composite ontology after adding relations classes
javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/KR--AD_40718.tsv ../../data/Ancestors40718.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/KR--NI_40716.tsv ../../data/Ancestors40716.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/KR--WD_40717.tsv ../../data/Ancestors40717.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/NR--WD_38484.tsv ../../data/Ancestors38484.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/NR--AD_40674.tsv ../../data/Ancestors40674.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/NR--NI_40676.tsv ../../data/Ancestors40676.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_CP_best.tsv ../../data/AncestorsCP_AllBest.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_CP_InitialOntologies.tsv ../../data/InitialOntologiesAncestors.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_KR--CP_40716.tsv ../../data/AncestorsCP_40716.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_KR--CP_40717.tsv ../../data/AncestorsCP_40717.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_KR--CP_40718.tsv ../../data/AncestorsCP_40718.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_NR--CP_38484.tsv ../../data/AncestorsCP_38484.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_NR--CP_40674.tsv ../../data/AncestorsCP_40674.txt

javac -cp  ".:../../data/owltools-runner-all.jar" ./reasoning/populateAncestorsAll.java
java  -cp  ".:../../data/owltools-runner-all.jar" -Xmx60G reasoning.populateAncestorsAll  ../../data/Transformed_NR--CP_40676.tsv ../../data/AncestorsCP_40676.txt

# Creating a comprehensive Superclass file for all annotations
cat ../../data/AncestorsCP_40676.txt ../../data/AncestorsCP_40674.txt ../../data/AncestorsCP_38484.txt ../../data/AncestorsCP_40718.txt ../../data/AncestorsCP_40717.txt ./../data/AncestorsCP_40716.txt ../../data/InitialOntologiesAncestors.txt ../../data/AncestorsCP_AllBest.txt ../../data/Ancestors40676.txt ../../data/Ancestors40674.txt ../../data/Ancestors38484.txt ../../data/Ancestors40716.txt ../../data/Ancestors40717.txt ../../data/Ancestors40718.txt > ../../data/AllAncestorsCurationExperiment.txt

#!/bin/bash
cp ../../data/AllAncestorsCurationExperiment.txt /usr/local/mysql-5.6.10-osx10.7-x86_64/data/ontologies/AllAncestorsCurationExperiment.txt

# Creating and loading superclasses into a database
mysql << EOF

use ontologies;

drop table tbl_allancestorscurationexperiment;
CREATE TABLE IF NOT EXISTS tbl_allancestorscurationexperiment (   id int(100) NOT NULL AUTO_INCREMENT,   term varchar(700) DEFAULT NULL,   ancestor varchar(700) DEFAULT NULL,   PRIMARY KEY (id),   UNIQUE KEY uniq (term,ancestor) ) ENGINE=InnoDB AUTO_INCREMENT=1706354 DEFAULT CHARSET=latin1;

LOAD DATA INFILE 'AllAncestorsCurationExperiment.txt' IGNORE INTO TABLE tbl_allancestorscurationexperiment FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' (term, ancestor);

EOF


rm ../../data/AllAncestors_Combinations.txt

python transform.py ../data/NR--CP_40674.tsv
python transform.py ../data/NR--CP_40676.tsv
python transform.py ../data/NR--CP_38484.tsv
python transform.py ../data/KR--CP_40716.tsv
python transform.py ../data/KR--CP_40717.tsv
python transform.py ../data/KR--CP_40718.tsv
python transform.py ../data/CP_best.tsv

# Creating grouped EQ subsumers for annotations
python populategroupedancestors.py ../data/NR--WD_38484.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py ../data/NR--AD_40674.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py ../data/NR--NI_40676.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py ../data/KR--NI_40716.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py ../data/KR--WD_40717.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py ../data/KR--AD_40718.tsv 1 tbl_allancestorscurationexperiment C_EQ_

python populategroupedancestors.py ../data/Transformed_NR--CP_40674.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_NR--CP_40676.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_NR--CP_38484.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_KR--CP_40716.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_KR--CP_40717.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_KR--CP_40718.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_CP_best.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_CP2012_Biocreative.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py ../data/Transformed_CP_InitialOntologies.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
