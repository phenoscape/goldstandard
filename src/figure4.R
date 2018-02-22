library(ggplot2)
library(reshape2)
library(Rmisc)
library(gridExtra)
options(scipen=999)


getmeanJsim <- function(filename1,filename2,filename3){
	# takes three curator comparison files and returns mean Jsim from each file
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["SimJ.Score"], na.rm = TRUE))
	
	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["SimJ.Score"], na.rm = TRUE))
	
	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["SimJ.Score"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}

getmeanNIC <- function(filename1,filename2,filename3){
	# takes three curator comparison files and returns mean NIC from each file
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["NIC.Score"], na.rm = TRUE))
	
	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["NIC.Score"], na.rm = TRUE))
	
	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["NIC.Score"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}

getmeanPartialRecall <- function(filename1,filename2,filename3){
	# takes three curator comparison files and returns mean PR from each file
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["SimJ.Partial.Recall"], na.rm = TRUE))

 	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["SimJ.Partial.Recall"], na.rm = TRUE))

 	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["SimJ.Partial.Recall"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}

getmeanPartialPrecision <- function(filename1,filename2,filename3){
	# takes three curator comparison files and returns mean PP from each file
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["SimJ.Partial.Precision"], na.rm = TRUE))

 	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["SimJ.Partial.Precision"], na.rm = TRUE))

 	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["SimJ.Partial.Precision"], na.rm = TRUE))


	return(c(mean1,mean2,mean3))
}
	
	
	# get mean PP for CP - GS in Naive round
	filename1="../data/CombinedComparisons/PP_Transformed_NR--CP_38484--GS_Dataset.tsv"
	filename2="../data/CombinedComparisons/PP_Transformed_NR--CP_40674--GS_Dataset.tsv"
	filename3="../data/CombinedComparisons/PP_Transformed_NR--CP_40676--GS_Dataset.tsv"
	N_meanPP=getmeanPartialPrecision(filename1,filename2,filename3)
	
	# get mean PP for CP - GS in Knowledge round
	filename3="../data/CombinedComparisons/PP_Transformed_KR--CP_40716--GS_Dataset.tsv"
	filename1="../data/CombinedComparisons/PP_Transformed_KR--CP_40717--GS_Dataset.tsv"
	filename2="../data/CombinedComparisons/PP_Transformed_KR--CP_40718--GS_Dataset.tsv"
	K_meanPP=getmeanPartialPrecision(filename1,filename2,filename3)

	# get mean PP for CP Best - GS
	infile="../data/CombinedComparisons/PP_Transformed_CP_best--GS_Dataset.tsv"
	bestmeanpp=getmeanPartialPrecision(infile,infile,infile)
	
	# get mean PR for CP - GS in Naive round
	filename3="../data/CombinedComparisons/PR_Transformed_NR--CP_40676--GS_Dataset.tsv"
	filename1="../data/CombinedComparisons/PR_Transformed_NR--CP_38484--GS_Dataset.tsv"
	filename2="../data/CombinedComparisons/PR_Transformed_NR--CP_40674--GS_Dataset.tsv"
	N_meanPR=getmeanPartialRecall(filename1,filename2,filename3)

	# get mean PR for CP - GS in Knowledge round
	filename3="../data/CombinedComparisons/PR_Transformed_KR--CP_40716--GS_Dataset.tsv"
	filename1="../data/CombinedComparisons/PR_Transformed_KR--CP_40717--GS_Dataset.tsv"
	filename2="../data/CombinedComparisons/PR_Transformed_KR--CP_40718--GS_Dataset.tsv"
	K_meanPR=getmeanPartialRecall(filename1,filename2,filename3)
	
	# get mean PR for CP Best - GS
	infile="../data/CombinedComparisons/PR_Transformed_CP_best--GS_Dataset.tsv"
	bestmeanpr=getmeanPartialRecall(infile,infile,infile)

	# get mean Jsim and NIC for CP - GS in Naive round
	filename1="../data/CombinedComparisons/Transformed_NR--CP_38484--GS_Dataset.tsv"
	filename2="../data/CombinedComparisons/Transformed_NR--CP_40674--GS_Dataset.tsv"
	filename3="../data/CombinedComparisons/Transformed_NR--CP_40676--GS_Dataset.tsv"
	N_augmeanJsim=getmeanJsim(filename1,filename2,filename3)
	N_augmeanNIC=getmeanNIC(filename1,filename2,filename3)

	# get mean Jsim and NIC for CP - GS in Knowledge round
	filename1="../data/CombinedComparisons/Transformed_KR--CP_40717--GS_Dataset.tsv"
	filename2="../data/CombinedComparisons/Transformed_KR--CP_40718--GS_Dataset.tsv"
	filename3="../data/CombinedComparisons/Transformed_KR--CP_40716--GS_Dataset.tsv"
	K_augmeanJsim=getmeanJsim(filename1,filename2,filename3)
	K_augmeanNIC=getmeanNIC(filename1,filename2,filename3)

	# get mean Jsim and NIC for CP Best - GS
	infile="../data/CombinedComparisons/Transformed_CP_best--GS_Dataset.tsv"
	bestmeanjsim=getmeanJsim(infile,infile,infile)
	bestmeannic=getmeanNIC(infile,infile,infile)
 

	# getting PP series (Naive, Knowledge) using Aug ontologies
	PP_C1Aug=c(N_meanPP[1],K_meanPP[1])
	PP_C2Aug=c(N_meanPP[2],K_meanPP[2])
	PP_C3Aug=c(N_meanPP[3],K_meanPP[3])

	# getting PR series (Naive, Knowledge) using Aug ontologies
	PR_C1Aug=c(N_meanPR[1],K_meanPR[1])
	PR_C2Aug=c(N_meanPR[2],K_meanPR[2])
	PR_C3Aug=c(N_meanPR[3],K_meanPR[3])

	# getting Jsim series (Naive, Knowledge) using Aug ontologies
	Jsim_C1Aug=c(N_augmeanJsim[1],K_augmeanJsim[1])
	Jsim_C2Aug=c(N_augmeanJsim[2],K_augmeanJsim[2])
	Jsim_C3Aug=c(N_augmeanJsim[3],K_augmeanJsim[3])

	# getting NIC series (Naive, Knowledge) using Aug ontologies
	I_C1Aug=c(N_augmeanNIC[1],K_augmeanNIC[1])
	I_C2Aug=c(N_augmeanNIC[2],K_augmeanNIC[2])
	I_C3Aug=c(N_augmeanNIC[3],K_augmeanNIC[3])

	# getting PP, PR, Jsim, NIC series (Naive, Knowledge) using Best ontologies
	PP_Merged=c(bestmeanpp[1],bestmeanpp[1])
	PR_Merged=c(bestmeanpr[1],bestmeanpr[1])
	Jsim_Merged=c(bestmeanjsim[1],bestmeanjsim[1])
	I_Merged=c(bestmeannic[1],bestmeannic[1])


	# getting distribution of PP/PR/Jsim/NIC using Aug ontologies in Naive/Knowledge round for three curators
	PP_Aug_N_Curators=c(PP_C1Aug[1],PP_C2Aug[1],PP_C3Aug[1])
	PP_Aug_K_Curators=c(PP_C1Aug[2],PP_C2Aug[2],PP_C3Aug[2])
	PR_Aug_N_Curators=c(PR_C1Aug[1],PR_C2Aug[1],PR_C3Aug[1])
	PR_Aug_K_Curators=c(PR_C1Aug[2],PR_C2Aug[2],PR_C3Aug[2])
	Jsim_Aug_N_Curators=c(Jsim_C1Aug[1],Jsim_C2Aug[1],Jsim_C3Aug[1])
	Jsim_Aug_K_Curators=c(Jsim_C1Aug[2],Jsim_C2Aug[2],Jsim_C3Aug[2])
	I_Aug_N_Curators=c(I_C1Aug[1],I_C2Aug[1],I_C3Aug[1])
	I_Aug_K_Curators=c(I_C1Aug[2],I_C2Aug[2],I_C3Aug[2])
	PP_Aug=c(mean(PP_Aug_N_Curators),mean(PP_Aug_K_Curators))
	PR_Aug=c(mean(PR_Aug_N_Curators),  mean(PR_Aug_K_Curators))
	Jsim_Aug=c(mean(Jsim_Aug_N_Curators),  mean(Jsim_Aug_K_Curators))
	I_Aug=c(mean(I_Aug_N_Curators),  mean(I_Aug_K_Curators))

	x=c(1,2)
	rounds = c('Naive','Knowledge')

# plotting PP series for Aug and Merged ontologies
PPdf <- data.frame(Ontology= c("Mean Augmented", "Merged"),
                 Naive=c(PP_Aug[1],PP_Merged[1]), 
                 Knowledge=c(PP_Aug[2],PP_Merged[2]))

PPdf_melted <- melt(PPdf, id.vars=c("Ontology"))
colnames(PPdf_melted)[2] <- "CurationRound"
errorlist=c(2*(sd(PP_Aug_N_Curators)/sqrt(length(PP_Aug_N_Curators))),0,2*(sd(PP_Aug_K_Curators)/sqrt(length(PP_Aug_K_Curators))),0)
dodge <- position_dodge(.5)
p1<-ggplot(data = PPdf_melted, aes(x = CurationRound, y = value, group = Ontology, label = "")) + 
  geom_point(size=4, position = dodge,aes(shape=Ontology))+ylim(0,1)+xlab("")+ylab("Similarity to Gold Standard") + 
  geom_errorbar(width=0.2,aes(ymin=PPdf_melted['value']-errorlist,ymax=PPdf_melted['value']+errorlist), position = dodge) + 
  geom_text(hjust = 2, position = dodge)+theme(legend.position="none",plot.title = element_text(hjust = 0.5,face='italic'),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"))+ggtitle("PP")



# plotting PR series for Aug and Merged ontologies
PRdf <- data.frame(Ontology= c("Mean Augmented", "Merged"),
                 Naive=c(PR_Aug[1],PR_Merged[1]), 
                 Knowledge=c(PR_Aug[2],PR_Merged[2]))
PRdf_melted <- melt(PRdf, id.vars=c("Ontology"))
colnames(PRdf_melted)[2] <- "CurationRound"
errorlist=c(2*(sd(PR_Aug_N_Curators)/sqrt(length(PR_Aug_N_Curators))),0,2*(sd(PR_Aug_K_Curators)/sqrt(length(PR_Aug_K_Curators))),0)
p2<-ggplot(data = PRdf_melted, aes(x = CurationRound, y = value, group = Ontology, label = "")) + 
  geom_point(size=4, position = dodge,aes(shape=Ontology))+ylim(0,1)+xlab("")+ylab("") + 
  geom_errorbar(width=0.2,aes(ymin=PRdf_melted['value']-errorlist,ymax=PRdf_melted['value']+errorlist), position = dodge) + 
  geom_text(hjust = 2, position = dodge)+theme(legend.title = element_blank(),legend.position = c(.95, .95),
  legend.justification = c("right", "top"),
  legend.box.just = "right",
  legend.margin = margin(6, 6, 6, 6),plot.title = element_text(hjust = 0.5,face='italic'),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"))+ggtitle("PR")




# plotting Jsim series for Aug and Merged ontologies
jsimdf <- data.frame(Ontology= c("Mean Augmented", "Merged"),
                 Naive=c(Jsim_Aug[1],Jsim_Merged[1]), 
                 Knowledge=c(Jsim_Aug[2],Jsim_Merged[2]))
jsimdf_melted <- melt(jsimdf, id.vars=c("Ontology"))
colnames(jsimdf_melted)[2] <- "CurationRound"
errorlist=c(2*(sd(Jsim_Aug_N_Curators)/sqrt(length(Jsim_Aug_N_Curators))),0,2*(sd(Jsim_Aug_K_Curators)/sqrt(length(Jsim_Aug_K_Curators))),0)
p3<-ggplot(data = jsimdf_melted, aes(x = CurationRound, y = value, group = Ontology, label = "")) + 
  geom_point(size=4, position = dodge,aes(shape=Ontology))+ylim(0,1)+xlab("Curation Round")+ylab("Similarity to Gold Standard") + 
  geom_errorbar(width=0.2,aes(ymin=jsimdf_melted['value']-errorlist,ymax=jsimdf_melted['value']+errorlist), position = dodge) + 
  geom_text(hjust = 2, position = dodge)+theme(legend.position="none",plot.title = element_text(hjust = 0.5,face='italic'),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(expression(J[sim]))




# plotting In series for Aug and Merged ontologies
Indf <- data.frame(Ontology= c("Mean Augmented", "Merged"),
                 Naive=c(I_Aug[1],I_Merged[1]), 
                 Knowledge=c(I_Aug[2],I_Merged[2]))
Indf_melted <- melt(Indf, id.vars=c("Ontology"))
colnames(Indf_melted)[2] <- "CurationRound"
errorlist=c(2*(sd(I_Aug_N_Curators)/sqrt(length(I_Aug_N_Curators))),0,2*(sd(I_Aug_K_Curators)/sqrt(length(I_Aug_K_Curators))),0)
p4<-ggplot(data = Indf_melted, aes(x = CurationRound, y = value, group = Ontology, label = "")) + 
  geom_point(size=4, position = dodge,aes(shape=Ontology))+ylim(0,1)+xlab("Curation Round")+ylab("") + 
  geom_errorbar(width=0.2,aes(ymin=Indf_melted['value']-errorlist,ymax=Indf_melted['value']+errorlist), position = dodge) + 
  geom_text(hjust = 2, position = dodge)+theme(legend.position="none",plot.title = element_text(hjust = 0.5,face='italic'),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"))+ggtitle(expression(I[n]))



plot<-grid.arrange(p1, p2, p3, p4, ncol = 2)
file.rename(from = file.path("./", "Rplots.pdf"), to = file.path("../results/", "GS-OntCompleteness.pdf"))





