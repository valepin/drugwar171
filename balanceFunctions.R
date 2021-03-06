# author: Valeria Espinosa
# date: Oct 4, 2012
# Goal: balance plots - functions

calcWeights<-function(MatchMat,N)
{
    n<-dim(MatchMat)[1]
    wsTilde<-rep(0,N)
    vs<-rep(0,N)
    for(i in 1:n)
    {        
        munMatch<-as.numeric(MatchMat[i,])
        munMatch<-munMatch[!is.na(munMatch)]
        # cat("munMatch",munMatch,"\n")
        vs[munMatch]<-compfull[munMatch,9]/sum(compfull[munMatch,9]) 
        wsTilde[munMatch]<-Ws[as.numeric(rownames(MatchMat)[i])]*compfull[munMatch,9]/sum(compfull[munMatch,9])         
        # cat("Ws ",i,"=",as.numeric(rownames(MatchMat)[i]),"\n")
        # cat("PopNum",compfull[munMatch,9],"\n")
        # cat("PopDen ", i," = " ,compfull[munMatch,9],"\n")
        #cat("NAs = ",sum(is.na(wsTilde))," i=",i,"\n")
    }
    Vs<<-vs
    return(wsTilde)
}

calcMeansAndVars<-function(TreatMat, ContMat, Covs, cont, Ws,WsTilde)
{   
    means<- matrix(NA,length(Covs),4)
    # make the weights add up to 1
    Ws=Ws/sum(Ws)
    WsTilde=WsTilde/sum(WsTilde)
    i=1
    j=1
    #browser()
    for (co in Covs) {
        means[i,1:2]=c(sum(Ws*TreatMat[,co],na.rm=TRUE),sum(WsTilde*ContMat[,co],na.rm=TRUE))
        means[i,3:4]=c(ifelse(is.element(co,cont),sum((Ws*TreatMat[,co]-means[i,1])^2,na.rm=TRUE)*sum(Ws^2),1/2),
          ifelse(is.element(co,cont),sum((WsTilde*ContMat[,co]-means[i,2])^2,na.rm=TRUE)*sum(WsTilde^2),1/2))
        # means[i,3:4]=c(ifelse(is.element(co,cont),sum(Ws^2)*var(TreatMat[,co]),1/2),
        #   ifelse(is.element(co,cont),sum(WsTilde^2)*var(ContMat[,co]),1/2))
        i=i+1
    }
    colnames(means)=c("meanT","meanC","varT","varC")
    rownames(means)=names(TreatMat)[Covs]    
    return("means"= means)

}

loveplot<-function(MatPlot,cont=TRUE, labels=c(),xlims=c(-3,3),bg_col="#32323299", leg_col="white", position="topright",leg_size=1) # if not the
{
    #Let MatPlot only have the covariates to plot
    # The first one should be the original sample 
    colors=c("black","gray","royalblue","coral2","darkorchid")
    types=25:21
    par(mai=c(0.5,1,0.5,0.1),mfrow=c(1,1),col=bg_col,bg=bg_col,col.axis=leg_col,col.lab=leg_col) 
    plot((MatPlot[[1]][,1]-MatPlot[[1]][,2])/sqrt(apply(MatPlot[[1]][,3:4],1,sum)), 1:dim(MatPlot[[1]])[1], col=bg_col, bg=colors[1], xlab=NA, ylab=NA, yaxt="n",pch=25,cex=1.5, 
    main=ifelse(cont,""),xlim=xlims)
    for(i in 2:length(MatPlot))
    {
        points((MatPlot[[i]][,1]-MatPlot[[i]][,2])/sqrt(apply(MatPlot[[1]][,3:4],1,sum)), 1:dim(MatPlot[[1]])[1], col=bg_col, bg=colors[i], xlab=NA, ylab=NA, yaxt="n",pch=types[i],cex=1.5)
    }
 
    axis(2, labels=rownames(MatPlot[[1]]), at=1:dim(MatPlot[[1]])[1],font.lab=1,cex.axis=0.8,hadj=0.5,padj=1,las=1,col=leg_col,col.ticks=leg_col,col.lab=leg_col)
    abline(v=0,col=leg_col)
    abline(h=1:dim(MatPlot[[1]])[1], lty="dotted",col="lightgray")
    legend(position,legend=labels,box.col=bg_col,
    pch=c(25:(26-length(lpMat))),col=bg_col,pt.bg=colors[1:length(lpMat)],bg=bg_col,text.col=leg_col,cex=leg_size)   
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

