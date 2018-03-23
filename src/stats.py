def test_c_NvsK():
	filename='../data/CombinedComparisons/NR--AD_40674--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/KR--AD_40718--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Score'],y=kr_df['SimJ Score'])
	print "Naive vs Knowledge C2 SimJ",p,t,np.round(np.mean(kr_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=nr_df['NIC Score'],y=kr_df['NIC Score'])
	print "Naive vs Knowledge C2 IC",p,t,np.round(np.mean(kr_df['NIC Score']),3)
	

	filename="../data/CombinedComparisons/NR--NI_40676--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/KR--NI_40716--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Score'],y=kr_df['SimJ Score'])
	print "Naive vs Knowledge C3 SimJ",p,t,np.round(np.mean(kr_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=nr_df['NIC Score'],y=kr_df['NIC Score'])
	print "Naive vs Knowledge C3 IC",p,t,np.round(np.mean(kr_df['NIC Score']),3)
	

	
	filename="../data/CombinedComparisons/NR--WD_38484--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/KR--WD_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Score'],y=kr_df['SimJ Score'])
	print "Naive vs Knowledge C1 SimJ",p,t,np.round(np.mean(kr_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=nr_df['NIC Score'],y=kr_df['NIC Score'])
	print "Naive vs Knowledge C1 IC",p,t,np.round(np.mean(kr_df['NIC Score']),3)


	#PR - C2
	filename='../data/CombinedComparisons/PR_NR--AD_40674--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/PR_KR--AD_40718--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Partial Recall'],y=kr_df['SimJ Partial Recall'])
	print "Naive vs Knowledge C2 PR",p,t,np.round(np.mean(kr_df['SimJ Partial Recall']),3)

	#PP - C2
	filename='../data/CombinedComparisons/PP_NR--AD_40674--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/PP_KR--AD_40718--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Partial Precision'],y=kr_df['SimJ Partial Precision'])
	print "Naive vs Knowledge C2 PP",p,t,np.round(np.mean(kr_df['SimJ Partial Precision']),3)



	# PP - C3
	filename='../data/CombinedComparisons/PP_NR--NI_40676--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/PP_KR--NI_40716--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Partial Precision'],y=kr_df['SimJ Partial Precision'])
	print "Naive vs Knowledge C3 PP",p,t,np.round(np.mean(kr_df['SimJ Partial Precision']),3)

	# PR - C3
	filename='../data/CombinedComparisons/PR_NR--NI_40676--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/PR_KR--NI_40716--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Partial Recall'],y=kr_df['SimJ Partial Recall'])
	print "Naive vs Knowledge C3 PR",p,t,np.round(np.mean(kr_df['SimJ Partial Recall']),3)



	# PP - C1
	filename='../data/CombinedComparisons/PP_NR--WD_38484--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/PP_KR--WD_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Partial Precision'],y=kr_df['SimJ Partial Precision'])
	print "Naive vs Knowledge C1 PP",p,t,np.round(np.mean(kr_df['SimJ Partial Precision']),3)

	# PR - C1
	filename='../data/CombinedComparisons/PR_NR--WD_38484--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	nr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename="../data/CombinedComparisons/PR_KR--WD_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	kr_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=nr_df['SimJ Partial Recall'],y=kr_df['SimJ Partial Recall'])
	print "Naive vs Knowledge C1 PR",p,t,np.round(np.mean(kr_df['SimJ Partial Recall']),3)




def test_ontology_completeness():
	# Testing only Augmented vs. Best
	filename='../data/CombinedComparisons/Transformed_CP_best--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	best_df = pd.read_csv(filename,header = 0,delimiter="\t")
	filename='../data/CombinedComparisons/PP_Transformed_CP_best--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	best_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	filename='../data/CombinedComparisons/PR_Transformed_CP_best--GS_Dataset.tsv'
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	best_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")


	filename="../data/CombinedComparisons/PP_Transformed_NR--CP_38484--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pp['SimJ Partial Precision'],y=aug_df_pp['SimJ Partial Precision'])
	print "Best vs Augmented Naive C1 PP",p,t,np.round(np.mean(aug_df_pp['SimJ Partial Precision']),3)
	filename="../data/CombinedComparisons/PP_Transformed_KR--CP_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pp['SimJ Partial Precision'],y=aug_df_pr['SimJ Partial Precision'])
	print "Best vs Augmented Knowledge C1 PP",p,t,np.round(np.mean(aug_df_pr['SimJ Partial Precision']),3)

	filename="../data/CombinedComparisons/PR_Transformed_NR--CP_38484--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pr['SimJ Partial Recall'],y=aug_df_pp['SimJ Partial Recall'])
	print "Best vs Augmented Naive C1 PR",p,t,np.round(np.mean(aug_df_pp['SimJ Partial Recall']),3)
	filename="../data/CombinedComparisons/PR_Transformed_KR--CP_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pr['SimJ Partial Recall'],y=aug_df_pr['SimJ Partial Recall'])
	print "Best vs Augmented Knowledge C1 PR",p,t,np.round(np.mean(aug_df_pr['SimJ Partial Recall']),3)


	filename="../data/CombinedComparisons/Transformed_NR--CP_38484--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df['SimJ Score'],y=aug_df['SimJ Score'])
	print "Best vs Augmented Naive C1 SimJ",p,t,np.round(np.mean(aug_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=best_df['NIC Score'],y=aug_df['NIC Score'])
	print "Best vs Augmented Naive C1 IC",p,t,np.round(np.mean(aug_df['NIC Score']),3)



	filename="../data/CombinedComparisons/Transformed_KR--CP_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df['SimJ Score'],y=aug_df['SimJ Score'])
	print "Best vs Augmented Knowledge C1 SimJ",p,t,np.round(np.mean(aug_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=best_df['NIC Score'],y=aug_df['NIC Score'])
	print "Best vs Augmented Knowledge C1 IC",p,t,np.round(np.mean(aug_df['NIC Score']),3)


	filename="../data/CombinedComparisons/PP_Transformed_NR--CP_40674--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pp['SimJ Partial Precision'],y=aug_df_pp['SimJ Partial Precision'])
	print "Best vs Augmented Naive C2 PP",p,t,np.round(np.mean(aug_df_pp['SimJ Partial Precision']),3)
	filename="../data/CombinedComparisons/PR_Transformed_NR--CP_40674--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pr['SimJ Partial Recall'],y=aug_df_pr['SimJ Partial Recall'])
	print "Best vs Augmented Naive C2 PR",p,t,np.round(np.mean(aug_df_pr['SimJ Partial Recall']),3)



	filename="../data/CombinedComparisons/PP_Transformed_KR--CP_40718--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pp['SimJ Partial Precision'],y=aug_df_pp['SimJ Partial Precision'])
	print "Best vs Augmented Knowledge C2 PP",p,t,np.round(np.mean(aug_df_pp['SimJ Partial Precision']),3)
	filename="../data/CombinedComparisons/PR_Transformed_KR--CP_40718--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pr['SimJ Partial Recall'],y=aug_df_pr['SimJ Partial Recall'])
	print "Best vs Augmented Knowledge C2 PR",p,t,np.round(np.mean(aug_df_pr['SimJ Partial Recall']),3)

	filename="../data/CombinedComparisons/Transformed_NR--CP_40674--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df['SimJ Score'],y=aug_df['SimJ Score'])
	print "Best vs Augmented Naive C2 SimJ",p,t,np.round(np.mean(aug_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=best_df['NIC Score'],y=aug_df['NIC Score'])
	print "Best vs Augmented Naive C2 IC",p,t,np.round(np.mean(aug_df['NIC Score']),3)

	filename="../data/CombinedComparisons/Transformed_KR--CP_40718--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df['SimJ Score'],y=aug_df['SimJ Score'])
	print "Best vs Augmented Knowledge C2 SimJ",p,t,np.round(np.mean(aug_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=best_df['NIC Score'],y=aug_df['NIC Score'])
	print "Best vs Augmented Knowledge C2 IC",p,t,np.round(np.mean(aug_df['NIC Score']),3)



	filename="../data/CombinedComparisons/PP_Transformed_NR--CP_40676--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pp['SimJ Partial Precision'],y=aug_df_pp['SimJ Partial Precision'])
	print "Best vs Augmented Naive C3 PP",p,t,np.round(np.mean(aug_df_pp['SimJ Partial Precision']),3)
	filename="../data/CombinedComparisons/PR_Transformed_NR--CP_40676--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pr['SimJ Partial Recall'],y=aug_df_pr['SimJ Partial Recall'])
	print "Best vs Augmented Naive C3 PR",p,t,np.round(np.mean(aug_df_pr['SimJ Partial Recall']),3)



	filename="../data/CombinedComparisons/PP_Transformed_KR--CP_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pp = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pp['SimJ Partial Precision'],y=aug_df_pp['SimJ Partial Precision'])
	print "Best vs Augmented Knowledge C3 PP",p,t,np.round(np.mean(aug_df_pp['SimJ Partial Precision']),3)
	filename="../data/CombinedComparisons/PR_Transformed_KR--CP_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df_pr = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df_pr['SimJ Partial Recall'],y=aug_df_pr['SimJ Partial Recall'])
	print "Best vs Augmented Knowledge C3 PR",p,t,np.round(np.mean(aug_df_pr['SimJ Partial Recall']),3)	


	filename="../data/CombinedComparisons/Transformed_NR--CP_40676--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df['SimJ Score'],y=aug_df['SimJ Score'])
	print "Best vs Augmented Naive C3 SimJ",p,t,np.round(np.mean(aug_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=best_df['NIC Score'],y=aug_df['NIC Score'])
	print "Best vs Augmented Naive C3 IC",p,t,np.round(np.mean(aug_df['NIC Score']),3)

	filename="../data/CombinedComparisons/Transformed_KR--CP_40717--GS_Dataset.tsv"
	cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
	os.system(cmd)
	aug_df = pd.read_csv(filename,header = 0,delimiter="\t")
	t,p=scipy.stats.wilcoxon(x=best_df['SimJ Score'],y=aug_df['SimJ Score'])
	print "Best vs Augmented Knowledge C3 SimJ",p,t,np.round(np.mean(aug_df['SimJ Score']),3)
	t,p=scipy.stats.wilcoxon(x=best_df['NIC Score'],y=aug_df['NIC Score'])
	print "Best vs Augmented Knowledge C3 IC",p,t,np.round(np.mean(aug_df['NIC Score']),3)



def main():
	test_c_NvsK()

	test_ontology_completeness()

if __name__ == "__main__":
	from collections import defaultdict
	import numpy
	import sys
	import os
	import pandas as pd
	import numpy as np
	import scipy.stats
	import math
	import re
	main()