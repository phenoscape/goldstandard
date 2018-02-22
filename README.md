## Gold Standard Analysis

* This repository contains semantic similarity, Partial Precision, and Partial Recall results between curator-gold standard comparisons. 

* Curators were assigned IDs for the Naive (WD_38484, AD_40674, NI_40676)
  and Knowledge rounds (NI_40716, WD_40717, AD_40718). IDs with the same
  two letter prefix belong to the same curator; hence there were 3 curators
  in total. Gold Standard was assigned "GS" as the ID. 
* Annotation rounds are indicated by "NR"= Naive round or "KR" = Knowledge round.
   


* The following curator-GS comparisons were conducted :
    * **Naive Round:**

            38484 -- GS
            40674 -- GS
            38484 -- GS

    * **Knowledge Round:**

            40717 -- GS
            40718 -- GS
            40717 -- GS

    * For each curator-GS pair, pairwise comparisons are made between
      the set of EQ annotations for a particular character-state
      combination to the set of EQs for the same character-state
      combination. The best match (highest similarity) from these pairwise
      comparisons is the score associated to the character-state
      combination. 

* The following GS-charaparser comparisons were conducted for CharaParser:
    * **Naive Round:**

            GS -- CP_38484
            GS -- CP_40674
            GS -- CP_40676

    * **Knowledge Round:**

            GS -- CP_40716
            GS -- CP_40717
            GS -- CP_40718

    * **Charaparser Best:**

            GS -- CP_best
  


## Similarity Metrics Used:

* The results contain scores for the SimJ, NIC, Partial Precision, and Partial Recall metrics. The SimJ score
  for two EQ statements, EQ1 and EQ2 is normally calculated as                      
   (Number of Common Subsumers for EQ1, EQ2 (Intersection) / Number of All
  Subsumers of EQ1, EQ2 (Union))
    * The SimJ score lies in the range of [0,1]
    * If EQ1 and EQ2 are exactly the same, the SimJ score is 1
    * SimJ is not based on Information Content
  The IC score for EQ1,EQ2 is the IC of their least common subsumer. The IC of a term t, is calculated as -log(freq(t)/corpussize). The corpus is the combination of all the curator and charaparser annotations, all ancestors of every annotation. The corpus size is the number of annotations in the corpus. IC scores do not have a fixed range unlike SimJ scores. In order to force the IC scores to lie in the [0,1] range, the IC scores are divided by the maximum possible IC for this dataset resulting in a normalized IC score (NIC). The maximum IC is the score when the frequency of a term is 1. The mean and Median MaxNIC scores reported are the mean and median normalized IC scores. Partial Precision and Partial Recall are computed using the SimJ scores per EQ for each character state. 


## Ontology Used in the Analysis

* The ontology used for this analysis is ./Ontologies/MergedOntology_GS_Relations.owl. 

## Pipeline

* All the commands (in order) used to generate results for the manuscript are listed in ./src/run-goldstandard-analysis.sh
