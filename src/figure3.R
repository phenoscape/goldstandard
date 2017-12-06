library(ggplot2)
library(reshape2)
library(Rmisc)
library(gridExtra)

savePlot <- function(myPlot,name) {
        png(name)
        print(myPlot)
        dev.off()
}


PP_C1Aug=c(0.186 ,0.203)
	PP_C2Aug=c(0.136,0.145)
	PP_C3Aug=c(0.162,0.18)
	PR_C1Aug=c(0.227 ,0.243)
	PR_C2Aug=c(0.173, 0.183)
	PR_C3Aug=c(0.202,0.22)
	Jsim_C1Aug=c(0.249, 0.266)
	Jsim_C2Aug=c(0.194,0.206)
	Jsim_C3Aug=c(0.225,0.243)
	I_C1Aug=c(0.389,0.401)
	I_C2Aug=c(0.32,0.34)
	I_C3Aug=c(0.352,0.377)
	PP_Merged=c(0.155,0.155)
	PR_Merged=c(0.251,0.251)
	Jsim_Merged=c(0.276,0.276)
	I_Merged=c(0.429,0.429)


	PP_Aug_N_Curators=c(PP_C1Aug[1],PP_C2Aug[1],PP_C2Aug[1])
	PP_Aug_K_Curators=c(PP_C1Aug[2],PP_C2Aug[2],PP_C2Aug[2])
	PR_Aug_N_Curators=c(PR_C1Aug[1],PR_C2Aug[1],PR_C2Aug[1])
	PR_Aug_K_Curators=c(PR_C1Aug[2],PR_C2Aug[2],PR_C2Aug[2])
	Jsim_Aug_N_Curators=c(Jsim_C1Aug[1],Jsim_C2Aug[1],Jsim_C2Aug[1])
	Jsim_Aug_K_Curators=c(Jsim_C1Aug[2],Jsim_C2Aug[2],Jsim_C2Aug[2])
	I_Aug_N_Curators=c(I_C1Aug[1],I_C2Aug[1],I_C2Aug[1])
	I_Aug_K_Curators=c(I_C1Aug[2],I_C2Aug[2],I_C2Aug[2])


	PP_Aug=c(mean(PP_Aug_N_Curators),mean(PP_Aug_K_Curators))
	PR_Aug=c(mean(PR_Aug_N_Curators),  mean(PR_Aug_K_Curators))
	Jsim_Aug=c(mean(Jsim_Aug_N_Curators),  mean(Jsim_Aug_K_Curators))
	I_Aug=c(mean(I_Aug_N_Curators),  mean(I_Aug_K_Curators))

	x=c(1,2)
	rounds = c('Naive','Knowledge')


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
panel.background = element_blank(), axis.line = element_line(colour = "black"))+ggtitle("Jsim")





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
panel.background = element_blank(), axis.line = element_line(colour = "black"))+ggtitle("In")



plot<-grid.arrange(p1, p2, p3, p4, ncol = 2)
savePlot(plot,"../results/Figure2.png")





