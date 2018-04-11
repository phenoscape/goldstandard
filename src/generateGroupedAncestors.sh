# This should come with installing the dependency OWLTools
# (https://github.com/owlcollab/owltools)
OWLTOOLS=/path/to/OWLTools-Runner/bin/owltools

# also ensure to set CLASSPATH to include the Java dependencies
JAVAC=javac
JAVA=java

# Either put MySQL client into the path, or set full path here.
# Also, include login credentials if any are needed to connect with full
# DML privileges.
MYSQL=mysql

# where the data and ontologies directories are
DATADIR=../GoldStandardData
ONTOLOGIESDIR=../GoldStandardOntologies

##############################################################################
# -- no more customizations below except for MySQL LOAD DATA INFILE below -- #
##############################################################################

# Map Uberon temp IDs to permanent IDs
python convertUBERONTEMP.py > $DATADIR/UnaccountedTerms.txt

# Creating the composite ontology that includes Uberon, PATO, BSPO, and GO
$OWLTOOLS $ONTOLOGIESDIR/BestMerged.owl $ONTOLOGIESDIR/uberon.owl $ONTOLOGIESDIR/go.owl $ONTOLOGIESDIR/pato-simple.owl $ONTOLOGIESDIR/bspo.owl --merge-support-ontologies -o $ONTOLOGIESDIR/MergedOntology_GS.owl


# Adding relations classes to the composite ontology
$JAVAC ./reasoning/AddRelationsClasses.java

$JAVA -Xmx60G reasoning.AddRelationsClasses $DATADIR/MergedOntology_GS.owl $DATADIR/MergedOntology_GS_Relations.owl

# Querying for superclasses of all classes in the Merged ontology with relations classes
$JAVAC ./reasoning/GetAncestors.java

$JAVA -Xmx80G reasoning.GetAncestors


cat $DATADIR/MappedAnnotations/*tsv > $DATADIR/AllAnnotations.tsv

# This is so we have a hard-codable location for the data file to be loaded
# by mysql below. The assumption here is that the server allows LOCAL INFILE.
# If it doesn't, remove the LOCAL below. If the server is remote, you will
# also need to copy the file instead of /tmp to a directory that the server
# has access to, and then change the path in the LOAD DATA INFILE statement.
cp -p $DATADIR/AnnotationSubsumers_Relations.txt /tmp

$MYSQL << EOF
use ontologies;
drop table tbl_goldstandardanalysis;

CREATE TABLE IF NOT EXISTS tbl_goldstandardanalysis (   id int(100) NOT NULL AUTO_INCREMENT,   term varchar(700) DEFAULT NULL,   ancestor varchar(700) DEFAULT NULL,   PRIMARY KEY (id),   UNIQUE KEY uniq (term,ancestor) ) ENGINE=InnoDB AUTO_INCREMENT=1706354 DEFAULT CHARSET=latin1;


LOAD DATA LOCAL INFILE '/tmp/AnnotationSubsumers_Relations.txt' IGNORE INTO TABLE tbl_goldstandardanalysis FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' (term, ancestor);

EOF


rm $DATADIR/AllAncestors_Combinations.txt

# Populate grouped ancestors for all annotation files
python populategroupedancestors.py $DATADIR/MappedAnnotations/NR--WD_38484.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/NR--AD_40674.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/NR--NI_40676.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/KR--NI_40716.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/KR--WD_40717.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/KR--AD_40718.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/GS_Dataset.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_CP_best.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_NR--CP_38484.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_NR--CP_40674.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_NR--CP_40676.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_KR--CP_40716.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_KR--CP_40717.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py $DATADIR/MappedAnnotations/Transformed_KR--CP_40718.tsv 1 tbl_goldstandardanalysis CP_EQ_
