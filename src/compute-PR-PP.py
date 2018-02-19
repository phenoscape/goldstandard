def load_pereqscores(filename):
	infile=open(filename)
	infile.next()
	gs=dict()
	cp=dict()
	for line in infile:
		chno,stateno,cpeqno,gseqno,simj,nic=line.split("\t")
		if chno not in gs:
			gs[chno]=dict()
		if stateno not in gs[chno]:
			gs[chno][stateno]=dict()
		if 'simj' not in gs[chno][stateno]:
			gs[chno][stateno]['simj']=dict()

		if gseqno not in gs[chno][stateno]['simj']:
			gs[chno][stateno]['simj'][gseqno]=dict()
		
		if cpeqno not in gs[chno][stateno]['simj'][gseqno]:
			gs[chno][stateno]['simj'][gseqno][cpeqno]=float(simj)

		if chno not in cp:
			cp[chno]=dict()
		if stateno not in cp[chno]:
			cp[chno][stateno]=dict()
		if 'simj' not in cp[chno][stateno]:
			cp[chno][stateno]['simj']=dict()
		if cpeqno not in cp[chno][stateno]['simj']:
			cp[chno][stateno]['simj'][cpeqno]=dict()
		
		if gseqno not in cp[chno][stateno]['simj'][cpeqno]:
			cp[chno][stateno]['simj'][cpeqno][gseqno]=float(simj)
	
	infile.close()
	return gs,cp

def compute_partial_precision(cp):
	pp=dict()
	simjprecisionlist=[]
	for chno in cp:
		pp[chno]=dict()
		for stateno in cp[chno]:
			pp[chno][stateno]=dict()
			precision=0
			maxscores=[]
			for cpeqno in cp[chno][stateno]['simj']:
				maxscores.append(max(cp[chno][stateno]['simj'][cpeqno].iteritems(), key=operator.itemgetter(1))[1])
			precision=np.sum(maxscores)/len(maxscores)
			pp[chno][stateno]['simj']=precision
			simjprecisionlist.append(precision)


	return pp,np.mean(simjprecisionlist)
	

def compute_partial_recall(gs):
	pr=dict()
	simjrecalllist=[]
	for chno in gs:
		pr[chno]=dict()
		for stateno in gs[chno]:
			pr[chno][stateno]=dict()
			
			recall=0
			maxscores=[]
			for gseqno in gs[chno][stateno]['simj']:
				maxscores.append(max(gs[chno][stateno]['simj'][gseqno].iteritems(), key=operator.itemgetter(1))[1])
			recall=np.sum(maxscores)/len(maxscores)
			pr[chno][stateno]['simj']=recall
			simjrecalllist.append(recall)

	return pr,np.mean(simjrecalllist)

def compute(infile):
	# compute PP and PR for each comparison
	ppoutfile=infile.replace("PerEQ","PP")
	proutfile=infile.replace("PerEQ","PR")
	C_A,C_B=load_pereqscores(infile)
	
	pp,simjmeanpp=compute_partial_precision(C_A)
	pr,simjmeanpr=compute_partial_recall(C_B)


	outfile=open(ppoutfile,'w')
	outfile.write("Character Number\tState Number\tSimJ Partial Precision\n")
	for characterno in pp:
		for stateno in pp[characterno]:
			outfile.write(characterno+"\t"+stateno+"\t"+str(pp[characterno][stateno]['simj'])+"\n")
	outfile.close()

	outfile=open(proutfile,'w')
	outfile.write("Character Number\tState Number\tSimJ Partial Recall\n")
	for characterno in pr:
		for stateno in pr[characterno]:
			outfile.write(characterno+"\t"+stateno+"\t"+str(pr[characterno][stateno]['simj'])+"\n")
	outfile.close()
	return simjmeanpp,simjmeanpr


def CP_GS():
	# PP and PR similarity between CP and GS using C1 Aug ontology
	infile="../data/CombinedComparisons/PerEQ_Transformed_NR--CP_38484--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP C1 Naive Aug-GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	infile="../data/CombinedComparisons/PerEQ_Transformed_KR--CP_40717--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP C1 Knowledge Aug-GS Knowledge PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	


	# PP and PR similarity between CP and GS using C2 Aug ontology
	infile="../data/CombinedComparisons/PerEQ_Transformed_NR--CP_40674--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP C2 Naive Aug-GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	infile="../data/CombinedComparisons/PerEQ_Transformed_KR--CP_40718--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP C2 Naive Aug-GS Knowledge PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	

	
	# PP and PR similarity between CP and GS using C3 Aug ontology
	infile="../data/CombinedComparisons/PerEQ_Transformed_NR--CP_40676--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP C3 Naive Aug-GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	infile="../data/CombinedComparisons/PerEQ_Transformed_KR--CP_40716--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP C3 Knowledge Aug-GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	

	# PP and PR similarity between CP and GS using CP best ontology
	infile="../data/CombinedComparisons/PerEQ_Transformed_CP_best--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "CP Best - GS PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	
	
def C1_GS():
	# PP and PR similarity between C1 and GS
	infile="../data/CombinedComparisons/PerEQ_NR--WD_38484--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "C1 GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	
	infile="../data/CombinedComparisons/PerEQ_KR--WD_40717--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "C1 GS Knowledge PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	


def C2_GS():
	# PP and PR similarity between C2 and GS
	infile="../data/CombinedComparisons/PerEQ_NR--AD_40674--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "C2 GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	
	infile="../data/CombinedComparisons/PerEQ_KR--AD_40718--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "C2 GS Knowledge PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	


def C3_GS():
	# PP and PR similarity between C3 and GS
	infile="../data/CombinedComparisons/PerEQ_NR--NI_40676--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "C3 GS Naive PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	
	infile="../data/CombinedComparisons/PerEQ_KR--NI_40716--GS_Dataset.tsv"
	simjmeanpp,simjmeanpr=compute(infile)
	print "C3 GS Knowledge PP --- PR", np.round(simjmeanpp,3),np.round(simjmeanpr,3)
	


def main():
	CP_GS()
	C1_GS()
	C2_GS()
	C3_GS()
	
if __name__ == "__main__":
	import operator
	from collections import defaultdict
	import numpy as np
	import sys
	main()
