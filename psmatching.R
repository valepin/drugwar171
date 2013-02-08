# author: Valeria Espinosa
# date: Sept 24/2012 (cumple Bertha)
library(xtable)
library(MatchIt)
library(mice)
source("balanceFunctions.R")
# read in the tsv's at the municipality level
Educ<- read.delim("data/MunEducation.tsv", header = TRUE, sep = "\t")
cartInt<- read.delim("data/CartelIncomeExpensesByMunicipality.tsv", header = TRUE, sep = "\t")
Hom<- read.delim("data/MunHomicides.tsv", header = TRUE, sep = "\t")
Pop<- read.delim("data/MunPopulationEst.tsv", header = TRUE, sep = "\t")
Int<-read.delim("data/InterventionDataNexos2011.tsv", header = TRUE, sep = "\t")
Med <-read.delim("data/MunMedical.tsv", header = TRUE, sep = "\t")
LatLon<-read.delim("data/latlon.tsv", header = FALSE, sep = "\t")
RCRD <- read.csv(file="data/RoadsCRD.csv",header=T)



# read in the tsv's at the state level
ScartInt<- read.delim("data/CartelIncomeExpensesState.tsv", header = TRUE, sep = "\t")
SHom<- read.delim("data/StateHomicides.tsv", header = TRUE, sep = "\t")
SPop<- read.delim("data/StatePop.tsv", header = TRUE, sep = "\t")
SGDP<- read.csv("data/stateGDPcurrentValue.csv", header = TRUE)


# get the references of which municipalities are in treated regions(units) and how many
intervened<-which(cartInt$Intervened.Units>0)
Nt<-length(unique(cartInt$Intervened.Units[intervened]))
Ws<-rep(0,dim(Educ)[1])
Regions<-cartInt$Intervened.Units
# get the information relevant for each treated unit
intUnitInfo=list()
for(i in 1:Nt)
{
    munIs<- which(cartInt$Intervened.Units==i)
    claves<-Pop$Clave[munIs]
    dates<-Int$Date.3[is.element(Int$Clave,claves)]
    intUnitInfo[[i]]=list("Date" = min(dates),"Munis"= munIs,"Claves"=claves)
    Ws[munIs]<-Pop[munIs,19]/sum(Pop[munIs,19]) 
}

#to get the info table in latex 
tab<-cbind(table(cartInt$Intervened.Units),c(NA,unlist(intUnitInfo)[names(unlist(intUnitInfo))=='Date']))
xtable(cbind(tab[2:10,],tab[11:19,]))

# which units were intervened in 2010
I2010<-which(unlist(intUnitInfo)[names(unlist(intUnitInfo))=='Date']=='2010')


#let's look at the homicide rates from 1990 to 2006 (before any intrevention)
# Hcols<-seq(from=4,to=52,by=3)
# plot(1:17,Hom[-intervened,Hcols][1,],ylim=c(0,500))
# apply(Hom[-intervened,Hcols][-1,],1,points,1:17,add=T)

############################
#
# Creating the data set that we'll use for propensity score matching

#
###########################

X<-data.frame(LatLon)

#Medical covs
X <-cbind(X, Med[,grep(2006,names(Med))] )

names(X)<-c("State","Municipality","Lat","Lon","Clave", "ConsultsPerDoc","ConsultsPerMedUnit","DocsPerMedUnit")

# Education Covs 
X$AvEduc05<-Educ[,61]
X$ReadWrite05<-Educ[,46]/Educ[,45]
X$MissReadWrite05<-ifelse(Educ[,45]>0,Educ[,48]/Educ[,45],0)
X$IndLang05<-Educ[,63]/Educ[,62]
X$MissIndLang05<-ifelse(Educ[,63]>0,Educ[,65]/Educ[,63],0) #note that this is well defined as zero if the denominator is zero

#Population 
X$PopMun06 <- Pop[,19] 

# Homicide Rate Information up to 2006
X$Hom06<-Hom[,52]/X$PopMun06*100000
# Get a categorical value for these
quants<-quantile(X$Hom06[X$Hom06>0],seq(0,0.8,by=0.25))

# X$Hom06Class<-rep(0, length(X$Hom06))
# X$Hom06Class[X$Hom06>0 & X$Hom06<=quants[2]]<- 1
# X$Hom06Class[X$Hom06>quants[2] & X$Hom06<=quants[3]]<- 2
# X$Hom06Class[X$Hom06>quants[3] & X$Hom06<=quants[4]]<- 3
# X$Hom06Class[X$Hom06>quants[4]]<- 4
# 
# X$Hom06Class<-rep(0, length(X$Hom06))
# X$Hom06Class[X$Hom06>0 & X$Hom06<=quants[3]]<- 1
# X$Hom06Class[X$Hom06>quants[3]]<- 2

 X$Hom06Class<-rep(0, length(X$Hom06))
# X$Hom06Class[X$HomX$Hom06<=quants[3]]<- 1
 X$Hom06Class[X$Hom06>quants[3]]<- 1


#last Party before Calderon period (?) is this the one we want?
# I thought we mgiht want cartInt[,1]? That's the party before 2006.(NO, that's clave)
# In Dec 2006 calderon came in so if we get a party in his period it may be a
# response. (yes, that's why I got the third column)
X$PartyMunBC <- cartInt[,3]

#Income (Ingresos) and Expenses (Egresos)
X$Inc06   <- cartInt[,43]/X$PopMun06
#X$Exp06 <- cartInt[,42] # I must have made a mistake when cleaning the data set 

# State Info
X$StatePop06   <- SPop[X$Clave%/%1000,grep(2006,names(SPop))]
X$StateHom06 <- SHom[X$Clave%/%1000,52]/X$StatePop06*100000
X$StateGDP06 <- SGDP[X$Clave%/%1000,grep(2006,names(SGDP))]

#last Party before Calderon period (?) is this the one we want?
X$PartyMunBC <- cartInt[,3]


#Added Dec 4, 2012 - roads and criminal rivalry related deaths
##  X$Reg.Cars <- RCRD[,grep("Registered.cars",names(RCRD))]
#  X$CRdeathsDec06 <- RCRD[,grep("Diciembre.2006",names(RCRD))]
# X$CRdeathsJan06 <- RCRD[,grep("Enero.2007",names(RCRD))]
# X$CRdeathsFeb06 <- RCRD[,grep("Febrero.2007",names(RCRD))]
# X$CRdeathsMar06 <- RCRD[,grep("Marzo.2007",names(RCRD))]
#X$CRdeathsApr06 <- RCRD[,grep("Abril.2007",names(RCRD))]



write.csv(X,"data/dataToPSMatch.csv")
############################
#
# Lets get prior balance checks
#
###########################

#par(mfrow=c(2,8), mai=c(0.6,0.3,0.2,0.1))
par(mfrow=c(2,7), mai=c(0.6,0.3,0.2,0.1))

#for(i in 6:13)
for(i in 14:20)
{
    if(names(X)[i]!="PartyMunBC")
    {
        hist(X[intervened,i],col="grey",border="white",main=names(X)[i],breaks=20, xlab="intervened",
        xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))
    }else
    {
        barplot(table(X[intervened,i]),col="grey",border="white",xlab="intervened")
    }    
}

#for(i in 6:13)
for(i in 14:20)
{
    if(names(X)[i]!="PartyMunBC")
    {
        hist(X[-intervened,i],col="lightblue",border="white",main="",xlab="control",breaks=20,
           xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))
    }else
    {
        barplot(table(X[-intervened,i]),col="lightblue",border="white",xlab="control")
    }    
}

#just plot the homicides
par(mfrow=c(2,1), mai=c(0.8,0.5,0.2,0.1))

i=which(colnames(X) %in% "Hom06")
#homicides 
hist(X[intervened,i],col="grey",border="white",main=names(X)[i],breaks=20, xlab="intervened",
xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))

#homicides 
hist(X[-intervened,i],col="lightblue",border="white",main="",xlab="control",breaks=20,ylim=c(0,100),
   xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))
   


#write.csv(X,"dataToPSMatch.csv")

############################
#
# Now, what about the missingness?
#
###########################
palette <- colorRampPalette(c('#0033BB','#ffffff'))(256)

# the intervened units
data<-matrix(as.numeric(!is.na(X[intervened,])),nrow=dim(X[intervened,])[1],ncol=dim(X[intervened,])[2])
rownames(data)= X$Clave[intervened]
colnames(data)= colnames(X)


missing_heatmap <- heatmap(data, scale="none", margins=c(6,1),col=palette,cexRow=0.1,cexCol=0.2)#, col = heat.colors(256))
####
n<-300
contPool<-setdiff(1:dim(X)[1], intervened)
samp<-sample(contPool,n)
data<-matrix(as.numeric(!is.na(X[samp,])),nrow=dim(X[samp,])[1],ncol=dim(X[samp,])[2])
rownames(data)= X$Clave[samp]
colnames(data)= colnames(X)


missing_heatmap <- heatmap(data, scale="none", margins=c(6,1),col=palette,cexRow=0.1,cexCol=0.2)#, col = heat.colors(256))




############################
#
# Now do the matching
#
###########################
treated <- rep(0,dim(X)[1])+(cartInt$Intervened.Units>0)

#eliminate the rows that correspond to treated units of 2010
gotT2010<-c()

for(i in I2010)
{
    gotT2010<-c(gotT2010,intUnitInfo[[i]]$Munis)
}

clave <- X$Clave
full <- cbind(X[,!(names(X) %in% c("State", "Municipality", "Clave"))])
clave <- clave[-gotT2010]
full<-full[-gotT2010,]
treated<-treated[-gotT2010]
Ws<-Ws[-gotT2010]
Regions<-Regions[-gotT2010]

# we have NAs impute? Match on missing?
missind <- as.data.frame(is.na(full)[,apply(is.na(full),2,sum)>0])
names(missind) <- paste(names(as.data.frame(missind)),"miss",sep="")

## this is just me messing around. Not sure how you want to deal with the missing data. I.e. impute using some logistic regression models and just do regular propensity score with the imputed data set? Exact match on missing might be ok but I think we will have to discard 1 treated unit. 

# comp <- complete(mice(full,method="mean",m=1,maxit=1))
# comp<-comp[(missind[,4]!=TRUE & missind[,5]!=TRUE),]
# compfull <- cbind(comp,missind[(missind[,4]!=TRUE & missind[,5]!=TRUE),1:3])
# treated<-treated[(missind[,4]!=TRUE & missind[,5]!=TRUE)]

comp <- complete(mice(full,method="mean",m=1,maxit=1))
comp<-cbind(comp[,!(names(comp) %in% c("ConsultsPerDoc","ConsultsPerMedUnit"))])
comp<-comp[(missind[,4]!=TRUE & missind[,5]!=TRUE),]
compfull <- cbind(comp,missind[(missind[,4]!=TRUE & missind[,5]!=TRUE),3])
compfull<-na.omit(compfull)
compfull<-compfull[,!(names(compfull) %in% c("Exp06"))]
treated<-treated[(missind[,4]!=TRUE & missind[,5]!=TRUE)]
Ws<-Ws[(missind[,4]!=TRUE & missind[,5]!=TRUE)]
Regions<-Regions[(missind[,4]!=TRUE & missind[,5]!=TRUE)]
clave <- clave[(missind[,4]!=TRUE & missind[,5]!=TRUE)]

#m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","ConsultsPerDocmiss","ConsultsPerMedUnitmiss","DocsPerMedUnitmiss"),ratio=5)
rownames(compfull)=1:dim(compfull)[1] #redifine the rownames to have easy access
names(compfull)[dim(compfull)[2]] = "missIndDocsPerUnit"

#check the balance on the other covariates (histograms and love plots)
factors<-"PartyMunBC"

TreatCov<-compfull[treated==1,]
#ContMatchesCov<-compfull[matches,]
difmeanCovs<-setdiff(1:dim(compfull)[2],which(names(TreatCov) %in% factors))


# trying to understand the missing 
# data<-compfull
# data<-X[(missind[,4]!=TRUE & missind[,5]!=TRUE),c(8:17,19:21)]
# psScore<-glm(treated~.*.,data=data,family=binomial(link = "logit"))
# 
# par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
# hist(psScore$fitted.values[intervened],col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
# hist(psScore$fitted.values[-intervened],col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,80))
# 

####


Init<-calcMeansAndVars(compfull[treated==1,],compfull[treated==0,],difmeanCovs,difmeanCovs,Ws[treated==1]
    ,rep(1,sum(treated==0)))
Vs<-c()
#
# # matching based on the main effect
# fmla <- as.formula(paste("treated ~ ", paste(names(compfull), collapse= "+")))
# m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","missIndDocsPerUnit"),ratio=5)
# WsTilde<-calcWeights(m1$match.matrix,dim(compfull)[1])
# matches<-as.numeric(c(t(m1$match.matrix)))
# matches<-matches[!is.na(matches)]
# postMatch<-calcMeansAndVars(TreatCov,compfull[matches,],difmeanCovs,difmeanCovs,Ws[treated==1],WsTilde[matches])
# 
# checking the distribution of propensity scores (balance on a fundamental covariate?)
# pst<-match.data(m1)[treated==1,""]
# psc<-match.data(m1)[matches,"distance"]
# par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
# hist(pst,col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
# hist(psc,col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,100))
# 
# #
# # matching on me and all 2fi with Hom06
# fmla <- as.formula(paste("treated ~ ", paste(names(compfull), collapse= "+"),"+", paste("Hom06:",names(compfull), collapse= "+")))
# m2 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","missind[(missind[, 4] != TRUE & missind[, 5] != TRUE), 3]"),ratio=5)
# WsTilde<-calcWeights(m2$match.matrix,dim(compfull)[1])
# # checking the distribution of propensity scores (balance on a fundamental covariate?)
# matches2<-as.numeric(c(t(m2$match.matrix)))
# matches2<-matches2[!is.na(matches2)]
# 
# pst<-match.data(m2)[treated==1,"distance"]
# psc<-match.data(m2)[matches2,"distance"]
# par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
# hist(pst,col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
# hist(psc,col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,100))
# 

#postMatchHom<-calcMeansAndVars(TreatCov,compfull[matches2,],difmeanCovs,difmeanCovs,Ws[treated==1],WsTilde[matches2])

#Matching based only on Homicide Rate and higher order terms that involve it

fmla <- as.formula(paste("treated ~",paste(names(compfull)[-c(11,12,17)],collapse= "+"),"+",paste("Hom06:",names(compfull), collapse= "+")))
#fmla <- as.formula(paste("treated ~ Hom06+",paste("Hom06:",names(compfull), collapse= "+")))
# for the one below get rid of Hom06Class in X
#mH <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","missIndDocsPerUnit"),ratio=4)
mH <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","Hom06Class","missIndDocsPerUnit"),ratio=3)
WsTilde<-calcWeights(mH$match.matrix,dim(compfull)[1])
# checking the distribution of propensity scores (balance on a fundamental covariate?)
matchesH<-as.numeric(c(t(mH$match.matrix)))
matchesH<-matchesH[!is.na(matchesH)]

postMatchHR<-calcMeansAndVars(TreatCov,compfull[matchesH,],difmeanCovs,difmeanCovs,Ws[treated==1],WsTilde[matchesH])

pst<-match.data(mH)[treated==1,"distance"]
psc<-match.data(mH)[matchesH,"distance"]
par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
hist(pst,col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
hist(psc,col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,100))


clavetreated <- clave[treated==1]
regiontreated <- Regions[treated==1]
clavematched <- clave[matchesH]
matchframe <- data.frame(matrix(nrow=length(clavetreated),ncol=m+2))
for(i in 1:length(clavetreated)){
  matchframe[i,] <- c(clavetreated[i],regiontreated[i],clavematched[((i-1)*m + 1):(i*m)])
}
names(matchframe) <- c("clave","region",paste("match",1:m,sep=""))

lpMat<-list(Init,postMatchHR)
pdf("Images/FinalLoveplot.pdf")
loveplot(lpMat,labels=c("Initial","Matched"),xlim=c(-1,1),bg_col="white",leg_col="black")
dev.off()

# compare Party
par(mfcol=c(2,2), mai=c(0.8,0.5,0.7,0.1))

#Before Matching

barplot(table(compfull$PartyMunBC[treated==0]),col="lightblue",border="white",xlab="control",main="Before Matching")

barplot(table(compfull$PartyMunBC[treated==1]),col="coral",border="white",xlab="intervened",main="Before Matching")

# 

barplot(table(compfull$PartyMunBC[matchesH]),col="lightblue",border="white",xlab="control",main="After Matching")

barplot(table(compfull$PartyMunBC[treated==1]),col="coral",border="white",xlab="intervened",main="After Matching")
#######

# source("balanceFunctions.R")
# png("Images/MEloveplot.png",width=500,height=350)
# loveplot(lpMat,labels=c("Initial","Matched"),xlim=c(-1,1),position="bottomleft",bg_col="grey22")
# dev.off()
# }
# 
# ##create loveplots
# for(i in 1:length(matchframe$clave)){
#   ##calc muni statistics
#   treatsub <- matchframe$clave[i]
#   matchsub <- unlist(matchframe[i,c(paste("match",1:m,sep=""))])
#   reg.treat.cov <-  compfull[clave%in%treatsub,]
#   reg.control.cov <-  compfull[clave%in%matchsub,]
#   ##TODO weights are not correct
#   munilove <- calcMeansAndVars(reg.treat.cov,reg.control.cov,difmeanCovs,difmeanCovs,1,Vs[clave%in%matchsub])
# 
#   ##calc region statistics. 
#   region.index <- matchframe$region[i] #Super inefficient but too tired to care
#   regsub <- subset(compfull,Regions==region.index)
#   treatsub <- matchframe[matchframe$region==region.index,]$clave
#   matchsub <- unlist(matchframe[matchframe$region==region.index,c(paste("match",1:m,sep=""))])
#   reg.treat.cov <-  compfull[clave%in%treatsub,]
#   reg.control.cov <-  compfull[clave%in%matchsub,]
# ##TODO weights are not correct
#   regionlove <- calcMeansAndVars(reg.treat.cov,reg.control.cov,difmeanCovs,difmeanCovs,Ws[clave%in%treatsub],WsTilde[clave%in%matchsub])
# 
#   ##loveplot
#   lpMat<-list(Init,postMatchHR,regionlove,munilove)
#   png(paste("Images/loveplot",matchframe$clave[i],".png",sep=""),width=500,height=350)
# #png(paste("Images/loveplot",matchframe$clave[i],".png",sep=""))
#   loveplot(lpMat,labels=c("Initial","Matched","Region","Municipality"),xlim=c(-1,1),leg_size=1.2,position="bottomright",bg_col=)
#   dev.off()
# }
# ### hist test
# 
# source("balanceFunctions.R")
# ### hist test


TreatMat <-compfull[treated==1,]
ContMat<-compfull[treated==0,]

# histCheck(compfull[treated==1,],compfull[treated==0,],1:6)
# x11()
# histCheck(compfull[treated==1,],compfull[matches,],1:6)
# x11()
histCheck(compfull[treated==1,],compfull[matchesH,],1:6)
histCheck(compfull[treated==1,],compfull[treated==0,],7:13)

histCheck(as.matrix(compfull[treated==1,10]/compfull[treated==1,9]*100000),as.matrix(compfull[matchesH,10]/compfull[matchesH,9]*1000000),1)


######
par(mfrow=c(2,2), mai=c(0.8,0.5,0.7,0.1))

i=which(colnames(X) %in% "PopMun06")
j=which(colnames(compfull) %in% "PopMun06")
#homicides

hist(X[intervened,i],col="coral",border="white",main=paste(names(X)[i]," before\n"),breaks=20, xlab="intervened",
xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))

hist(compfull[treated==1,j],col="coral",border="white",main=paste(names(compfull)[j]," after\n"),breaks=20,ylim=c(0,200), xlab="intervened",
xlim=c(min(compfull[treated==1,j],compfull[matchesH,j],na.rm=TRUE),max(compfull[treated==1,j],compfull[matchesH,j],na.rm=TRUE)))


#homicides 

hist(X[-intervened,i],col="grey",border="white",main=names(X)[i],breaks=20, xlab="control",#ylim=c(0,200),
xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))

hist(compfull[matchesH,j],col="grey",border="white",main=names(compfull)[j],breaks=20, xlab="control",#ylim=c(0,200),
xlim=c(min(compfull[treated==1,j],compfull[matchesH,j],na.rm=TRUE),max(compfull[treated==1,j],compfull[matchesH,j],na.rm=TRUE)))



#checkBalance for each Region
#Quality of matches
regs<-sort(unique(Regions))[-1]

regNames<-c("Tijuana","Nogales","Juárez","Pánuco","Reynosa","Guadalupe","Villa de Cos","Teúl","R. de Romos","Sinaloa",
            "Celaya","Apatzingán","Acapulco")

par(mfcol=c(2,13), mai=c(0.8,0.3,0.5,0.2))
for(i in 1:length(regs))
{
    r=regs[i] 
    rowsR<-which(Regions==r)
    matchesR<-as.numeric(mH$match.matrix[as.numeric(rownames(mH$match.matrix)) %in% rowsR,])
    hist(mH$distance[matchesR],col="lightblue",border="white",ylab="",xlab="control", main= regNames[i],
        xlim=c(min(mH$distance[rowsR],mH$distance[matchesR]),max(mH$distance[rowsR],mH$distance[matchesR])),breaks=5)
    hist(mH$distance[rowsR],col="coral",border="white",main="",ylab="",xlab="intervened", freq=T,
         xlim=c(min(mH$distance[rowsR],mH$distance[matchesR],na.rm=TRUE),max(mH$distance[rowsR],mH$distance[matchesR],
             na.rm=TRUE)),breaks=5)        
}

########################
#
# Analysis
#
########################
regs<-sort(unique(Regions))[-1]

# get the homicide rate
Date<-unlist(intUnitInfo)[names(unlist(intUnitInfo))=='Date'][-I2010]

 matches=matchesH
# get rid of all the units that were eliminated for this process

HomMod<-Hom[-gotT2010,-grep("Criminal",names(Hom))]
HomMod<-HomMod[(missind[,4]!=TRUE & missind[,5]!=TRUE),]

PopMod<-Pop[-gotT2010,]
PopMod<-PopMod[(missind[,4]!=TRUE & missind[,5]!=TRUE),]

effects<-rep(NA,length(regs))
effectsD<-rep(NA,length(regs))
varsB<-matrix(NA,length(regs),2)
varsN<-matrix(NA,length(regs),2)
varsNGv<-matrix(NA,length(regs),2)

PjsG<-matrix(NA,length(regs),2)
Pjs<-matrix(NA,length(regs),2)
Y<-rep(NA,dim(compfull)[1])
G<-rep(NA,dim(compfull)[1])

PjsG2<-matrix(NA,length(regs),2)
G2<-rep(NA,dim(compfull)[1])
varsNGv2<-matrix(NA,length(regs),2)

PjsG3<-matrix(NA,length(regs),2)
G3<-rep(NA,dim(compfull)[1])
varsNGv3<-matrix(NA,length(regs),2)

# number of matcheslengh
m<-3

for(i in 1:length(regs))
{
    # get the
    r=regs[i] 
    rowsR<-which(Regions==r)
    matchesR<-as.numeric(mH$match.matrix[as.numeric(rownames(mH$match.matrix)) %in% rowsR,])
    rowsMod<-c(rowsR,matchesR)
    #we add 1 because the homicide column is right after it 
    colH<-grep(Date[i],names(HomMod))+4
    colP<-grep(Date[i],names(PopMod))+1
    cat("i=",i," colH=", colH," colP=",colP,"\n")
    # get the response
    Y[rowsMod]<-HomMod[rowsMod,colH]/PopMod[rowsMod,colP]
    G[rowsMod]<-HomMod[rowsMod,colH]/PopMod[rowsMod,colP]-HomMod[rowsMod,colH-6]/PopMod[rowsMod,colP-2]
    # get the post treatment homicide rate estimates
    pj1<-sum(Ws[rowsR]*Y[rowsR])
    pj0<-sum(WsTilde[matchesR]*Y[matchesR])
    effects[i]<-(pj1-pj0)*100000
    Pjs[i,]<-c(sum(Ws[rowsR]*Y[rowsR])*100000,sum(WsTilde[matchesR]*Y[matchesR])*100000)    
    # get the post-pre treatment homicide rate estimates    
    effectsD[i]<-(sum(Ws[rowsR]*G[rowsR])-sum(WsTilde[matchesR]*G[matchesR]))*100000
    PjsG[i,]<-c(sum(Ws[rowsR]*G[rowsR])*100000,sum(WsTilde[matchesR]*G[matchesR])*100000)    
    #    
    varsB[i,]<-c(pj1/sum(PopMod[rowsR,colP])*100000^2,
        pj0/sum(PopMod[rowsR,colP])*100000^2)
    varsN[i,]<-c(sum(Ws[rowsR]*Y[rowsR]^2)*100000^2/(1-sum(Ws[rowsR]^2)),
        sum(WsTilde[matchesR]*Y[matchesR]^2)*100000^2/(1-sum(WsTilde[matchesR]^2)))
    #varsNv[i,2]<-var(c(Ws[rowsR]%*%matrix(Y[matchesR],ncol=m,byrow=T)))*100000^2/m
    varsNGv[i,2]<-var(c(Ws[rowsR]%*%matrix(G[matchesR],ncol=m,byrow=T)))*100000^2/m  
    # check if that region can be taken in to account for the "two year" effect, and for the "three year" effect respectively
    if(Date[i]<2009)
    {
     G2[rowsMod]<-HomMod[rowsMod,colH+3]/PopMod[rowsMod,colP+1]-HomMod[rowsMod,colH-6]/PopMod[rowsMod,colP-2]    
      PjsG2[i,]<-c(sum(Ws[rowsR]*G2[rowsR])*100000,sum(WsTilde[matchesR]*G2[matchesR])*100000)
      varsNGv2[i,2]<-var(c(Ws[rowsR]%*%matrix(G2[matchesR],ncol=m,byrow=T)))*100000^2/m
      if(Date[i]<2008)
      {
          G3[rowsMod]<-HomMod[rowsMod,colH+6]/PopMod[rowsMod,colP+2]-HomMod[rowsMod,colH-6]/PopMod[rowsMod,colP-2]    
           PjsG3[i,]<-c(sum(Ws[rowsR]*G3[rowsR])*100000,sum(WsTilde[matchesR]*G3[matchesR])*100000)
          varsNGv3[i,2]<-var(c(Ws[rowsR]%*%matrix(G3[matchesR],ncol=m,byrow=T)))*100000^2/m         
      }      
    }             
}


#varsN[,1]<-0#var(Y[treated==1]*100000)
# Results<-cbind(tab[-1,][-I2010,],Pjs[,1],effectsD,sqrt(apply(varsB,1,sum)),sqrt(apply(varsN,1,sum)),sqrt(varsNv[,2]),PjsG[,1],effectsD,
# sqrt(apply(varsNG,1,sum)),sqrt(varsNGv[,2]))
# colnames(Results)<-c("num Mun","Date","obs HR","effect","SD bin","SD ney","SD reg","obs HR change","effect G","SD ney G","SD reg G")

Results<-cbind(tab[-1,][-I2010,],PjsG[,1],effectsD,sqrt(varsNGv[,2]),PjsG2[,1],PjsG2[,1]-PjsG2[,2],sqrt(varsNGv2[,2])
            ,PjsG3[,1],PjsG3[,1]-PjsG3[,2],sqrt(varsNGv3[,2]))
colnames(Results)<-c("num Mun","Date","obs HR change 1","effect G 1","SD ney G 1","obs HR change 2","effect G 2","SD ney G 2"
                    ,"obs HR change 3","effect G 3","SD ney G 3")


ordRegs<- order(Results[,grep("effect G 1",colnames(Results))],decreasing=T)
regNames<-c("Tijuana","Nogales","Juárez","Pánuco","Reynosa","Guadalupe","Villa de Cos","Teúl","Rincón de Romos","Sinaloa",
            "Celaya","Apatzingán","Acapulco")
          
xtable(Results)

 regNames<-regNames[ordRegs] 



Response<-calcMeansAndVars(matrix(Y[treated==1]),matrix(Y[matchesH]),1,1,Ws[treated==1],WsTilde[matchesH])




# Variance calculation

# VN<-c(var(Ws[treated==1]/13*Y[treated==1])*100000^2/(1-sum((Ws[treated==1]/13)^2)),
#  var(WsTilde[matches]/13*Y[matches])*100000^2/(1-sum((WsTilde[matches]/13)^2))+mean(varsN[,2]))
#  # VNG<-c(var(Ws[treated==1]/13*(Y[treated==1]-compfull$Hom06[treated==1]/100000))*100000^2/(1-sum((Ws[treated==1]/13)^2)),
#  #  var(WsTilde[matches]/13*(Y[matches]-compfull$Hom06[matches]/100000))*100000^2/(1-sum((WsTilde[matches]/13)^2))+mean(varsNG[,2]))
#   VNG<-c(var(PjsG[,1])/length(effectsD)+mean(varsNG[,1]),
#    var(PjsG[,2])/length(effectsD)+mean(varsNG[,2]))
# VB<-apply(varsB,2,sum)/13^2




# with Y & G    
#  Results<-Results[ordRegs,c(1,2,8,9,11)]
#     ResAv<-c(250,0,Response[,1]*100000, (Response[,1]-Response[,2])*100000,sqrt(sum(VB)),sqrt(sum(VN)),ResponseG[,1]*100000,
#         (ResponseG[,1]-ResponseG[,2])*100000,sqrt(sum(apply(PjsG,2,var))/13+mean(varsNGv[,2])))    
# Results<-rbind(Results, ResAv[c(1,2,7:9)])

# only G (with three year estimates)    
 Results<-Results[ordRegs,]
    ResAv<-c(250,0,ResponseG[,1]*100000,
        (ResponseG[,1]-ResponseG[,2])*100000,sqrt(sum(apply(PjsG,2,var))/13+mean(varsNGv[,2])/13),ResponseG2[,1]*100000,
            (ResponseG2[,1]-ResponseG2[,2])*100000,sqrt(sum(apply(PjsG2,2,var,na.rm=T))/sum(!is.na(PjsG2[,1]))+
            mean(varsNGv2[,2],na.rm=T)/sum(!is.na(PjsG2[,1]))),ResponseG3[,1]*100000,
                (ResponseG3[,1]-ResponseG3[,2])*100000,sqrt(sum(apply(PjsG3,2,var,na.rm=T))/sum(!is.na(PjsG3[,1]))+
                mean(varsNGv3[,2],na.rm=T)/sum(!is.na(PjsG3[,1])))
                        )   
                        
ResAv1<-c(250,0,mean(Results[,3]),
    mean(Results[,4]),sqrt(sum(apply(PjsG,2,var))/13+mean(varsNGv[,2])/13),
    mean(Results[,6],na.rm=T),mean(Results[,7],na.rm=T),
         sqrt(sum(apply(PjsG2,2,var,na.rm=T))/sum(!is.na(PjsG2[,1]))+
         mean(varsNGv2[,2],na.rm=T)/sum(!is.na(PjsG2[,1]))),mean(Results[,9],na.rm=T),mean(Results[,10],na.rm=T),
 sqrt(sum(apply(PjsG3[-ordRegs[1],],2,var,na.rm=T))/sum(!is.na(PjsG3[-ordRegs[1],]))+mean(varsNGv3[-ordRegs[1],2],na.rm=T)/sum(!is.na(PjsG3[-ordRegs[1],1])))
    )    
                         

# without Juárez
   ResAvWOJ<-c(250,0,mean(Results[-1,3]),
       mean(Results[-1,4]),sqrt(sum(apply(PjsG[-1,],2,var))/12+mean(varsNGv[-1,2])/12),
       mean(Results[-1,6],na.rm=T),mean(Results[-1,7],na.rm=T),
            sqrt(sum(apply(PjsG2[-ordRegs[1],],2,var,na.rm=T))/sum(!is.na(PjsG2[-ordRegs[1],1]))+
            mean(varsNGv2[-ordRegs[1],2],na.rm=T)/sum(!is.na(PjsG2[-ordRegs[1],1]))),mean(Results[-1,9],na.rm=T),mean(Results[-1,10],na.rm=T),
    sqrt(sum(apply(PjsG3[-ordRegfs[1],],2,var,na.rm=T))/sum(!is.na(PjsG3[-ordRegs[1],]))+mean(varsNGv3[-ordRegs[1],2],na.rm=T)/sum(!is.na(PjsG3[-ordRegs[1],1])))
       )    



        
ResultsF<-rbind(Results, ResAv1,ResAvWOJ)



rownames(ResultsF)<-c(regNames, "Average","Average wJ")

xtable(ResultsF)

output<-data.frame(cbind(rownames(ResultsF),c(rownames(Results),0),ResultsF[,c(1,2,4,5)]))
# !!!!!
# note that this does not respect the column names. To keep processing running it is necessary to write the header in Results.tsv
write(output,file="data/Results.tsv",ncolumns=6,sep="\t")


#### get the plot of the effect




colors=c("coral2","coral","royalblue","coral2","darkorchid")

par(mar=c(9,5,2,2))
Res<-read.delim("data/Results.tsv", header = T, sep = "\t")
n=dim(Res)[1]-1
plot(c(1:n),Res[-14,5] ,type='p',col="white", bg=colors[1],ylab="homicide rate pero 100000 inhabitants",xlab=""
    ,xaxt="n",pch=21,ylim=c(-30,110))

    
axis(side=1, at=c(1:n),labels=Res[-14,1],las=2,family="serif",font.lab=1,cex.axis=0.7)
segments(c(1:n),Res[-14,5]-1.96*Res[-14,6],c(1:n),Res[-14,5]+1.96*Res[-14,6],col=colors[2],lty=1)
segments(c(1:n)-0.1,Res[-14,5]-1.96*Res[-14,6],c(1:n)+.1,Res[-14,5]-1.96*Res[-14,6],col=colors[2],lty=1)
segments(c(1:n)-0.1,Res[-14,5]+1.96*Res[-14,6],c(1:n)+.1,Res[-14,5]+1.96*Res[-14,6],col=colors[2],lty=1)
abline(h=Res[14,5],lty=1,col="black")
abline(h=Res[14,5]-1.96*Res[14,6],lty=3,col="black")
abline(h=Res[14,5]+1.96*Res[14,6],lty=3,col="black")
abline(h=0,lty=1,col="darkgray")


# points(c(1:n),Res[-14,4],type='p',col="white",bg='gray',pch=23,cex=0.7)
# segments(c(1:n),Res[-14,4]-1.96*Res[-14,6],c(1:n),Res[-14,4]+1.96*Res[-14,6],col='darkgray',lty=1)
# segments(c(1:n)-0.1,Res[-14,4]-1.96*Res[-14,6],c(1:n)+.1,Res[-14,4]-1.96*Res[-14,6],col='darkgray',lty=1)
# segments(c(1:n)-0.1,Res[-14,4]+1.96*Res[-14,6],c(1:n)+.1,Res[-14,4]+1.96*Res[-14,6],col='darkgray',lty=1)


#### get some balance checks on other covariates
RCRDmod<-RCRD[-gotT2010,][(missind[,4]!=TRUE & missind[,5]!=TRUE),]
RCRDmod <- complete(mice(RCRDmod,method="mean",m=1,maxit=1))
ExtraCov<-cbind(is.na(RCRDmod[,4]),!is.na(RCRDmod[,4])*RCRDmod[,4],RCRDmod[,c(9:13)],log(compfull$Hom06+1),log(compfull$StateHom06),
    compfull$Hom06^2,compfull$StateHom06^2
    )
    
names(ExtraCov)<-c("MissInd Road Nwk Long","Road Nwk Long if present",paste("Cr.Riv.D.",names(RCRDmod)[9:13]),
"log(Hom06+1)","log(StateHom06+1)",expression(Hom06^2),expression(StateHom06^2))    
#,as.numeric(compfull$Hom06)%*%as.matrix(compfull[,-11]))
test_init<-calcMeansAndVars(ExtraCov[treated==1,],ExtraCov[treated==0,],1:dim(ExtraCov)[2],1:dim(ExtraCov)[2],Ws[treated==1],rep(1,sum(treated==0)))

test_post<-calcMeansAndVars(ExtraCov[treated==1,],ExtraCov[matchesH,],1:dim(ExtraCov)[2],1:dim(ExtraCov)[2],Ws[treated==1],WsTilde[matchesH])
loveplot(list(test_init,test_post),labels=c("Initial","Matched"),xlim=c(-1,1),bg_col="white",leg_col="black")


####### Get the maximum distance in Hom rate 06 between the treated and all its matches
findMaxDistHom06<-function(i)
{
    treat<-compfull$Hom06[as.numeric(row.names(mH$match.matrix)[i])]
    conts<-compfull$Hom06[as.numeric(mH$match.matrix[i,])]
    return(max(abs(conts-treat)))
}


maxDistHR06<-apply(as.matrix(1:dim(mH$match.matrix)[1]),1,findMaxDistHom06)