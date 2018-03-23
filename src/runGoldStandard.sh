# compute semantic similarity between curators, CP to the Gold Standard in different settings
### NEEDS AllAncestors_Combinations.txt zip file is also too big for Github - Download from https://www.dropbox.com/s/q3e6ui6ti2vpmxx/AllAncestors_Combinations.txt?dl=0
## Unzip all zip files
python computeSim.py 
# compute Partial Precision and Partial Recall for all comparisons
python compute-PR-PP.py 

# run statistical tests
python stats.py 

# Run ../../Intercurator-Consistency/src/runInterCurator.sh before running below. 
# generate figures
Rscript figure3.R
Rscript figure4.R
Rscript figure5.R