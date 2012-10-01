# author: Valeria Espinosa
# date: Sept 24/2012 (cumple Bertha)
library(xtable)
library(MatchIt)
library(mice)
# read in the tsv's at the municipality level
Educ<- read.delim("data/MunEducation.tsv", header = TRUE, sep = "\t")
cartInt<- read.delim("data/CartelIncomeExpensesByMunicipality.tsv", header = TRUE, sep = "\t")
Hom<- read.delim("data/MunHomicides.tsv", header = TRUE, sep = "\t")
Pop<- read.delim("data/MunPopulationEst.tsv", header = TRUE, sep = "\t")
Int<-read.delim("data/InterventionDataNexos2011.tsv", header = TRUE, sep = "\t")
Med <-read.delim("data/MunMedical.tsv", header = TRUE, sep = "\t")
LatLon<-read.delim("data/latlon.tsv", header = FALSE, sep = "\t")


# read in the tsv's at the state level
ScartInt<- read.delim("data/CartelIncomeExpensesByState.tsv", header = TRUE, sep = "\t")
SHom<- read.delim("data/StateHomicides.tsv", header = TRUE, sep = "\t")
SPop<- read.delim("data/StatePop.tsv", header = TRUE, sep = "\t")
SGDP<- read.csv("data/stateGDPcurrentValue.csv", header = TRUE)


# get the references of which municipalities are in treated regions(units) and how many
intervened<-which(cartInt$Intervened.Units>0)
Nt<-length(unique(cartInt$Intervened.Units[intervened]))

# get the information relevant for each treated unit
intUnitInfo=list()
for(i in 1:Nt)
{
    munIs<- which(cartInt$Intervened.Units==i)
    claves<-Pop$Clave[munIs]
    dates<-Int$Date.3[is.element(Int$Clave,claves)]
    intUnitInfo[[i]]=list("Date" = min(dates),"Munis"= munIs,"Claves"=claves)
}

#to get the info table in latex 
tab<-cbind(table(cartInt$Intervened.Units),c(NA,unlist(intUnitInfo)[names(unlist(intUnitInfo))=='Date']))
xtable(cbind(tab[2:10,],tab[11:19,]))

#let's look at the homicide rates from 1990 to 2006 (before any intrevention)
Hcols<-seq(from=4,to=52,by=3)
plot(1:17,Hom[-intervened,Hcols][1,],ylim=c(0,500))
apply(Hom[-intervened,Hcols][-1,],1,points,1:17,add=T)

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
X$MissReadWrite05<-Educ[,48]/Educ[,45]
X$IndLang05<-Educ[,63]/Educ[,62]
X$MissIndLang05<-ifelse(Educ[,63]>0,Educ[,65]/Educ[,63],0) #note that this is well defined as zero if the denominator is zero
# put NAs when Educ[,63] == 0?
X$MissIndLang05[Educ[,63]==0] <- NA

# Homicide Information up to 2006
X$Hom06<-Hom[,52]

#Population 
X$PopMun06 <- Pop[,19] 


#last Party before Calderon period (?) is this the one we want?
# I thought we mgiht want cartInt[,1]? That's the party before 2006.(NO, that's clave)
# In Dec 2006 calderon came in so if we get a party in his period it may be a
# response. (yes, that's why I got the third column)
X$PartyMunBC <- cartInt[,3]


#Income (Ingresos) and Expenses (Egresos)
X$Inc06   <- cartInt[,43]
X$Exp06 <- cartInt[,42]

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

for(i in 6:13)
#for(i in 14:21)
{
    if(names(X)[i]!="PartyMunBC")
    {
        hist(X[intervened,i],col="lightgrey",border="white",main=names(X)[i],breaks=20, xlab="intervened",
        xlim=c(min(X[intervened,i],X[-intervened,i],na.rm=TRUE),max(X[intervened,i],X[-intervened,i],na.rm=TRUE)))
    }else
    {
        barplot(table(X[intervened,i]),col="lightgrey",border="white",xlab="intervened")
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





#write.csv(X,"dataToPSMatch.csv")


############################
#
# Now do the matching
#
###########################
treated <- rep(0,dim(X)[1])+(cartInt$Intervened.Units>0)
full <- cbind(X[,!(names(X) %in% c("State", "Municipality", "Clave"))])
# we have NAs impute? Match on missing?
missind <- as.data.frame(is.na(full)[,apply(is.na(full),2,sum)>0])
names(missind) <- paste(names(as.data.frame(missind)),"miss",sep="")

## this is just me messing around. Not sure how you want to deal with the missing data. I.e. impute using some logistic regression models and just do regular propensity score with the imputed data set? Exact match on missing might be ok but I think we will have to discard 1 treated unit. 

## comp <- complete(mice(full,m=1,maxit=1))
## compfull <- cbind(comp,missind)
## fmla <- as.formula(paste("treated ~ ", paste(names(full), collapse= "+")))
## m1 <- matchit(fmla,data=cbind(compfull,treated), exact=c("PartyMunBC",names(missind)),ratio=1)
