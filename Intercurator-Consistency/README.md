## Inter-curator Similarity Results

* Curators were assigned IDs for the Naive (WD_38484, AD_40674, NI_40676)
  and Knowledge rounds (NI_40716, WD_40717, AD_40718). IDs with the same
  two letter prefix belong to the same curator; hence there were 3 curators
  in total. 
* Charaparser was assigned a two letter prefix of 'CP' and uses the same IDs assigned to the curators. Thus, CP_40716.tsv are the Charaparser annotations obtained using Curator 40716's version of the ontologies. CP_best.tsv is the file with the Charaparser annotations obtained using the merged ontology from all the curators' term requests.    


* The following curator-curator comparisons were conducted :
    * **Naive Round:**

            38484 -- 40674
            40674 -- 40676
            38484 -- 40676

    * **Knowledge Round:**

            40717 -- 40718
            40718 -- 40716
            40717 -- 40716

    * For each curator-curator pair, pairwise comparisons are made between
      the set of EQ annotations for a particular character-state
      combination to the set of EQs for the same character-state
      combination. The best match (highest similarity) from these pairwise
      comparisons is the score associated to the character-state
      combination. 

* The following curator-charaparser comparisons were conducted for CharaParser:
    * **Naive Round:**

            38484 -- CP_38484
            40674 -- CP_40674
            40676 -- CP_40676

    * **Knowledge Round:**

            40716 -- CP_40716
            40717 -- CP_40717
            40718 -- CP_40718

    * **Charaparser Best:**

            38484 -- CP_best
            40674 -- CP_best
            40676 -- CP_best
            40716 -- CP_best
            40717 -- CP_best
            40718 -- CP_best    

    * For each curator-Charaparser pair, pairwise comparisons are made between
      the set of EQ annotations for a particular character-state
      combination to the set of EQs for the same character-state
      combination. The best match (highest similarity) from these pairwise
      comparisons is the score associated to the character-state
      combination. 

### Example

* Curator AD_40674 vs Curator NI_40676, Naive round, Character 1 State 0, 
    * Curator AD_40674 and Curator NI_40676 have 2 EQs each for Character 1 
      State 0. 
    * There are 4 pairwise similarity comparisons in this case and the best
      score from the 4 comparisons is associated to Character 1 State 0 in
      the results file `NR--AD_40674--NI_40676.tsv`.


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

* The ontology used for this analysis is ./Ontologies/Best_Relations.owl. The ontology was used for all intercurator and charaparser-curator analyses.

## Pipeline

* All the commands (in order) used to generate results for the manuscript are listed in ./src/runintercuratoranalysis.sh