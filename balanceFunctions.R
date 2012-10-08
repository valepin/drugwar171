# author: Valeria Espinosa
# date: Oct 4, 2012
# Goal: balance plots - functions



calcMeansAndVars<-function(TreatMat, ContMat, Covs, cont, ws)
{
    means<- matrix(NA,length(Covs),4)
    #vars <- rep(NA,length(cont))
    i=1
    j=1
    #browser()
    for (co in Covs) {
        means[i,]=c(sum(Tweights*TreatMat[,co],na.rm=TRUE),sum(Cweights*ContMat[,co],na.rm=TRUE),
        ifelse(is.element(co,cont),var(TreatMat[,co],na.rm=TRUE)/dim(TreatMat)[1],NA),
         ifelse(is.element(co,cont),var(TreatMat[,co],na.rm=TRUE)/dim(TreatMat)[1],NA)var(ContMat[,co],na.rm=TRUE)/dim(ContMat)[1]),NA))
        i=i+1
    }
    colnames(means)=c("meanT","meanC","propMiss","varTauHat")
    rownames(means)=names(TreatMat)[Covs]
    
    return("means"= means)
# modify the way the variance is calculated to take the weights in to account
}

loveplot<-function(MatPlot,cont=TRUE, labels=c())
{
    #Let MatPlot only have the covariates to plot
    # The first one should be the original sample 
    colors=c("aquamarine4","orchid","gray","royalblue","coral2","darkorchid")
    types=25:21
    par(mai=c(0.5,1,0.5,0.1),mfrow=c(1,1))
    plot((MatPlot[[1]][,1]-MatPlot[[1]][,2])/sqrt(MatPlot[[1]][,4]), 1:dim(MatPlot[[1]])[1], col="white", bg="aquamarine4", xlab=NA, ylab=NA, yaxt="n",pch=25,cex=1.2, 
    main=ifelse(cont,"t statistics for differences in ordinal variables","mean differences in binary variables"))
    for(i in 2:length(MatPlot))
    {
        points((MatPlot[[i]][,1]-MatPlot[[i]][,2])/sqrt(MatPlot[[1]][,4]), 1:dim(MatPlot[[1]])[1], col="white", bg=colors[i], xlab=NA, ylab=NA, yaxt="n",pch=types[i],cex=1.2)
    }
 
    axis(2, labels=rownames(MatPlot[[1]]), at=1:dim(MatPlot[[1]])[1],font.lab=1,cex.axis=0.8,hadj=0.5,padj=1,las=1)
    abline(v=0)
    abline(h=1:dim(MatPlot[[1]])[1], lty="dotted",col="lightgray")
    # legend("topright",legend=c("Initial","Without 0 Blacks cases","Matching of D & A","Matching of Imbalanced Or","Matching All"),
    # pch=c(25,21,22,23,24),col="white",pt.bg=c("aquamarine4","gray","coral2","royalblue","darkorchid"),bg="white")
    legend("topleft",legend=labels,
    pch=c(25:(26-length(lpMat))),col="white",pt.bg=colors[1:length(lpMat)],bg="white",cex=0.7)   
}

histCheck<-function(TreatMat, ContMat, Covs)
{
    n<-length(Covs)
    par(mfrow=c(2,n), mai=c(0.6,0.3,0.2,0.1))
    for(i in Covs)
    {
        if(class(TreatMat[,i])== "numeric")
        {
            hist(TreatMat[,i],col="lightgrey",border="white",main=names(TreatMat)[i],breaks=20, xlab="intervened",
            xlim=c(signif(min(TreatMat[,i],ContMat[,i],na.rm=TRUE),3),signif(max(TreatMat[,i],ContMat[,i],na.rm=TRUE),3)))
        }else
        {
            barplot(table(TreatMat[,i]),col="lightgrey",border="white",xlab="intervened")
        }    
    }
    for(i in Covs)
    {
        if(class(ContMat[,i])=='numeric')
        {
            hist(ContMat[,i],col="lightblue",border="white",main="",breaks=20, xlab="control",
            xlim=c(min(ContMat[,i],ContMat[,i],na.rm=TRUE),max(TreatMat[,i],ContMat[,i],na.rm=TRUE)))
        }else
        {
            barplot(table(ContMat[,i]),col="lightblue",border="white",xlab="control")
        }
    }    
}