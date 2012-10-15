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
X$StateHom06 <- SHom[X$Clave%/%1000,52]
X$StateGDP06 <- SGDP[X$Clave%/%1000,grep(2006,names(SGDP))]

#last Party before Calderon period (?) is this the one we want?
X$PartyMunBC <- cartInt[,3]


write.csv(X,"data/dataToPSMatch.csv")
############################
#
# Lets get prior balance checks
#
###########################

#par(mfrow=c(2,8), mai=c(0.6,0.3,0.2,0.1))
par(mfrow=c(2,7), mai=c(0.6,0.3,0.2,0.1))

#for(i in 6:13)
for(i in 14:21)
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
for(i in 14:21)
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
names(compfull)[16] = "missIndDocsPerUnit"

# checking the distribution of propensity scores (balance on a fundamental covariate?)
pst<-match.data(m1)[treated==1,"distance"]
psc<-match.data(m1)[matches,"distance"]
par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
hist(pst,col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
hist(psc,col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,100))

# check the balance on the other covariates (histograms and love plots)
factors<-"PartyMunBC"

TreatCov<-compfull[treated==1,]
ContMatchesCov<-compfull[matches,]
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

#Mtching based only on Homicide Rate and higher order terms that involve it
fmla <- as.formula(paste("treated ~ Hom06+",paste("Hom06:",names(compfull), collapse= "+")))
mH <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","missIndDocsPerUnit"),ratio=5)

WsTilde<-calcWeights(mH$match.matrix,dim(compfull)[1])
# checking the distribution of propensity scores (balance on a fundamental covariate?)
matchesH<-as.numeric(c(t(mH$match.matrix)))
matchesH<-matches2[!is.na(matchesH)]

postMatchHR<-calcMeansAndVars(TreatCov,compfull[matchesH,],difmeanCovs,difmeanCovs,Ws[treated==1],WsTilde[matchesH])



clavetreated <- clave[treated==1]
regiontreated <- Regions[treated==1]
clavematched <- clave[matchesH]
matchframe <- data.frame(matrix(nrow=length(clavetreated),ncol=7))
for(i in 1:length(clavetreated)){
  matchframe[i,] <- c(clavetreated[i],regiontreated[i],clavematched[((i-1)*5 + 1):(i*5)])
}
names(matchframe) <- c("clave","region",paste("match",1:5,sep=""))

##create loveplots
for(i in 1:length(matchframe$clave)){
  ##calc muni statistics
  treatsub <- matchframe$clave[i]
  matchsub <- unlist(matchframe[i,c(paste("match",1:5,sep=""))])
  reg.treat.cov <-  compfull[clave%in%treatsub,]
  reg.control.cov <-  compfull[clave%in%matchsub,]
  ##TODO weights are not correct
  munilove <- calcMeansAndVars(reg.treat.cov,reg.control.cov,difmeanCovs,difmeanCovs,Ws[clave%in%treatsub],WsTilde[clave%in%matchsub])

  ##calc region statistics. 
  region.index <- matchframe$region[i] #Super inefficient but too tired to care
  regsub <- subset(compfull,Regions==region.index)
  treatsub <- matchframe[matchframe$region==reg,]$clave
  matchsub <- unlist(matchframe[matchframe$region==reg,c(paste("match",1:5,sep=""))])
  reg.treat.cov <-  compfull[clave%in%treatsub,]
  reg.control.cov <-  compfull[clave%in%matchsub,]
##TODO weights are not correct
  regionlove <- calcMeansAndVars(reg.treat.cov,reg.control.cov,difmeanCovs,difmeanCovs,Ws[clave%in%treatsub],WsTilde[clave%in%matchsub])

  ##loveplot
  lpMat<-list(Init,postMatchHR,regionlove,munilove)
  png(paste("Images/loveplot",matchframe$clave[i],".png",sep=""))
  loveplot(lpMat,labels=c("Initial","Matched HomR","Region","Munipality"),xlim=c(-1,1))
  dev.off()
}
### hist test


### hist test


TreatMat <-compfull[treated==1 & ,]
ContMat<-compfull[treated==0,]

histCheck(compfull[treated==1,],compfull[treated==0,],1:6)
x11()
histCheck(compfull[treated==1,],compfull[matches,],1:6)
x11()
histCheck(compfull[treated==1,],compfull[matches2,],1:6)
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
regs<-sort(unique(Regions))[-1]
for(r in regs)
{
    
}


########################
#
# Analysis
#
########################

# get the homicide rate
Date<-unlist(intUnitInfo)[names(unlist(intUnitInfo))=='Date'][-I2010]

 matches=matchesH
# get rid of all the units that were eliminated for this process
HomMod<-Hom[-gotT2010,]
HomMod<-HomMod[(missind[,4]!=TRUE & missind[,5]!=TRUE),]

PopMod<-Pop[-gotT2010,]
PopMod<-PopMod[(missind[,4]!=TRUE & missind[,5]!=TRUE),]

effects<-rep(NA,length(regs))
effectsD<-rep(NA,length(regs))
varsB<-matrix(NA,length(regs),2)
varsN<-matrix(NA,length(regs),2)
varsND<-matrix(NA,length(regs),2)
Y<-rep(NA,dim(compfull)[1])
# number of matches
m<-5
tracks<-c()
for(i in 1:length(regs))
{
    # get the
    r=regs[i] 
    rowsR<-which(Regions==r)
    matchesR<-as.numeric(mH$match.matrix[as.numeric(rownames(mH$match.matrix)) %in% rowsR,])
    rowsMod<-c(rowsR,matchesR)
    #we add 1 because the homicide column is right after it 
    colH<-grep(Date[i],names(HomMod))+1
    colP<-grep(Date[i],names(PopMod))+1
    cat("i=",i," colH=", colH," colP=",colP,"\n")
    Y[rowsMod]<-HomMod[rowsMod,colH]/PopMod[rowsMod,colP]
    pj1<-mean(Y[rowsR])
    pj0<-sum(WsTilde[matchesR]*Y[matchesR])
    effects[i]<-(pj1-pj0)*100000
    effectsD[i]<-(pj1-mean(compfull$Hom06[rowsR]/100000)-
        pj0+mean(compfull$Hom06[matchesR])/100000)*100000
    # pij0<-rep(NA,m)
    # nij0<-rep(NA,m)
    # for(j in 1:(length(matchesR)/5))
    # {
    #     pointer<-matchesR[((j-1)*5+1):(j*5)]
    #     pij0[j]<-sum(Vs[pointer]*Y[pointer])
    #     nij0[j]<-sum(PopMod[pointer,colP])
    # }
    varsB[i,]<-c(pj1*(1-pj1)/sum(PopMod[rowsR,colP])*100000^2,
        pj0*(1-pj0)/sum(PopMod[rowsR,colP])*100000^2)
        #sum(Ws[rowsR]^2*pij0*(1-pij0))*100000^2/sum(nij0))
    varsN[i,]<-c(var(Ws[rowsR]*Y[rowsR])*100000^2/(1-sum(Ws[rowsR]^2)),
        var(WsTilde[matchesR]*Y[matchesR])*100000^2/(1-sum(WsTilde[matchesR]^2)))    
    varsN[i,]<-c(var(Ws[rowsR]*(Y[rowsR]))*100000^2/(1-sum(Ws[rowsR]^2)),
               var(WsTilde[matchesR]*Y[matchesR])*100000^2/(1-sum(WsTilde[matchesR]^2)))    
   varsND[i,]<-c(var(Ws[rowsR]*(Y[rowsR]-compfull$Hom06[rowsR]/100000))*100000^2/(1-sum(Ws[rowsR]^2)),
              var(WsTilde[matchesR]*(Y[matchesR]-compfull$Hom06[matchesR]/100000))*100000^2/(1-sum(WsTilde[matchesR]^2)))               
        
}
#varsN[,1]<-0#var(Y[treated==1]*100000)
Results<-cbind(tab[-1,][-I2010,],effects,sqrt(apply(varsB,1,sum)),sqrt(apply(varsN,1,sum)),effectsD,sqrt(apply(varsND,1,sum)))
colnames(Results)<-c("num Mun","Date","effect","SD bin","SD ney","effect G","SD ney G")

xtable(Results)

Response<-calcMeansAndVars(matrix(Y[treated==1]),matrix(Y[matchesH]),1,1,Ws[treated==1],WsTilde[matchesH])
# Variance calculation

VN<-c(var(Ws[treated==1]/13*Y[treated==1])*100000^2/(1-sum((Ws[treated==1]/13)^2)),
 var(WsTilde[matches]/13*Y[matches])*100000^2/(1-sum((WsTilde[matches]/13)^2)))
VB<-apply(varsB,2,sum)/13^2

### gain scores
ResponseG<-calcMeansAndVars(matrix(Y[treated==1]-compfull$Hom06[treated==1]/100000),
        matrix(Y[matches]-compfull$Hom06[matches]/100000),1,1,Ws[treated==1],WsTilde[matchesH])
# Variance calculation

VN<-c(var(Ws[treated==1]/13*Y[treated==1])*100000^2/(1-sum((Ws[treated==1]/13)^2)),
 var(WsTilde[matches]/13*Y[matches])*100000^2/(1-sum((WsTilde[matches]/13)^2)))
 VNG<-c(var(Ws[treated==1]/13*(Y[treated==1]-compfull$Hom06[treated==1]/100000))*100000^2/(1-sum((Ws[treated==1]/13)^2)),
  var(WsTilde[matches]/13*(Y[matches]-compfull$Hom06[matches]/100000))*100000^2/(1-sum((WsTilde[matches]/13)^2))) 
VB<-apply(varsB,2,sum)/13^2


ResAv<-c(250,0, (Response[,1]-Response[,2])*100000,sqrt(sum(VB)),sqrt(sum(VN)),
    (ResponseG[,1]-ResponseG[,2])*100000,sqrt(sum(VNG)))

Results<-rbind(Results, ResAv)

write("Results.tsv",Results,sep="   ")

#### get the plot of the effect



colors=c("coral2","coral","royalblue","coral2","darkorchid")

par(mar=c(9,5,2,2))
Res<-read.delim("data/Results.tsv", header = TRUE, sep = "\t")
n=dim(Res)[1]-1
plot(c(1:n),Res[-14,7] ,type='p',col="white", bg=colors[1],ylab="homicide rate pero 100000 inhabitants",xlab='Region'
    ,xaxt="n",pch=21,ylim=c(-70,370))

    
axis(side=1, at=c(1:n),labels=Res[-14,1],las=2,family="serif",font.lab=1,cex.axis=0.7)
segments(c(1:n),Res[-14,7]-1.96*Res[-14,8],c(1:n),Res[-14,7]+1.96*Res[-14,8],col=colors[2],lty=1)
segments(c(1:n)-0.1,Res[-14,7]-1.96*Res[-14,8],c(1:n)+.1,Res[-14,7]-1.96*Res[-14,8],col=colors[2],lty=1)
segments(c(1:n)-0.1,Res[-14,7]+1.96*Res[-14,8],c(1:n)+.1,Res[-14,7]+1.96*Res[-14,8],col=colors[2],lty=1)
abline(h=Res[14,7],lty=1,col="black")
abline(h=Res[14,7]-1.96*Res[14,8],lty=3,col="black")
abline(h=Res[14,7]+1.96*Res[14,8],lty=3,col="black")
abline(h=0,lty=1,col="darkgray")


points(c(1:n),Res[-14,4],type='p',col="white",bg='gray',pch=23,cex=0.7)
segments(c(1:n),Res[-14,4]-1.96*Res[-14,6],c(1:n),Res[-14,4]+1.96*Res[-14,6],col='darkgray',lty=1)
segments(c(1:n)-0.1,Res[-14,4]-1.96*Res[-14,6],c(1:n)+.1,Res[-14,4]-1.96*Res[-14,6],col='darkgray',lty=1)
segments(c(1:n)-0.1,Res[-14,4]+1.96*Res[-14,6],c(1:n)+.1,Res[-14,4]+1.96*Res[-14,6],col='darkgray',lty=1)
