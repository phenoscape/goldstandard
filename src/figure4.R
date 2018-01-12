library(ggplot2)
library(reshape2)
library(Rmisc)
library(gridExtra)

savePlot <- function(myPlot,name) {
        png(name)
        print(myPlot)
        dev.off()
}

	IntC_N=c(0.524,0.511,0.548,0.802)
	IntC_N_Curators_PP=c(0.514,0.513,0.547)
	IntC_N_Curators_PR=c(0.499,0.508,0.526)
	IntC_N_Curators_Jsim=c(0.537,0.535,0.572)
	IntC_N_Curators_In=c(0.807,0.794,0.807)

	IntC_K=c(0.521,0.512,0.541,0.806)
	IntC_K_Curators_PP=c(0.531,0.489,0.543)
	IntC_K_Curators_PR=c(0.526,0.482,0.530)
	IntC_K_Curators_Jsim=c(0.554,0.506,0.565)
	IntC_K_Curators_In=c(0.818,0.792,0.809)

	SCP_Initial=c(0.160,0.231,0.249,0.561)
	SCP_Initial_Curators_PP=c(0.154,0.155,0.171)
	SCP_Initial_Curators_PR=c(0.214,0.228,0.250)
	SCP_Initial_Curators_Jsim=c(0.239,0.246,0.264)
	SCP_Initial_Curators_In=c(0.556,0.564,0.564)


	SCP_Aug=c(0.246,0.311,0.333,0.621)
	SCP_Aug_Curators_PP=c(0.266,0.21,0.264)
	SCP_Aug_Curators_PR=c(0.323,0.279,0.333)
	SCP_Aug_Curators_Jsim=c(0.35,0.3,0.349)
	SCP_Aug_Curators_In=c(0.631,0.613,0.620)

	SCP_Merged=c(0.210,0.346,0.368,0.657)
	SCP_Merged_Curators_PP=c(0.21,0.196,0.225)
	SCP_Merged_Curators_PR=c(0.343,0.323,0.373)
	SCP_Merged_Curators_Jsim=c(0.371,0.343,0.391)
	SCP_Merged_Curators_In=c(0.657,0.655,0.659)

 df <- data.frame(Ontology= c("Naive Inter-curator", "Knowledge Inter-curator", "SCP Initial", "SCP Augmented", "SCP Merged"),PP=c(IntC_N[1],IntC_K[1],SCP_Initial[1],SCP_Aug[1],SCP_Merged[1]),PR=c(IntC_N[1],IntC_K[2],SCP_Initial[2],SCP_Aug[2],SCP_Merged[2]),Jsim=c(IntC_N[3],IntC_K[3],SCP_Initial[3],SCP_Aug[3],SCP_Merged[3]),In=c(IntC_N[4],IntC_K[4],SCP_Initial[4],SCP_Aug[4],SCP_Merged[4]))


errorlist=c(2*(sd(IntC_N_Curators_PP)/sqrt(length(IntC_N_Curators_PP))),2*(sd(IntC_K_Curators_PP)/sqrt(length(IntC_K_Curators_PP))),2*(sd(SCP_Initial_Curators_PP)/sqrt(length(SCP_Initial_Curators_PP))),2*(sd(SCP_Aug_Curators_PP)/sqrt(length(SCP_Aug_Curators_PP))),2*(sd(SCP_Merged_Curators_PP)/sqrt(length(SCP_Merged_Curators_PP))),2*(sd(IntC_N_Curators_PR)/sqrt(length(IntC_N_Curators_PR))),2*(sd(IntC_K_Curators_PR)/sqrt(length(IntC_K_Curators_PR))),2*(sd(SCP_Initial_Curators_PR)/sqrt(length(SCP_Initial_Curators_PR))),2*(sd(SCP_Aug_Curators_PR)/sqrt(length(SCP_Aug_Curators_PR))),2*(sd(SCP_Merged_Curators_PR)/sqrt(length(SCP_Merged_Curators_PR))),3*(sd(IntC_N_Curators_Jsim)/sqrt(length(IntC_N_Curators_Jsim))),3*(sd(IntC_K_Curators_Jsim)/sqrt(length(IntC_K_Curators_Jsim))),3*(sd(SCP_Initial_Curators_Jsim)/sqrt(length(SCP_Initial_Curators_Jsim))),3*(sd(SCP_Aug_Curators_Jsim)/sqrt(length(SCP_Aug_Curators_Jsim))),3*(sd(SCP_Merged_Curators_Jsim)/sqrt(length(SCP_Merged_Curators_Jsim))),4*(sd(IntC_N_Curators_In)/sqrt(length(IntC_N_Curators_In))),4*(sd(IntC_K_Curators_In)/sqrt(length(IntC_K_Curators_In))),4*(sd(SCP_Initial_Curators_In)/sqrt(length(SCP_Initial_Curators_In))),4*(sd(SCP_Aug_Curators_In)/sqrt(length(SCP_Aug_Curators_In))),4*(sd(SCP_Merged_Curators_In)/sqrt(length(SCP_Merged_Curators_In))))

xlabels<-c(expression(italic(PP)),expression(italic(PR)),expression(italic(J)[sim]),expression(italic(I[n])))
print (xlabels)
df_melted <- melt(df, id.vars=c("Ontology"))
colnames(df_melted)[2] <- "SimilarityMetric"
dodge <- position_dodge(0.7)
ggplot(data = df_melted, aes(x = SimilarityMetric, y = value, group = Ontology, label = "")) + 
  geom_point(size=4, position = dodge,aes(shape=Ontology))+ylim(0,1)+xlab("")+xlab("Similarity Metric")+ylab("Similarity to Gold Standard")  + 
  geom_errorbar(width=0.2,aes(ymin=df_melted['value']-errorlist,ymax=df_melted['value']+errorlist), position = dodge)+
  geom_text(hjust = 2, position = dodge)+theme(legend.title = element_blank(),legend.position = c(.3, .95),
  legend.justification = c("right", "top"),
  legend.box.just = "right",
  legend.margin = margin(6, 6, 6, 6),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"),axis.text.x = element_text(face="italic"))+scale_x_discrete(labels=xlabels)

file.rename(from = file.path("./", "Rplots.pdf"), to = file.path("../results/", "SCP-OntCompleteness.pdf"))











