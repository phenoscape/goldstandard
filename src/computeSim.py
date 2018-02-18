## computing character state level pairwise similarity. 
#inputs are two Classes-XXX files. 
def populateIC():
	# Computes IC for all classes and loads IC into a dictionary
	ic_dict={}
	ancestors_dict={}
	f=open("../data/AllAncestors_Combinations.txt")
	corpussize=0
	for line in f:
		corpussize=corpussize+1
		line=line.strip()
		if line in ancestors_dict:
			ancestors_dict[line]=ancestors_dict[line]+1
		else:
			ancestors_dict[line]=1
	p=float(1)/float(corpussize)
	maxic=-math.log(p,2)
	ic_dict["Maximum"]=maxic

	f.close()
	f=open("../data/AllAncestors_Combinations.txt")
	for line in f:
		freq=ancestors_dict[line.strip()]
		p=float(freq)/float(corpussize)
		ic=-math.log(p,2)
		ic_dict[line.strip()]=ic
	return ic_dict

def getIC(anc1,anc2,ic_dict):
	# given two ancestor sets and the IC dictionary, returns the  NIC
	common=set.intersection(anc1,anc2)
	maxIC=0
	t=""
	for term in common:
		ic=ic_dict[term.strip()]
		if ic > maxIC:
			maxIC=ic
			t=term	
	return (float(maxIC)/float(ic_dict['Maximum']))


def getancestors(line):
	# this will return a set of ancestors for a class
	global ancestor_dict
	line=line.strip()
	ancestors=ancestor_dict[line]
	return ancestors

def populateancestors(file):
	# load all ancestors of classes into a dictionary
	file=file.replace("Classes","Ancestors")	
	f = open(file,'r')
	global ancestor_dict
	for line in f:
		terms=line.split("\t")
		child=terms[0].strip()
		ancestor=terms[1].strip()
		if child in ancestor_dict:
			ancestor_dict[child].add(ancestor)
		else:
			ancestor_dict[child]=set()
			ancestor_dict[child].add(child)
			ancestor_dict[child].add(ancestor)

def main():
	ic_dict= populateIC()
	print "Populated IC"

	#GS to Curators - Naive round
	compute("../data/MappedAnnotations/NR--WD_38484.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/NR--AD_40674.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/NR--NI_40676.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)

	#GS to Curators - Knowledge round
	compute("../data/MappedAnnotations/KR--NI_40716.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/KR--WD_40717.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/KR--AD_40718.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)

	#GS to CharaParser - Naive round
	compute("../data/MappedAnnotations/Transformed_NR--CP_38484.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/Transformed_NR--CP_40674.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/Transformed_NR--CP_40676.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)

	#GS to CharaParser - Knowledge round
	compute("../data/MappedAnnotations/Transformed_KR--CP_40716.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/Transformed_KR--CP_40717.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)
	compute("../data/MappedAnnotations/Transformed_KR--CP_40718.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)

	# GS to CharaParser - Final Merged
	compute("../data/MappedAnnotations/Transformed_CP_best.tsv", "../data/MappedAnnotations/GS_Dataset.tsv", 1,ic_dict)



def compute(inputfile1,inputfile2,qualities,ic_dict):
	# takes as input an annotation file and the GS dataset and computes SimJ and NIC similarity between the two
	characterscoresIC = defaultdict(list)
	characterscoresSimJ = defaultdict(list)
	inputfile1="../data/Classes-"+inputfile1.replace("../data/MappedAnnotations/","")
	inputfile2="../data/Classes-"+inputfile2.replace("../data/MappedAnnotations/","")
	file1=open(inputfile1,'r')
	pereqscorefile="../data/CombinedComparisons/"+"PerEQ_"+inputfile1.replace(".tsv","").replace("../data/Classes-","")+ "--"+inputfile2.replace("NR--","").replace("Transformed_","").replace("KR--","").replace(".tsv","").replace("../data/Classes-","")+".tsv"
	if qualities==1:
		outputfile="../data/CombinedComparisons/"+inputfile1.replace(".tsv","").replace("../data/Classes-","")+ "--"+inputfile2.replace("NR--","").replace("Transformed_","").replace("KR--","").replace(".tsv","").replace("../data/Classes-","")+".tsv"
	else:
		outputfile="../data/CombinedComparisons/NoQualitites_"+inputfile1.replace(".tsv","").replace("../data/Classes-","")+ "--"+inputfile2.replace("NR--","").replace("Transformed_","").replace("KR--","").replace(".tsv","").replace("../data/Classes-","")+".tsv"
	


	pereq=open(pereqscorefile,'w')
	outputfile=outputfile.replace(".txt","")
	res=open(outputfile,'w')
	
	populateancestors(inputfile1)
	populateancestors(inputfile2)
	IClist=[]
	SimJlist=[]
	Linlist=[]
	line1count=1
	

	res.write("Character Number"+"\t"+"State Number"+"\t"+"SimJ Score" +"\t"+"NIC Score"+"\n")
	pereq.write("Character Number"+"\t"+"State Number"+"\t"+ "Curator 1 EQ Number"+"\t"+"Curator 2 EQ Number"+"\t"+ "SimJ Score"+"\t"+"NIC Score"+ "\n")
	for line1 in file1:
		file2=open(inputfile2,'r')
		line2count=1
		line1count=line1count+1
		for line2 in file2:
			
			
			line2count=line2count+1
			
			#format is character\tstate\tclassname
			# do the below only if the characters and the states are the same. 
			data1=line1.split("\t")
			data2=line2.split("\t")
			character1=data1[0].strip()
			state1=data1[1].strip()
			character2=data2[0].strip()
			state2=data2[1].strip()
			class1=data1[2].strip()
			class2=data2[2].strip()
			eqnumber1=data1[3].strip()
			eqnumber2=data2[3].strip()
			
			key=character1+"\t"+state1



			simj=0
			ic=0
			if character1 == character2 and state1 == state2:
				if class1.strip() !="" and class2.strip()!="":
					ancestors1=getancestors(class1) #this is a set
					ancestors2=getancestors(class2)
					ic=getIC(ancestors1,ancestors2,ic_dict)
					unionset=set.union(ancestors1,ancestors2)
					commonancestors= set.intersection(ancestors1,ancestors2)
	
					simj=float(len(commonancestors))/float(len(unionset))

				else:
					simj=0	
				pereq.write(str(character1)+"\t"+str(state1)+"\t"+eqnumber1+"\t"+eqnumber2+  "\t"+str(simj)+"\t"+str(ic)+"\n")
				characterscoresSimJ[key].append(simj)
				characterscoresIC[key].append(ic)

				
				
	#get the max values for each character-state comparison here and add to IClist and SimJ list			

	for characterstate in characterscoresSimJ:
		tmp=characterstate.split("\t")
		character=tmp[0]
		state=tmp[1]

		icmaxscore=max(characterscoresIC[characterstate])
		IClist.append(icmaxscore)

		simjmaxscore=max(characterscoresSimJ[characterstate])
		SimJlist.append(simjmaxscore)

		res.write(character+"\t"+state+"\t"+str(simjmaxscore)+"\t"+str(icmaxscore)+"\n")
		

	



	simjmean=str(round(numpy.mean(SimJlist),3))	
	simjmedian=str(round(numpy.median(SimJlist),3))
	normicmean=str(round(numpy.mean(IClist),3))
	normicmedian=str(round(numpy.median(IClist),3))

	print "\n\n"+outputfile.replace("CombinedComparisons","").replace(".//","").replace("Classes-","")
	print "\tMean SimJ",simjmean

	print "\tMean IC",normicmean
	
	
	outfile=outputfile.replace("CombinedComparisons","").replace(".//","").replace("Classes-","")






if __name__ == "__main__":
	from collections import defaultdict
	import numpy
	import sys
	import math
	import re
	ancestor_dict=dict()
	idmap_dict={}
	main()