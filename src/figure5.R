library(ggplot2)
library(reshape2)
library(Rmisc)
library(gridExtra)
options(scipen=999)

getmeanJsim <- function(filename1,filename2,filename3){
	
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["SimJ.Score"], na.rm = TRUE))
	
	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["SimJ.Score"], na.rm = TRUE))
	
	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["SimJ.Score"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}

getmeanNIC <- function(filename1,filename2,filename3){
	
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["NIC.Score"], na.rm = TRUE))
	
	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["NIC.Score"], na.rm = TRUE))
	
	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["NIC.Score"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}

getmeanPartialRecall <- function(filename1,filename2,filename3){
	
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["SimJ.Partial.Recall"], na.rm = TRUE))
	
	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["SimJ.Partial.Recall"], na.rm = TRUE))
	
	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["SimJ.Partial.Recall"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}

getmeanPartialPrecision <- function(filename1,filename2,filename3){
	
	df = read.table(filename1,header=TRUE,sep="\t")
 	mean1=(colMeans(df["SimJ.Partial.Precision"], na.rm = TRUE))
	
	df = read.table(filename2,header=TRUE,sep="\t")
 	mean2=(colMeans(df["SimJ.Partial.Precision"], na.rm = TRUE))
	
	df = read.table(filename3,header=TRUE,sep="\t")
 	mean3=(colMeans(df["SimJ.Partial.Precision"], na.rm = TRUE))
	return(c(mean1,mean2,mean3))
}


	filename1="../Intercurator-Consistency/precision-recall-scores/PP_NR--WD_38484--AD_40674.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PP_NR--AD_40674--NI_40676.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PP_NR--WD_38484--NI_40676.tsv"
	IntC_N_Curators_PP=getmeanPartialPrecision(filename1,filename2,filename3)


	filename1="../Intercurator-Consistency/precision-recall-scores/PR_NR--WD_38484--AD_40674.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PR_NR--AD_40674--NI_40676.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PR_NR--WD_38484--NI_40676.tsv"
	IntC_N_Curators_PR=getmeanPartialRecall(filename1,filename2,filename3)

	

	filename1="../Intercurator-Consistency/sim-scores/NR--WD_38484--AD_40674.tsv"
	filename2="../Intercurator-Consistency/sim-scores/NR--AD_40674--NI_40676.tsv"
	filename3="../Intercurator-Consistency/sim-scores/NR--WD_38484--NI_40676.tsv"
	IntC_N_Curators_Jsim=getmeanJsim(filename1,filename2,filename3)
	IntC_N_Curators_In=getmeanNIC(filename1,filename2,filename3)

	IntC_N=c(mean(IntC_N_Curators_PP),mean(IntC_N_Curators_PR),mean(IntC_N_Curators_Jsim),mean(IntC_N_Curators_In))


	
	filename1="../Intercurator-Consistency/precision-recall-scores/PP_KR--WD_40717--NI_40716.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PP_KR--WD_40717--AD_40718.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PP_KR--AD_40718--NI_40716.tsv"
	IntC_K_Curators_PP=getmeanPartialPrecision(filename1,filename2,filename3)


	filename1="../Intercurator-Consistency/precision-recall-scores/PR_KR--WD_40717--NI_40716.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PR_KR--WD_40717--AD_40718.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PR_KR--AD_40718--NI_40716.tsv"
	IntC_K_Curators_PR=getmeanPartialRecall(filename1,filename2,filename3)
	



	filename1="../Intercurator-Consistency/sim-scores/KR--WD_40717--AD_40718.tsv"
	filename2="../Intercurator-Consistency/sim-scores/KR--AD_40718--NI_40716.tsv"
	filename3="../Intercurator-Consistency/sim-scores/KR--WD_40717--NI_40716.tsv"
	IntC_K_Curators_Jsim=getmeanJsim(filename1,filename2,filename3)
	IntC_K_Curators_In=getmeanNIC(filename1,filename2,filename3)


	IntC_K=c(mean(IntC_K_Curators_PP),mean(IntC_K_Curators_PR),mean(IntC_K_Curators_Jsim),mean(IntC_K_Curators_In))






	filename1="../Intercurator-Consistency/precision-recall-scores/PP_KR--WD_40717--CP_InitialOntologies.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PP_KR--NI_40716--CP_InitialOntologies.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PP_KR--AD_40718--CP_InitialOntologies.tsv"
	SCP_Initial_Curators_PP=getmeanPartialPrecision(filename1,filename2,filename3)
	

	filename1="../Intercurator-Consistency/precision-recall-scores/PR_KR--WD_40717--CP_InitialOntologies.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PR_KR--NI_40716--CP_InitialOntologies.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PR_KR--AD_40718--CP_InitialOntologies.tsv"
	SCP_Initial_Curators_PR=getmeanPartialRecall(filename1,filename2,filename3)



	filename1="../Intercurator-Consistency/sim-scores/KR--WD_40717--CP_InitialOntologies.tsv"
	filename2="../Intercurator-Consistency/sim-scores/KR--AD_40718--CP_InitialOntologies.tsv"
	filename3="../Intercurator-Consistency/sim-scores/KR--NI_40716--CP_InitialOntologies.tsv"
	SCP_Initial_Curators_Jsim=getmeanJsim(filename1,filename2,filename3)
	SCP_Initial_Curators_In=getmeanNIC(filename1,filename2,filename3)
	SCP_Initial=c(mean(SCP_Initial_Curators_PP),mean(SCP_Initial_Curators_PR),mean(SCP_Initial_Curators_Jsim),mean(SCP_Initial_Curators_In))



	filename1="../Intercurator-Consistency/precision-recall-scores/PP_KR--NI_40716--CP_40716.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PP_KR--WD_40717--CP_40717.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PP_KR--AD_40718--CP_40718.tsv"
	SCP_Aug_Curators_PP=getmeanPartialPrecision(filename1,filename2,filename3)


	filename1="../Intercurator-Consistency/precision-recall-scores/PR_KR--NI_40716--CP_40716.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PR_KR--WD_40717--CP_40717.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PR_KR--AD_40718--CP_40718.tsv"
	SCP_Aug_Curators_PR=getmeanPartialRecall(filename1,filename2,filename3)
	

	filename1="../Intercurator-Consistency/sim-scores/KR--WD_40717--CP_40717.tsv"
	filename2="../Intercurator-Consistency/sim-scores/KR--NI_40716--CP_40716.tsv"
	filename3="../Intercurator-Consistency/sim-scores/KR--AD_40718--CP_40718.tsv"
	SCP_Aug_Curators_Jsim=getmeanJsim(filename1,filename2,filename3)
	SCP_Aug_Curators_In=getmeanNIC(filename1,filename2,filename3)
	SCP_Aug=c(mean(SCP_Aug_Curators_PP),mean(SCP_Aug_Curators_PR),mean(SCP_Aug_Curators_Jsim),mean(SCP_Aug_Curators_In))
	print("SCP_Aug PP PR")
	print(SCP_Aug)
	

	
	filename1="../Intercurator-Consistency/precision-recall-scores/PR_KR--WD_40717--CP_best.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PR_KR--NI_40716--CP_best.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PR_KR--AD_40718--CP_best.tsv"
	SCP_Merged_Curators_PR=getmeanPartialRecall(filename1,filename2,filename3)


	filename1="../Intercurator-Consistency/precision-recall-scores/PP_KR--WD_40717--CP_best.tsv"
	filename2="../Intercurator-Consistency/precision-recall-scores/PP_KR--NI_40716--CP_best.tsv"
	filename3="../Intercurator-Consistency/precision-recall-scores/PP_KR--AD_40718--CP_best.tsv"
	SCP_Merged_Curators_PP=getmeanPartialPrecision(filename1,filename2,filename3)
	


 
	filename1="../Intercurator-Consistency/sim-scores/KR--WD_40717--CP_best.tsv"
	filename2="../Intercurator-Consistency/sim-scores/KR--AD_40718--CP_best.tsv"
	filename3="../Intercurator-Consistency/sim-scores/KR--NI_40716--CP_best.tsv"
	SCP_Merged_Curators_Jsim=getmeanJsim(filename1,filename2,filename3)
	SCP_Merged_Curators_In=getmeanNIC(filename1,filename2,filename3)
	SCP_Merged=c(mean(SCP_Merged_Curators_PP),mean(SCP_Merged_Curators_PR),mean(SCP_Merged_Curators_Jsim),mean(SCP_Merged_Curators_In))
	print ("SCP_Merged")
	print (SCP_Merged)

 df <- data.frame(Ontology= c("Naive Inter-curator", "Knowledge Inter-curator", "SCP Initial", "SCP Augmented", "SCP Merged"),PP=c(IntC_N[1],IntC_K[1],SCP_Initial[1],SCP_Aug[1],SCP_Merged[1]),PR=c(IntC_N[1],IntC_K[2],SCP_Initial[2],SCP_Aug[2],SCP_Merged[2]),Jsim=c(IntC_N[3],IntC_K[3],SCP_Initial[3],SCP_Aug[3],SCP_Merged[3]),In=c(IntC_N[4],IntC_K[4],SCP_Initial[4],SCP_Aug[4],SCP_Merged[4]))


errorlist=c(2*(sd(IntC_N_Curators_PP)/sqrt(length(IntC_N_Curators_PP))),2*(sd(IntC_K_Curators_PP)/sqrt(length(IntC_K_Curators_PP))),2*(sd(SCP_Initial_Curators_PP)/sqrt(length(SCP_Initial_Curators_PP))),2*(sd(SCP_Aug_Curators_PP)/sqrt(length(SCP_Aug_Curators_PP))),2*(sd(SCP_Merged_Curators_PP)/sqrt(length(SCP_Merged_Curators_PP))),2*(sd(IntC_N_Curators_PR)/sqrt(length(IntC_N_Curators_PR))),2*(sd(IntC_K_Curators_PR)/sqrt(length(IntC_K_Curators_PR))),2*(sd(SCP_Initial_Curators_PR)/sqrt(length(SCP_Initial_Curators_PR))),2*(sd(SCP_Aug_Curators_PR)/sqrt(length(SCP_Aug_Curators_PR))),2*(sd(SCP_Merged_Curators_PR)/sqrt(length(SCP_Merged_Curators_PR))),3*(sd(IntC_N_Curators_Jsim)/sqrt(length(IntC_N_Curators_Jsim))),3*(sd(IntC_K_Curators_Jsim)/sqrt(length(IntC_K_Curators_Jsim))),3*(sd(SCP_Initial_Curators_Jsim)/sqrt(length(SCP_Initial_Curators_Jsim))),3*(sd(SCP_Aug_Curators_Jsim)/sqrt(length(SCP_Aug_Curators_Jsim))),3*(sd(SCP_Merged_Curators_Jsim)/sqrt(length(SCP_Merged_Curators_Jsim))),4*(sd(IntC_N_Curators_In)/sqrt(length(IntC_N_Curators_In))),4*(sd(IntC_K_Curators_In)/sqrt(length(IntC_K_Curators_In))),4*(sd(SCP_Initial_Curators_In)/sqrt(length(SCP_Initial_Curators_In))),4*(sd(SCP_Aug_Curators_In)/sqrt(length(SCP_Aug_Curators_In))),4*(sd(SCP_Merged_Curators_In)/sqrt(length(SCP_Merged_Curators_In))))

xlabels<-c(expression(italic(PP)),expression(italic(PR)),expression(italic(J)[sim]),expression(italic(I[n])))
df_melted <- melt(df, id.vars=c("Ontology"))
colnames(df_melted)[2] <- "SimilarityMetric"
dodge <- position_dodge(0.7)
ggplot(data = df_melted, aes(x = SimilarityMetric, y = value, group = Ontology, label = "")) + 
  geom_point(size=4, position = dodge,aes(shape=Ontology))+ylim(0,1)+xlab("")+xlab("Similarity Metric")+ylab("Similarity Score")  + 
  geom_errorbar(width=0.2,aes(ymin=df_melted['value']-errorlist,ymax=df_melted['value']+errorlist), position = dodge)+
  geom_text(hjust = 2, position = dodge)+theme(legend.title = element_blank(),legend.position = c(.3, .95),
  legend.justification = c("right", "top"),
  legend.box.just = "right",
  legend.margin = margin(6, 6, 6, 6),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.text.x = element_text(face="italic"))+scale_x_discrete(labels=xlabels)

file.rename(from = file.path("./", "Rplots.pdf"), to = file.path("../results/", "SCP-OntCompleteness.pdf"))











