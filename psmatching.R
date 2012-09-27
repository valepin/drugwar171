# author: Valeria Espinosa
# date: Sept 24/2012 (cumple Bertha0)


# read in the tsv's
Educ<- read.delim("MunEducation.tsv", header = TRUE, sep = "\t")
cartInt<- read.delim("CartelIncomeExpensesByMunicipality.tsv", header = TRUE, sep = "\t")
Hom<- read.delim("MunHomicides.tsv", header = TRUE, sep = "\t")
Pop<- read.delim("MunPopulationEst.tsv", header = TRUE, sep = "\t")
Int<-read.delim("InterventionDataNexos2011.tsv", header = TRUE, sep = "\t")


# get the references of which municipalities are in treated regions(units) and how many
intervened<-which(cartInt$Intervened.Units>0)
Nt<-length(unique(cartInt$Intervened.Units[intervened]))

# get the information relevant for each treated unit
for(i in 1:Nt)
{
    intUnitInfo[[i]]=

}
#
table(cartInt$Intervened.Units)

#let's look at the homicide rates from 1990 to 2006 (before any intrevention)
Hcols<-seq(from=4,to=52,by=3)
plot(1:17,Hom[-intervened,Hcols][1,],ylim=c(0,500))
apply(Hom[-intervened,Hcols][-1,],1,plot,1:17,add=T)
