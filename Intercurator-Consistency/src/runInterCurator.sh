# Computing IC of subsumers
python getIC-combination.py ../data/AllAncestors_Combinations.txt ../data/IC-combination.txt

# Create output directories
mkdir ../data/CombinedComparisons
mkdir ../data/CombinedComparisons/PerEQSimScores


# Computing semantic similarity for all comparisons
python computeSim.py ../data/NR--WD_38484.tsv ../data/NR--AD_40674.tsv 1
python computeSim.py ../data/NR--WD_38484.tsv ../data/NR--NI_40676.tsv 1
python computeSim.py ../data/NR--AD_40674.tsv ../data/NR--NI_40676.tsv 1
python computeSim.py ../data/KR--WD_40717.tsv ../data/KR--NI_40716.tsv 1
python computeSim.py ../data/KR--WD_40717.tsv ../data/KR--AD_40718.tsv 1
python computeSim.py ../data/KR--AD_40718.tsv ../data/KR--NI_40716.tsv 1

python computeSim.py ../data/NR--AD_40674.tsv ../data/Transformed_NR--CP_40674.tsv 1
python computeSim.py ../data/NR--NI_40676.tsv ../data/Transformed_NR--CP_40676.tsv 1
python computeSim.py ../data/NR--WD_38484.tsv ../data/Transformed_NR--CP_38484.tsv 1
python computeSim.py ../data/KR--NI_40716.tsv ../data/Transformed_KR--CP_40716.tsv 1
python computeSim.py ../data/KR--WD_40717.tsv ../data/Transformed_KR--CP_40717.tsv 1
python computeSim.py ../data/KR--AD_40718.tsv ../data/Transformed_KR--CP_40718.tsv 1

python computeSim.py ../data/NR--AD_40674.tsv ../data/Transformed_CP_best.tsv 1
python computeSim.py ../data/NR--NI_40676.tsv ../data/Transformed_CP_best.tsv 1
python computeSim.py ../data/NR--WD_38484.tsv ../data/Transformed_CP_best.tsv 1
python computeSim.py ../data/KR--NI_40716.tsv ../data/Transformed_CP_best.tsv 1
python computeSim.py ../data/KR--WD_40717.tsv ../data/Transformed_CP_best.tsv 1
python computeSim.py ../data/KR--AD_40718.tsv ../data/Transformed_CP_best.tsv 1


python computeSim.py ../data/NR--AD_40674.tsv ../data/Transformed_CP_InitialOntologies.tsv 1
python computeSim.py ../data/NR--NI_40676.tsv ../data/Transformed_CP_InitialOntologies.tsv 1
python computeSim.py ../data/NR--WD_38484.tsv ../data/Transformed_CP_InitialOntologies.tsv 1
python computeSim.py ../data/KR--NI_40716.tsv ../data/Transformed_CP_InitialOntologies.tsv 1
python computeSim.py ../data/KR--WD_40717.tsv ../data/Transformed_CP_InitialOntologies.tsv 1
python computeSim.py ../data/KR--AD_40718.tsv ../data/Transformed_CP_InitialOntologies.tsv 1

python computeSim.py ../data/NR--WD_38484.tsv ../data/KR--WD_40717.tsv 1
python computeSim.py ../data/NR--AD_40674.tsv ../data/KR--AD_40718.tsv 1
python computeSim.py ../data/NR--NI_40676.tsv ../data/KR--NI_40716.tsv 1

# Conducting statistical tests
python stats.py