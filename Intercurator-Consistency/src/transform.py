idmapreplace_dict={}

def populatemapping():
	global idmapreplace_dict
	inp=open('../data/id_mapping.txt','r')
	for line in inp:
		temp=line.split("\t")
		idmapreplace_dict[temp[1].strip()]=temp[0].strip()


#Character	Character Label	State Symbol	State Label	Entity ID	Entity Label	Quality ID	Quality Label	Related Entity ID	Related Entity Label	
 		

import sys
inputfile1=str(sys.argv[1])
inp=open(inputfile1,'r')
outfile="Transformed_"+inputfile1
out=open(outfile,'w')


populatemapping()
characterstatepresent=[]
allcharacterstate=[]
chstate=open("../data/CharacterStateList.tsv",'r')
for line in chstate:
	character=line.split("\t")[0].strip()
	state=line.split("\t")[1].strip()
	if (character,state) not in allcharacterstate:
		allcharacterstate.append((character,state))

for line in inp:
	if "Character" not in line:
		line=line.replace(":","_")
		terms=line.split("\t")
		e1= terms[3].strip()
		q1 = terms[4].strip()
		e2=terms[5].strip()
		characterid=terms[1].strip()
		stateid=terms[2].strip()
		character=idmapreplace_dict[characterid].strip()
		state=idmapreplace_dict[stateid].strip()
		state=state.split("_")[1]
		en1=e1.split("@,")
		qu1=q1.split("@,")
		en2=e2.split("@,")
		m=max(len(en1),len(qu1),len(en2))
		for i in range (0,m):
			
			E1=""
			Q1=""
			E2=""
			if len(en1) > i:
				E1=en1[i].split("Score")[0]
			if len(qu1) > i:	
				Q1=qu1[i].split("Score")[0]
			if len(en2) > i:	
				E2=en2[i].split("Score")[0]
			if E1.strip()=="null":
				E1=""
			if E2.strip()=="null":
				E2=""
			if Q1.strip()=="null":
				Q1=""								
			
			if (character,state) not in characterstatepresent:
				characterstatepresent.append((character,state))
			out.write(character+"\t"+""+"\t"+state+"\t"+""+"\t"+E1+"\t"+""+"\t"+Q1+"\t"+""+"\t"+E2+"\t"+""+"\n")
for tup in allcharacterstate:
	if tup not in characterstatepresent:
		character=tup[0]
		state=tup[1]
		out.write(character+"\t"+""+"\t"+state+"\t"+""+"\t"+" "+"\t"+""+"\t"+" "+"\t"+""+"\t"+" "+"\t"+""+"\n")










