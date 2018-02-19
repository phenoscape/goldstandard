

def loadPATOpermanent():
	id2name=dict()
	datafile=open("../data/PATO_Names.txt",'r')
	for line in datafile:
		id2name[line.split("\t")[1].strip()]=line.split("\t")[0].strip()
	datafile.close()
	return id2name

def loadPATOXref():
	mapping=dict()
	datafile=open("../data/PATOxref.txt",'r')
	for line in datafile:
		mapping[line.split("\t")[0].strip()]=line.split("\t")[1].strip()
	datafile.close()
	return mapping


def loadUBERONpermanent():
	datafile=open("../data/UberonXref.txt",'r')
	mapping=dict()
	for line in datafile:
		temp=line.split("\t")[1].strip()
		if "UBERONTEMP" not in temp:
			temp="UBERONTEMP"+temp
		mapping[temp]=line.split("\t")[0].strip()
		mapping[temp.replace(":","_")]=line.split("\t")[0].strip()
	return mapping

def loadinvalidterms():
	datafile=open("../data/InvalidUBERONTemp.txt")
	invalid=set()
	for line in datafile:
		invalid.add(line.strip())
	return invalid



def loadfurtheractionterms():
	datafile=open("../data/FurtherActionUberon.txt")
	furtheraction=set()
	for line in datafile:
		furtheraction.add(line.strip())
	return furtheraction

def getuberonterms(line):
	termset=set()
	data=line.split("\t")
	for x in data:
		parts=x.split()
		for part in parts:
			if "UBERONTEMP" in part:
				if ',' in part:
					part=part.split(",")[1]
				termset.add(part.replace(")",""))		
	return termset

def mapPATO(line,mapping,id2name):
	for tempterm in mapping:
		if tempterm in line:
			if mapping[tempterm] in id2name:
				line=line.replace(tempterm, id2name[mapping[tempterm]])
	return line

def mapUBERON(line,mapping):
	for tempterm in mapping:
		if tempterm in line:
			line=line.replace(tempterm,mapping[tempterm])
	return line
def main():
	mapping=loadUBERONpermanent()
	furtheraction=loadfurtheractionterms()
	unaccountedlist=set()

	patoid2name=loadPATOpermanent()
	patomapping=loadPATOXref()

	for filename in os.listdir("../data/Annotations/"):
		infile=open("../data/Annotations/"+filename,'r')
		outfile=open("../data/MappedAnnotations/"+filename,'w')
		for line in infile:
			uberonmappedline=mapUBERON(line,mapping)
			uberonpatomappedline=mapPATO(uberonmappedline,patomapping,patoid2name)
				
			outfile.write(uberonpatomappedline)
		infile.close()
		outfile.close()

	invalid=loadinvalidterms()
	for filename in os.listdir("../data/MappedAnnotations/"):
		infile=open("../data/MappedAnnotations/"+filename,'r')
		for line in infile:
			line=line.replace(":","_")
			if "UBERONTEMP" in line:
				invalidflag=0
				for invalidterm in invalid:
					if invalidterm in line:
						invalidflag=1
				if invalidflag==0:
					furtheractionflag=0
					for term in furtheraction:
						if term in line:
							furtheractionflag=1
					if furtheractionflag ==0:
						termlist=getuberonterms(line)
						for term in termlist:
							unaccountedlist.add(term)
		infile.close()
	for term in unaccountedlist:	
		print term







if __name__ == "__main__":
	import os
	main()