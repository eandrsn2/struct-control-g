#########################
#Load necessary packages#
#########################
library(psych)
library(plyr)
library(dplyr)
library(PerformanceAnalytics)
library(corrplot)
library(factoextra)
library(lavaan)
#################
#Clear workspace#
#################
rm(list=ls(all=T))

MRIsubs<-read.csv('barbeylab/Downloads/R_CBR/INSIGHT/SubsDTI.csv',header=T,sep=',')


##############
#Read in data#
##############

datz.0<-read.csv('barbeylab/Downloads/R_CBR/INSIGHT/NPSummaryData1b.dat',header=T,sep='	')

################
#Structure data#
################
datz<-datz.0

datz$Group = as.factor(datz$Group)
datz$Eligiblez<-NULL
datz$Completez<-NULL


##############
#Read in data#
##############
datz2.0<-read.csv('barbeylab/Downloads/R_CBR/INSIGHT/QuestionnaireSummaryData1b.dat',header=T,sep='	')

################
#Structure data#
################
datz2<-datz2.0

datz2$Group = as.factor(datz2$Group)
datz2$HighestEd = as.factor(datz2$HighestEd)

datz2$Eligible<-NULL
datz2$Complete<-NULL


d<-datz[,c(19:28)]
d<-na.omit(d)


d<-dat[,c(1,3:4,8:10)]
d2<-datz[,c(1, 6:48)]
d<-join(d,d2,by="Subject")
d2<-datz2[,c(1,7)]
d<-join(d,d2,by="Subject")
d2<-dat[,c(1,5)]
d<-join(d,d2,by="Subject")
d<-d[,c(1:6,17:18,20,24,25,29,30:31,33:35,39,41,48,49, 50:51)]
d<-d[,c(1:6,13:18,22:23)]

dhold<-d
d$Subject<-NULL
d<-d[!c(row.names(d) %in% row.names(d[d$english_n=='NaN',])),]
d<-d[!c(row.names(d) %in% row.names(d[d$HighestEd=='NaN',])),]
d<-na.omit(d)
dcovars<-d
d$english_n<-NULL
d$HighestEd<-NULL
d$Age<-NULL
d$Sex<-NULL
foo2=list()

fa.parallel(d)
vss(d)
pairs.panels(d)
fa.diagram(fa(d,4))
fa.diagram(fa(d,2))
fa.diagram(fa(d,2,fm='wls',rotate="varimax"))
#d<-na.omit(d)
loads<-(fa(d,2))

loads<-loads$scores


##g factor structre

check_factorstructure(d)
efa <- psych::fa(d, nfactors = 2) %>% 
  model_parameters(sort = TRUE,threshold = "max")
efa
predict(efa, names = c("Gf","Gc"))


n <- n_factors(d)
as.data.frame(n)
summary(n)

partitions <- data_partition(d, training_proportion = 0.7)
training <- partitions$training
test <- partitions$test

structure_1 <- psych::fa(training, nfactors = 1) %>% 
  efa_to_cfa()
structure_2 <- psych::fa(training, nfactors = 2)  %>% 
  efa_to_cfa()

s1 <- lavaan::cfa(structure_1, data = test)
s2 <- lavaan::cfa(structure_2, data = test)
performance::compare_performance(s1, s2)


s1 <- lavaan::cfa(structure_1, data = d)
s2 <- lavaan::cfa(structure_2, data = d)
performance::compare_performance(s1, s2)

loads<-lavPredict(s1) 

loads<-data.frame(loads)
loads$Subject<-subnums
colnames(loads)[1]<-"G"
write.csv(loads,'barbeylab/Downloads/R_CBR/INSIGHT/G_CFA_Scores_DTI.csv',row.names=T)


loads<-lavPredict(s2)

loads<-data.frame(loads)
loads$Subject<-subnums
colnames(loads)[1]<-"Gf"
colnames(loads)[2]<-"Gc"
write.csv(loads,'barbeylab/Downloads/R_CBR/INSIGHT/GfGc_CFA_Scores_DTI.csv',row.names=T)




