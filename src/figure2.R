library(ggplot2)
library(reshape2)
library(Rmisc)
library(gridExtra)
library(Hmisc)
    load_data<-function()
    {
        filename="../data/CombinedComparisons/PP_NR--WD_38484--combined_matrix-Gold_Standard.tsv"
    C1_pp_Naive_df = read.table(filename,header = TRUE,sep="\t")
    

    filename="../data/CombinedComparisons/PR_NR--WD_38484--combined_matrix-Gold_Standard.tsv"
    C1_pr_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PP_KR--WD_40717--combined_matrix-Gold_Standard.tsv"
    C1_pp_Knowledge_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PR_KR--WD_40717--combined_matrix-Gold_Standard.tsv"
    C1_pr_Knowledge_df = read.table(filename,header=TRUE,sep="\t")
    
    filename="../data/CombinedComparisons/NR--WD_38484--GS_Dataset.tsv"
    C1_Jsim_and_In_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/KR--WD_40717--GS_Dataset.tsv"
    C1_Jsim_and_In_Knowledge_df = read.table(filename,header=TRUE,sep="\t")
    

    filename="../data/CombinedComparisons/PP_NR--AD_40674--combined_matrix-Gold_Standard.tsv"
    C2_pp_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PR_NR--AD_40674--combined_matrix-Gold_Standard.tsv"
    C2_pr_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PP_KR--AD_40718--combined_matrix-Gold_Standard.tsv"
    C2_pp_Knowledge_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PR_KR--AD_40718--combined_matrix-Gold_Standard.tsv"
    C2_pr_Knowledge_df = read.table(filename,header=TRUE,sep="\t")

    filename="../data/CombinedComparisons/NR--AD_40674--GS_Dataset.tsv"
    C2_Jsim_and_In_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/KR--AD_40718--GS_Dataset.tsv"
    C2_Jsim_and_In_Knowledge_df = read.table(filename,header=TRUE,sep="\t")



    filename="../data/CombinedComparisons/PP_NR--NI_40676--combined_matrix-Gold_Standard.tsv"
    C3_pp_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PR_NR--NI_40676--combined_matrix-Gold_Standard.tsv"
    C3_pr_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PP_KR--NI_40716--combined_matrix-Gold_Standard.tsv"
    C3_pp_Knowledge_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/PR_KR--NI_40716--combined_matrix-Gold_Standard.tsv"
    C3_pr_Knowledge_df = read.table(filename,header=TRUE,sep="\t")

    filename="../data/CombinedComparisons/NR--NI_40676--GS_Dataset.tsv"
    C3_Jsim_and_In_Naive_df = read.table(filename,header=TRUE,sep="\t")
    filename="../data/CombinedComparisons/KR--NI_40716--GS_Dataset.tsv"
    C3_Jsim_and_In_Knowledge_df = read.table(filename,header=TRUE,sep="\t")



    newlist<-list(C1_pp_Naive_df['SimJ.Partial.Precision'],C1_pr_Naive_df['SimJ.Partial.Recall'],C1_pp_Knowledge_df['SimJ.Partial.Precision'],C1_pr_Knowledge_df['SimJ.Partial.Recall'],   C2_pp_Naive_df['SimJ.Partial.Precision'],C2_pr_Naive_df['SimJ.Partial.Recall'],C2_pp_Knowledge_df['SimJ.Partial.Precision'],C2_pr_Knowledge_df['SimJ.Partial.Recall'],  C3_pp_Naive_df['SimJ.Partial.Precision'],C3_pr_Naive_df['SimJ.Partial.Recall'],C3_pp_Knowledge_df['SimJ.Partial.Precision'],C3_pr_Knowledge_df['SimJ.Partial.Recall'],C1_Jsim_and_In_Naive_df['SimJ.Score'],C1_Jsim_and_In_Naive_df['NIC.Score'],C1_Jsim_and_In_Knowledge_df['SimJ.Score'],C1_Jsim_and_In_Knowledge_df['NIC.Score'],C2_Jsim_and_In_Naive_df['SimJ.Score'],C2_Jsim_and_In_Naive_df['NIC.Score'],C2_Jsim_and_In_Knowledge_df['SimJ.Score'],C2_Jsim_and_In_Knowledge_df['NIC.Score'],C3_Jsim_and_In_Naive_df['SimJ.Score'],C3_Jsim_and_In_Naive_df['NIC.Score'],C3_Jsim_and_In_Knowledge_df['SimJ.Score'],C3_Jsim_and_In_Knowledge_df['NIC.Score'])
    return (newlist)
}


savePlot <- function(myPlot,name) {
        png(name)
        print(myPlot)
        dev.off()
}


datalist=load_data()
C1_pp_Naive_df=data.frame(datalist[1])
C1_pp_Naive_df$curator<-"C1"
C1_pp_Naive_df$round<-"Naive"
C2_pp_Naive_df=data.frame(datalist[5])
C2_pp_Naive_df$curator<-"C2"
C2_pp_Naive_df$round<-"Naive"
C3_pp_Naive_df=data.frame(datalist[9])
C3_pp_Naive_df$curator<-"C3"
C3_pp_Naive_df$round<-"Naive"
C1_pp_Knowledge_df=data.frame(datalist[3])
C2_pp_Knowledge_df=data.frame(datalist[7])
C3_pp_Knowledge_df=data.frame(datalist[11])
C1_pp_Knowledge_df$curator<-"C1"
C1_pp_Knowledge_df$round<-"Knowledge"
C2_pp_Knowledge_df$curator<-"C2"
C2_pp_Knowledge_df$round<-"Knowledge"
C3_pp_Knowledge_df$curator<-"C3"
C3_pp_Knowledge_df$round<-"Knowledge"
pp_df<-rbind(C1_pp_Naive_df,C2_pp_Naive_df,C3_pp_Naive_df,C1_pp_Knowledge_df,C2_pp_Knowledge_df,C3_pp_Knowledge_df)
names(pp_df)<-c("Similarity","Curator","Round")
head(pp_df)
data_summary <- function(x) {
   m <- mean(x)
   se=2*(sd(x)/sqrt(length(x)))
   ymin <- m-se
   ymax <- m+se
   return(c(y=m,ymin=ymin,ymax=ymax))
}


pp <- ggplot(pp_df, aes(x=Curator, y=Similarity,fill=Round)) + 
  geom_violin(position=position_dodge(0.5),show.legend=FALSE)+stat_summary(fun.data=data_summary,geom="pointrange", show.legend=FALSE, color="black",position=position_dodge(0.5))+scale_fill_manual(values=c("#999999", "#FFFFFF"))+labs(fill="",y="Similarity to Gold Standard",x="")+ggtitle(expression(italic(PP)))+theme(plot.title = element_text(hjust = 0.5),panel.background = element_blank(), axis.line = element_line(colour = "black"))



C1_pr_Naive_df=data.frame(datalist[2])
C2_pr_Naive_df=data.frame(datalist[6])
C3_pr_Naive_df=data.frame(datalist[10])
C1_pr_Naive_df$curator<-"C1"
C1_pr_Naive_df$round<-"Naive"
C2_pr_Naive_df$curator<-"C2"
C2_pr_Naive_df$round<-"Naive"
C3_pr_Naive_df$curator<-"C3"
C3_pr_Naive_df$round<-"Naive"


C1_pr_Knowledge_df=data.frame(datalist[4])
C2_pr_Knowledge_df=data.frame(datalist[8])
C3_pr_Knowledge_df=data.frame(datalist[12])
C1_pr_Knowledge_df$curator<-"C1"
C1_pr_Knowledge_df$round<-"Knowledge"
C2_pr_Knowledge_df$curator<-"C2"
C2_pr_Knowledge_df$round<-"Knowledge"
C3_pr_Knowledge_df$curator<-"C3"
C3_pr_Knowledge_df$round<-"Knowledge"

pr_df<-rbind(C1_pr_Naive_df,C2_pr_Naive_df,C3_pr_Naive_df,C1_pr_Knowledge_df,C2_pr_Knowledge_df,C3_pr_Knowledge_df)
names(pr_df)<-c("Similarity","Curator","Round")

pr <- ggplot(pr_df, aes(x=Curator, y=Similarity,fill=Round)) + 
  geom_violin(position=position_dodge(0.5))+stat_summary(fun.data=data_summary,geom="pointrange", show.legend=FALSE, color="black",position=position_dodge(0.5))+scale_fill_manual(values=c("#999999", "#FFFFFF"))+labs(fill="",y="",x="")+ggtitle(expression(italic(PR)))+theme(plot.title = element_text(hjust = 0.5),panel.background = element_blank(), axis.line = element_line(colour = "black"))


C1_Jsim_Naive_df=data.frame(datalist[13])
C2_Jsim_Naive_df=data.frame(datalist[17])
C3_Jsim_Naive_df=data.frame(datalist[21])
C1_Jsim_Naive_df$curator<-"C1"
C1_Jsim_Naive_df$round<-"Naive"
C2_Jsim_Naive_df$curator<-"C2"
C2_Jsim_Naive_df$round<-"Naive"
C3_Jsim_Naive_df$curator<-"C3"
C3_Jsim_Naive_df$round<-"Naive"



C1_Jsim_Knowledge_df=data.frame(datalist[15])
C2_Jsim_Knowledge_df=data.frame(datalist[19])
C3_Jsim_Knowledge_df=data.frame(datalist[23])
C1_Jsim_Knowledge_df$curator<-"C1"
C1_Jsim_Knowledge_df$round<-"Knowledge"
C2_Jsim_Knowledge_df$curator<-"C2"
C2_Jsim_Knowledge_df$round<-"Knowledge"
C3_Jsim_Knowledge_df$curator<-"C3"
C3_Jsim_Knowledge_df$round<-"Knowledge"

Jsim_df<-rbind(C1_Jsim_Naive_df,C2_Jsim_Naive_df,C3_Jsim_Naive_df,C1_Jsim_Knowledge_df,C2_Jsim_Knowledge_df,C3_Jsim_Knowledge_df)
names(Jsim_df)<-c("Similarity","Curator","Round")
Jsim <- ggplot(Jsim_df, aes(x=Curator, y=Similarity,fill=Round)) + 
  geom_violin(position=position_dodge(0.5),show.legend=FALSE)+stat_summary(fun.data=data_summary,geom="pointrange", show.legend=FALSE, color="black",position=position_dodge(0.5))+scale_fill_manual(values=c("#999999", "#FFFFFF"))+labs(fill="",y="Similarity to Gold Standard")+ggtitle(expression(italic(J)[sim]))+theme(plot.title = element_text(hjust = 0.5),panel.background = element_blank(), axis.line = element_line(colour = "black"))


C1_In_Knowledge_df=data.frame(datalist[16])
C2_In_Knowledge_df=data.frame(datalist[20])
C3_In_Knowledge_df =data.frame(datalist[24])
C1_In_Knowledge_df$curator<-"C1"
C1_In_Knowledge_df$round<-"Knowledge"
C2_In_Knowledge_df$curator<-"C2"
C2_In_Knowledge_df$round<-"Knowledge"
C3_In_Knowledge_df$curator<-"C3"
C3_In_Knowledge_df$round<-"Knowledge"

C1_In_Naive_df=data.frame(datalist[14])
C2_In_Naive_df=data.frame(datalist[18])
C3_In_Naive_df=data.frame(datalist[22])
C1_In_Naive_df$curator<-"C1"
C1_In_Naive_df$round<-"Naive"
C2_In_Naive_df$curator<-"C2"
C2_In_Naive_df$round<-"Naive"
C3_In_Naive_df$curator<-"C3"
C3_In_Naive_df$round<-"Naive"

In_df<-rbind(C1_In_Naive_df,C2_In_Naive_df,C3_In_Naive_df,C1_In_Knowledge_df,C2_In_Knowledge_df,C3_In_Knowledge_df)
names(In_df)<-c("Similarity","Curator","Round")
In <- ggplot(In_df, aes(x=Curator, y=Similarity,fill=Round)) + 
  geom_violin(position=position_dodge(0.5),show.legend=FALSE)+stat_summary(fun.data=data_summary,geom="pointrange", show.legend=FALSE, color="black",position=position_dodge(0.5))+scale_fill_manual(values=c("#999999", "#FFFFFF"))+labs(fill="",y="")+ggtitle(expression(italic(I[n])))+theme(plot.title = element_text(hjust = 0.5),panel.background = element_blank(), axis.line = element_line(colour = "black"))

plot<-grid.arrange(pp, pr, Jsim, In, ncol = 2)
file.rename(from = file.path("./", "Rplots.pdf"), to = file.path("../results/", "CuratorsvsGS.pdf"))