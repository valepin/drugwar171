# author: Valeria Espinosa
# date: Sept 24/2012 (cumple Bertha)
library(xtable)
library(MatchIt)
library(mice)
load("balanceFunctions.R")
# read in the tsv's at the municipality level
Educ<- read.delim("data/MunEducation.tsv", header = TRUE, sep = "\t")
cartInt<- read.delim("data/CartelIncomeExpensesByMunicipality.tsv", header = TRUE, sep = "\t")
Hom<- read.delim("data/MunHomicides.tsv", header = TRUE, sep = "\t")
Pop<- read.delim("data/MunPopulationEst.tsv", header = TRUE, sep = "\t")
Int<-read.delim("data/InterventionDataNexos2011.tsv", header = TRUE, sep = "\t")
Med <-read.delim("data/MunMedical.tsv", header = TRUE, sep = "\t")
LatLon<-read.delim("data/latlon.tsv", header = FALSE, sep = "\t")


# read in the tsv's at the state level
#ScartInt<- read.delim("data/CartelIncomeExpensesByState.tsv", header = TRUE, sep = "\t")
SHom<- read.delim("data/StateHomicides.tsv", header = TRUE, sep = "\t")
SPop<- read.delim("data/StatePop.tsv", header = TRUE, sep = "\t")
SGDP<- read.csv("data/stateGDPcurrentValue.csv", header = TRUE)


# get the references of which municipalities are in treated regions(units) and how many
intervened<-which(cartInt$Intervened.Units>0)
Nt<-length(unique(cartInt$Intervened.Units[intervened]))
Ws<-rep(0,dim(Educ)[1])

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

# Homicide Information up to 2006
X$Hom06<-Hom[,52]

#last Party before Calderon period (?) is this the one we want?
# I thought we mgiht want cartInt[,1]? That's the party before 2006.(NO, that's clave)
# In Dec 2006 calderon came in so if we get a party in his period it may be a
# response. (yes, that's why I got the third column)
X$PartyMunBC <- cartInt[,3]


#Income (Ingresos) and Expenses (Egresos)
X$Inc06   <- cartInt[,43]
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

par(mfrow=c(2,8), mai=c(0.6,0.3,0.2,0.1))
#par(mfrow=c(2,7), mai=c(0.6,0.3,0.2,0.1))

for(i in 6:13)
#for(i in 14:21)
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

for(i in 6:13)
#for(i in 14:21)
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
par(mfrow=c(2,2), mai=c(0.8,0.5,0.2,0.1))

i=which(colnames(X) %in% "Hom06")
#homicides 
hist(X[intervened,i],col="grey",border="white",main=names(X)[i],breaks=20, xlab="intervened",
xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))
#homicide rate
hist(X[intervened,i]/X$PopMun06[intervened]*100000,col="grey",border="white",main="Homicide Rate",breaks=20, xlab="intervened",
xlim=c(min(X[intervened,i]/X$PopMun06[intervened]*100000,X[-intervened,i]/X$PopMun06[-intervened]*100000,na.rm=TRUE),
max(X[intervened,i]/X$PopMun06[intervened]*100000,X[-intervened,i]/X$PopMun06[-intervened]*100000,na.rm=TRUE)))
#homicides 
hist(X[-intervened,i],col="lightblue",border="white",main="",xlab="control",breaks=20,ylim=c(0,200),
   xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))
   

#homicide rate
hist(X[-intervened,i]/X$PopMun06[-intervened]*100000,col="lightblue",border="white",main="",xlab="control",breaks=20,ylim=c(0,140),
xlim=c(min(X[intervened,i]/X$PopMun06[intervened]*100000,X[-intervened,i]/X$PopMun06[-intervened]*100000,na.rm=TRUE),
max(X[intervened,i]/X$PopMun06[intervened]*100000,X[-intervened,i]/X$PopMun06[-intervened]*100000,na.rm=TRUE)))

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


full <- cbind(X[,!(names(X) %in% c("State", "Municipality", "Clave"))])

full<-full[-gotT2010,]
treated<-treated[-gotT2010]
Ws<-Ws[-gotT2010]

# we have NAs impute? Match on missing?
missind <- as.data.frame(is.na(full)[,apply(is.na(full),2,sum)>0])
names(missind) <- paste(names(as.data.frame(missind)),"miss",sep="")

## this is just me messing around. Not sure how you want to deal with the missing data. I.e. impute using some logistic regression models and just do regular propensity score with the imputed data set? Exact match on missing might be ok but I think we will have to discard 1 treated unit. 

# comp <- complete(mice(full,method="mean",m=1,maxit=1))
# comp<-comp[(missind[,4]!=TRUE & missind[,5]!=TRUE),]
# compfull <- cbind(comp,missind[(missind[,4]!=TRUE & missind[,5]!=TRUE),1:3])
# treated<-treated[(missind[,4]!=TRUE & missind[,5]!=TRUE)]
# fmla <- as.formula(paste("treated ~ ", paste(names(full), collapse= "+")))
# #m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","ConsultsPerDocmiss","ConsultsPerMedUnitmiss","DocsPerMedUnitmiss"),ratio=5)
# m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC"),ratio=5)

comp <- complete(mice(full,method="mean",m=1,maxit=1))
comp<-cbind(comp[,!(names(comp) %in% c("ConsultsPerDoc","ConsultsPerMedUnit"))])
comp<-comp[(missind[,4]!=TRUE & missind[,5]!=TRUE),]
compfull <- cbind(comp,missind[(missind[,4]!=TRUE & missind[,5]!=TRUE),3])
compfull<-na.omit(compfull)
compfull<-compfull[,!(names(compfull) %in% c("Exp06"))]
treated<-treated[(missind[,4]!=TRUE & missind[,5]!=TRUE)]
Ws<-Ws[(missind[,4]!=TRUE & missind[,5]!=TRUE)]
fmla <- as.formula(paste("treated ~ ", paste(names(compfull), collapse= "+")))

#m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","ConsultsPerDocmiss","ConsultsPerMedUnitmiss","DocsPerMedUnitmiss"),ratio=5)
rownames(compfull)=1:dim(compfull)[1] #redifine the rownames to have easy access
m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","missind[(missind[, 4] != TRUE & missind[, 5] != TRUE), 3]"),ratio=1)
#m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC"),ratio=5)summ




# checking the distribution of propensity scores (balance on a fundamental covariate?)
pst<-match.data(m1)[treated==1,"distance"]
psc<-match.data(m1)[matches,"distance"]
par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
hist(pst,col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
hist(psc,col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,100))

# check the balance on the other covariates (histograms and love plots)
factors<-"PartyMunBC"
names(compfull)[16] = "missIndDocsPerUnit"
TreatCov<-compfull[treated==1,]
ContMatchesCov<-compfull[matches,]
difmeanCovs<-setdiff(1:dim(compfull)[2],which(names(TreatCov) %in% factors))


# trying to understand the missing 
data<-compfull
data<-X[(missind[,4]!=TRUE & missind[,5]!=TRUE),c(8:17,19:21)]
psScore<-glm(treated~.*.,data=data,family=binomial(link = "logit"))

par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
hist(psScore$fitted.values[intervened],col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
hist(psScore$fitted.values[-intervened],col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,80))

fmla <- as.formula(paste("treated ~ ", paste(names(compfull), collapse= "+"),"+", paste("Hom06:",names(compfull), collapse= "+")))
#fmla <- as.formula(paste("treated ~ ", paste(names(compfull), collapse= "+")))
m2 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC","missind[(missind[, 4] != TRUE & missind[, 5] != TRUE), 3]"),ratio=5)
# checking the distribution of propensity scores (balance on a fundamental covariate?)
matches2<-as.numeric(c(t(m2$match.matrix)))
matches2<-matches2[!is.na(matches2)]

pst<-match.data(m2)[treated==1,"distance"]
psc<-match.data(m2)[matches2,"distance"]
par(mfrow=c(2,1),mai=c(0.5,0.5,0.5,0.3))
hist(pst,col="lightgrey",border="white",main="propensity scores - intervened units",breaks=10, xlab="intervened units",xlim=c(0,1))
hist(psc,col="lightblue",border="white",main="propensity scores - control units",breaks=10, xlab="contol units",xlim=c(0,1),ylim=c(0,100))




Init<-calcMeansAndVars(compfull[treated==1,],compfull[treated==0,],difmeanCovs,difmeanCovs,rep(1,sum(treated==1))
    ,rep(1,sum(treated==0)))
#
InitW<-calcMeansAndVars(compfull[treated==1,],compfull[treated==0,],difmeanCovs,difmeanCovs,Ws[treated==1]
    ,compfull$PopMun06[treated==0]/sum(compfull$PopMun06[treated==0]))
#
WsTilde<-calcWeights(m1$match.matrix,dim(compfull)[1])
matches<-as.numeric(c(t(m1$match.matrix)))
matches<-matches[!is.na(matches)]
postMatch<-calcMeansAndVars(TreatCov,compfull[matches,],difmeanCovs,difmeanCovs,Ws[treated==1],WsTilde[matches])

postMatchHomSq<-calcMeansAndVars(TreatCov,compfull[matches2,],difmeanCovs,difmeanCovs,Ws[treated==1],WsTilde[matches2])


lpMat<-list(Init,InitW,postMatch,postMatchHomSq)
lpMat<-list(InitW,Init,postMatch)

loveplot(lpMat,labels=c("Initial","Initial with weights","Matched ME 5","Matched HomSq 5"),xlim=c(-0.5,0.5))

### hist test

TreatMat <-compfull[treated==1,]
ContMat<-compfull[treated==0,]

histCheck(compfull[treated==1,],compfull[treated==0,],1:6)
x11()
histCheck(compfull[treated==1,],compfull[matches,],1:6)
x11()
histCheck(compfull[treated==1,],compfull[matches2,],1:6)
histCheck(compfull[treated==1,],compfull[treated==0,],7:13)
