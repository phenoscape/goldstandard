# Map Uberon temp IDs to permanent IDs
python convertUBERONTEMP.py > ../data/UnaccountedTerms.txt

# Creating the composite ontology that includes Uberon, PATO, BSPO, and GO
../data/OWLTools-2015/owltools-read-only/OWLTools-Runner/bin/owltools ../Ontologies/BestMerged.owl ../Ontologies/uberon.owl ../Ontologies/go.owl ../Ontologies/pato-simple.owl ../Ontologies/bspo.owl --merge-support-ontologies -o ../Ontologies/MergedOntology_GS.owl


# Adding relations classes to the composite ontology
javac -cp  ".:../data/OWLTools-2015/owltools-read-only/OWLTools-Runner/bin/owltools-runner-all.jar" ./reasoning/AddRelationsClasses.java

java  -cp  ".:../data/OWLTools-2015/owltools-read-only/OWLTools-Runner/bin/owltools-runner-all.jar" -Xmx60G reasoning.AddRelationsClasses ../data/MergedOntology_GS.owl ../data/MergedOntology_GS_Relations.owl

# Querying for superclasses of all classes in the Merged ontology with relations classes
javac -cp  ".:../data/org.semanticweb.owl.owlapi-4.1.jar:../data/elk-owlapi.jar:../data/log4j-1.2.17.jar" ./reasoning/GetAncestors.java

java  -cp  ".:../data/org.semanticweb.owl.owlapi-4.1.jar:../data/elk-owlapi.jar:../data/log4j-1.2.17.jar" -Xmx80G reasoning.GetAncestors


cat ../data/MappedAnnotations/*tsv > ../data/AllAnnotations.tsv

cp ../data/AnnotationSubsumers_Relations.txt /usr/local/mysql-5.6.10-osx10.7-x86_64/data/ontologies/AnnotationSubsumers_Relations.txt

mysql << EOF
use ontologies;
drop table tbl_goldstandardanalysis;

CREATE TABLE IF NOT EXISTS tbl_goldstandardanalysis (   id int(100) NOT NULL AUTO_INCREMENT,   term varchar(700) DEFAULT NULL,   ancestor varchar(700) DEFAULT NULL,   PRIMARY KEY (id),   UNIQUE KEY uniq (term,ancestor) ) ENGINE=InnoDB AUTO_INCREMENT=1706354 DEFAULT CHARSET=latin1;


LOAD DATA INFILE 'AnnotationSubsumers_Relations.txt' IGNORE INTO TABLE tbl_goldstandardanalysis FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' (term, ancestor);

EOF


rm ../data/AllAncestors_Combinations.txt

# Populate grouped ancestors for all annotation files
python populategroupedancestors.py ../data/MappedAnnotations/NR--WD_38484.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/NR--AD_40674.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/NR--NI_40676.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/KR--NI_40716.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/KR--WD_40717.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/KR--AD_40718.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/GS_Dataset.tsv 1 tbl_goldstandardanalysis C_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_CP_best.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_NR--CP_38484.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_NR--CP_40674.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_NR--CP_40676.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_KR--CP_40716.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_KR--CP_40717.tsv 1 tbl_goldstandardanalysis CP_EQ_
python populategroupedancestors.py ../data/MappedAnnotations/Transformed_KR--CP_40718.tsv 1 tbl_goldstandardanalysis CP_EQ_
