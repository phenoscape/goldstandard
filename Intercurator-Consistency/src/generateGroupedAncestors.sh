# also ensure to set CLASSPATH to include the Java dependencies
JAVAC=javac
JAVA=java

# Either put MySQL client into the path, or set full path here.
# Also, include login credentials if any are needed to connect with full
# DML privileges.
MYSQL=mysql

# where the data and ontologies directories are
DATADIR=../InterCuratorData
ONTOLOGIESDIR=../InterCuratorOntologies

##############################################################################
# -- no more customizations below except for MySQL LOAD DATA INFILE below -- #
##############################################################################

# Add relations classes
$JAVAC  ./reasoning/AddRelationClasses.java
$JAVA ./reasoning/AddRelationClasses

# Querying for superclasses using the Composite ontology after adding relations classes
javac  ./reasoning/populateAncestorsAll.java
$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/KR--AD_40718.tsv $DATADIR/Ancestors40718.txt
$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/KR--NI_40716.tsv $DATADIR/Ancestors40716.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/KR--WD_40717.tsv $DATADIR/Ancestors40717.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/NR--WD_38484.tsv $DATADIR/Ancestors38484.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/NR--AD_40674.tsv $DATADIR/Ancestors40674.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/NR--NI_40676.tsv $DATADIR/Ancestors40676.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_CP_best.tsv $DATADIR/AncestorsCP_AllBest.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_CP_InitialOntologies.tsv $DATADIR/InitialOntologiesAncestors.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_KR--CP_40716.tsv $DATADIR/AncestorsCP_40716.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_KR--CP_40717.tsv $DATADIR/AncestorsCP_40717.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_KR--CP_40718.tsv $DATADIR/AncestorsCP_40718.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_NR--CP_38484.tsv $DATADIR/AncestorsCP_38484.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_NR--CP_40674.tsv $DATADIR/AncestorsCP_40674.txt

$JAVA -Xmx60G reasoning.populateAncestorsAll  $DATADIR/Transformed_NR--CP_40676.tsv $DATADIR/AncestorsCP_40676.txt

# Creating a comprehensive Superclass file for all annotations
cat $DATADIR/AncestorsCP_40676.txt $DATADIR/AncestorsCP_40674.txt $DATADIR/AncestorsCP_38484.txt $DATADIR/AncestorsCP_40718.txt $DATADIR/AncestorsCP_40717.txt $DATADIR/AncestorsCP_40716.txt $DATADIR/InitialOntologiesAncestors.txt $DATADIR/AncestorsCP_AllBest.txt $DATADIR/Ancestors40676.txt $DATADIR/Ancestors40674.txt $DATADIR/Ancestors38484.txt $DATADIR/Ancestors40716.txt $DATADIR/Ancestors40717.txt $DATADIR/Ancestors40718.txt > $DATADIR/AllAncestorsCurationExperiment.txt

# This is so we have a hard-codable location for the data file to be loaded
# by mysql below. The assumption here is that the server allows LOCAL INFILE.
# If it doesn't, remove the LOCAL below. If the server is remote, you will
# also need to copy the file instead of /tmp to a directory that the server
# has access to, and then change the path in the LOAD DATA INFILE statement.
cp -p $DATADIR/AllAncestorsCurationExperiment.txt /tmp/AllAncestorsCurationExperiment.txt

# Creating and loading superclasses into a database
$MYSQL << EOF

use ontologies;

drop table tbl_allancestorscurationexperiment;
CREATE TABLE IF NOT EXISTS tbl_allancestorscurationexperiment (   id int(100) NOT NULL AUTO_INCREMENT,   term varchar(700) DEFAULT NULL,   ancestor varchar(700) DEFAULT NULL,   PRIMARY KEY (id),   UNIQUE KEY uniq (term,ancestor) ) ENGINE=InnoDB AUTO_INCREMENT=1706354 DEFAULT CHARSET=latin1;

LOAD DATA LOCAL INFILE '/tmp/AllAncestorsCurationExperiment.txt' IGNORE INTO TABLE tbl_allancestorscurationexperiment FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' (term, ancestor);

EOF


rm $DATADIR/AllAncestors_Combinations.txt

python transform.py $DATADIR/NR--CP_40674.tsv
python transform.py $DATADIR/NR--CP_40676.tsv
python transform.py $DATADIR/NR--CP_38484.tsv
python transform.py $DATADIR/KR--CP_40716.tsv
python transform.py $DATADIR/KR--CP_40717.tsv
python transform.py $DATADIR/KR--CP_40718.tsv
python transform.py $DATADIR/CP_best.tsv

# Creating grouped EQ subsumers for annotations
python populategroupedancestors.py $DATADIR/NR--WD_38484.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py $DATADIR/NR--AD_40674.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py $DATADIR/NR--NI_40676.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py $DATADIR/KR--NI_40716.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py $DATADIR/KR--WD_40717.tsv 1 tbl_allancestorscurationexperiment C_EQ_
python populategroupedancestors.py $DATADIR/KR--AD_40718.tsv 1 tbl_allancestorscurationexperiment C_EQ_

python populategroupedancestors.py $DATADIR/Transformed_NR--CP_40674.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_NR--CP_40676.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_NR--CP_38484.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_KR--CP_40716.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_KR--CP_40717.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_KR--CP_40718.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_CP_best.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_CP2012_Biocreative.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
python populategroupedancestors.py $DATADIR/Transformed_CP_InitialOntologies.tsv 1 tbl_allancestorscurationexperiment CP_EQ_
