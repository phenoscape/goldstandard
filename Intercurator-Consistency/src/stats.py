def sortfiles(mypath,dirname):
	# sort score files by character and state
	from os.path import isfile, join
	allfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
	for filename in allfiles:
		if '.tsv' in filename:
			filename='../'+dirname+'/'+filename
			cmd='sort -t "," -k1n,1 -k2n,2 '+filename+' -o'+ filename 
			os.system(cmd)


def getavgList(f1,f2,f3):
	# given three score files for three curator comparisons, get the avg simJ and IC score for a character state
	simjlist=[]
	iclist=[]
	for line in f1:
		count=0
		if "Character" not in line:
			data=line.split("\t")
			simjscore=float(data[2])
			icscore=float(data[3])
			simjlist.append(simjscore)
			iclist.append(icscore)
			count+=1

	count=0
	for line in f2:
		if "Character" not in line:
			data=line.split("\t")
			simjscore=float(data[2])
			icscore=float(data[3])
			simjlist[count]=simjlist[count]+simjscore
			iclist[count]=iclist[count]+icscore
			count+=1

	count=0
	for line in f3:
		if "Character" not in line:
			data=line.split("\t")
			simjscore=float(data[2])
			icscore=float(data[3])
			simjlist[count]=(simjlist[count]+simjscore)/3
			iclist[count]=(iclist[count]+icscore)/3
			count+=1
	
	return simjlist,iclist

def getavgList_pp_pr(f1,f2,f3):
	# given three score files for three curator comparisons, get the avg PP or PR score for a character state
	scorelist=[]
	for line in f1:
		count=0
		if "Character" not in line:
			data=line.split("\t")
			score=float(data[2])
			scorelist.append(score)
			count+=1
	
	count=0
	for line in f2:
		if "Character" not in line:
			data=line.split("\t")
			score=float(data[2])
			scorelist.append(score)
			count+=1


	count=0
	for line in f3:
		if "Character" not in line:
			data=line.split("\t")
			score=float(data[2])
			scorelist.append(score)
			count+=1
	
	return scorelist

def main():
	knowledge_Avg_CC_PP,knowledge_Avg_CC_PR,knowledge_Avg_CC_SimJ,knowledge_Avg_CC_IC=Intercurator_Naive_vs_Knowledge()
	Human_CP(knowledge_Avg_CC_PP,knowledge_Avg_CC_PR,knowledge_Avg_CC_SimJ,knowledge_Avg_CC_IC)
	OntologyCompleteness()


def Intercurator_Naive_vs_Knowledge():
	sortfiles('../sim-scores/',"sim-scores")
	sortfiles('../precision-recall-scores/',"precision-recall-scores")
	f1=open('../sim-scores/NR--WD_38484--AD_40674.tsv','r')
	f2=open('../sim-scores/NR--AD_40674--NI_40676.tsv','r')
	f3=open('../sim-scores/NR--WD_38484--NI_40676.tsv','r')
	naive_Avg_CC_SimJ,naive_Avg_CC_IC=getavgList(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()


	f1=open('../sim-scores/KR--WD_40717--AD_40718.tsv','r')
	f2=open('../sim-scores/KR--AD_40718--NI_40716.tsv','r')
	f3=open('../sim-scores/KR--WD_40717--NI_40716.tsv','r')
	knowledge_Avg_CC_SimJ,knowledge_Avg_CC_IC=getavgList(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PP_KR--WD_40717--AD_40718.tsv','r')
	f2=open('../precision-recall-scores/PP_KR--AD_40718--NI_40716.tsv','r')
	f3=open('../precision-recall-scores/PP_KR--WD_40717--NI_40716.tsv','r')
	knowledge_Avg_CC_PP=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PP_NR--WD_38484--AD_40674.tsv','r')
	f2=open('../precision-recall-scores/PP_NR--AD_40674--NI_40676.tsv','r')
	f3=open('../precision-recall-scores/PP_NR--WD_38484--NI_40676.tsv','r')
	naive_Avg_CC_PP=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PR_KR--WD_40717--AD_40718.tsv','r')
	f2=open('../precision-recall-scores/PR_KR--AD_40718--NI_40716.tsv','r')
	f3=open('../precision-recall-scores/PR_KR--WD_40717--NI_40716.tsv','r')
	knowledge_Avg_CC_PR=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PR_NR--WD_38484--AD_40674.tsv','r')
	f2=open('../precision-recall-scores/PR_NR--AD_40674--NI_40676.tsv','r')
	f3=open('../precision-recall-scores/PR_NR--WD_38484--NI_40676.tsv','r')
	naive_Avg_CC_PR=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	# Testing Inter-curator Naive vs Knowledge Round
	t,p=scipy.stats.wilcoxon(x=naive_Avg_CC_SimJ,y=knowledge_Avg_CC_SimJ)
	print "Naive vs Knowledge Inter-curator SimJ p-value",p

	t,p=scipy.stats.wilcoxon(x=naive_Avg_CC_IC,y=knowledge_Avg_CC_IC)
	print "Naive vs Knowledge Inter-curator SimJ p-value",p

	t,p=scipy.stats.wilcoxon(x=naive_Avg_CC_PP,y=knowledge_Avg_CC_PP)
	print "Naive vs Knowledge Inter-curator PP p-value",p

	t,p=scipy.stats.wilcoxon(x=naive_Avg_CC_PR,y=knowledge_Avg_CC_PR)
	print "Naive vs Knowledge Inter-curator PR p-value",p
	
	return knowledge_Avg_CC_PP,knowledge_Avg_CC_PR,knowledge_Avg_CC_SimJ,knowledge_Avg_CC_IC



def Human_CP(knowledge_Avg_CC_PP,knowledge_Avg_CC_PR,knowledge_Avg_CC_SimJ,knowledge_Avg_CC_IC):
	# Computing Knowledge round scores only for manuscript
	# Compare CP best to CC
	
	f1=open('../sim-scores/KR--WD_40717--CP_best.tsv','r')
	f2=open('../sim-scores/KR--AD_40718--CP_best.tsv','r')
	f3=open('../sim-scores/KR--NI_40716--CP_best.tsv','r')
	knowledge_Avg_CPCC_SimJ,knowledge_Avg_CPCC_IC=getavgList(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PP_KR--WD_40717--CP_best.tsv','r')
	f2=open('../precision-recall-scores/PP_KR--AD_40718--CP_best.tsv','r')
	f3=open('../precision-recall-scores/PP_KR--NI_40716--CP_best.tsv','r')
	knowledge_Avg_CPCC_PP=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PR_KR--WD_40717--CP_best.tsv','r')
	f2=open('../precision-recall-scores/PR_KR--AD_40718--CP_best.tsv','r')
	f3=open('../precision-recall-scores/PR_KR--NI_40716--CP_best.tsv','r')
	knowledge_Avg_CPCC_PR=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()	

	
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_CC_SimJ,y=knowledge_Avg_CPCC_SimJ)
	print "Knowledge CP Best vs CC SimJ p-value",p

	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_CC_IC,y=knowledge_Avg_CPCC_IC)
	print "Knowledge CP Best vs CC IC p-value",p

	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_CC_PP,y=knowledge_Avg_CPCC_PP)
	print "Knowledge CP Best vs CC PP p-value",p

	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_CC_PR,y=knowledge_Avg_CPCC_PR)
	print "Knowledge CP Best vs CC PR p-value",p

def OntologyCompleteness():

	# Doing this comparison for Knowledge only for manuscript

	f1=open('../precision-recall-scores/PR_KR--WD_40717--CP_InitialOntologies.tsv','r')
	f2=open('../precision-recall-scores/PR_KR--AD_40718--CP_InitialOntologies.tsv','r')
	f3=open('../precision-recall-scores/PR_KR--NI_40716--CP_InitialOntologies.tsv','r')
	knowledge_Avg_Initial_CPCC_PR=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PR_KR--WD_40717--CP_40717.tsv','r')
	f2=open('../precision-recall-scores/PR_KR--AD_40718--CP_40718.tsv','r')
	f3=open('../precision-recall-scores/PR_KR--NI_40716--CP_40716.tsv','r')
	knowledge_Avg_Aug_CPCC_PR=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PR_KR--WD_40717--CP_best.tsv','r')
	f2=open('../precision-recall-scores/PR_KR--AD_40718--CP_best.tsv','r')
	f3=open('../precision-recall-scores/PR_KR--NI_40716--CP_best.tsv','r')
	knowledge_Avg_Best_CPCC_PR=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()


	f1=open('../precision-recall-scores/PP_KR--WD_40717--CP_InitialOntologies.tsv','r')
	f2=open('../precision-recall-scores/PP_KR--AD_40718--CP_InitialOntologies.tsv','r')
	f3=open('../precision-recall-scores/PP_KR--NI_40716--CP_InitialOntologies.tsv','r')
	knowledge_Avg_Initial_CPCC_PP=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PP_KR--WD_40717--CP_40717.tsv','r')
	f2=open('../precision-recall-scores/PP_KR--AD_40718--CP_40718.tsv','r')
	f3=open('../precision-recall-scores/PP_KR--NI_40716--CP_40716.tsv','r')
	knowledge_Avg_Aug_CPCC_PP=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../precision-recall-scores/PP_KR--WD_40717--CP_best.tsv','r')
	f2=open('../precision-recall-scores/PP_KR--AD_40718--CP_best.tsv','r')
	f3=open('../precision-recall-scores/PP_KR--NI_40716--CP_best.tsv','r')
	knowledge_Avg_Best_CPCC_PP=getavgList_pp_pr(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()





	f1=open('../sim-scores/KR--WD_40717--CP_InitialOntologies.tsv','r')
	f2=open('../sim-scores/KR--AD_40718--CP_InitialOntologies.tsv','r')
	f3=open('../sim-scores/KR--NI_40716--CP_InitialOntologies.tsv','r')
	knowledge_Avg_Initial_CPCC_SimJ,knowledge_Avg_Initial_CPCC_IC=getavgList(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../sim-scores/KR--WD_40717--CP_40717.tsv','r')
	f2=open('../sim-scores/KR--AD_40718--CP_40718.tsv','r')
	f3=open('../sim-scores/KR--NI_40716--CP_40716.tsv','r')
	knowledge_Avg_Aug_CPCC_SimJ,knowledge_Avg_Aug_CPCC_IC=getavgList(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()

	f1=open('../sim-scores/KR--WD_40717--CP_best.tsv','r')
	f2=open('../sim-scores/KR--AD_40718--CP_best.tsv','r')
	f3=open('../sim-scores/KR--NI_40716--CP_best.tsv','r')
	knowledge_Avg_Best_CPCC_SimJ,knowledge_Avg_Best_CPCC_IC=getavgList(f1,f2,f3)
	f1.close()
	f2.close()
	f3.close()
	



	#### Initial vs Aug
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Initial_CPCC_PR,y=knowledge_Avg_Aug_CPCC_PR)
	print "Knowledge Initial vs Aug PR p-value",p
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Initial_CPCC_PP,y=knowledge_Avg_Aug_CPCC_PP)
	print "Knowledge Initial vs Aug PP p-value",p
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Initial_CPCC_SimJ,y=knowledge_Avg_Aug_CPCC_SimJ)
	print "Knowledge Initial vs Aug SimJ p-value",p
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Initial_CPCC_IC,y=knowledge_Avg_Aug_CPCC_IC)
	print "Knowledge Initial vs Aug IC p-value",p


	


	#### Aug vs Merged
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Aug_CPCC_PR,y=knowledge_Avg_Best_CPCC_PR)
	print "Knowledge Aug vs Best PR p-value",p
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Aug_CPCC_PP,y=knowledge_Avg_Best_CPCC_PP)
	print "Knowledge Aug vs Best PP p-value",p
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Aug_CPCC_SimJ,y=knowledge_Avg_Best_CPCC_SimJ)
	print "Knowledge Aug vs Best SimJ p-value",p
	t,p=scipy.stats.wilcoxon(x=knowledge_Avg_Aug_CPCC_IC,y=knowledge_Avg_Best_CPCC_IC)
	print "Knowledge Aug vs Best IC p-value",p


if __name__ == "__main__":
	import sys
	import os
	import numpy as np
	import scipy.stats
	from os import listdir
	main()