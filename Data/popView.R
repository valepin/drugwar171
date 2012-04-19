# author: Valeria Espinosa
# date: april 3, 2012

pop = read.csv("poblacion.csv",header=TRUE)

nr=dim(pop)[1]
nc=dim(pop)[2]-2
popInterpolated = matrix(NA,nr, nc+16)
colnames(popInterpolated)=c(1990:2010)
rownames(popInterpolated)=pop[,2]
pop=pop[,-c(1,2)]

for(j in 1:21)
{   
    print(j)
    numaft=(j-1)%%5
    start=(j-1)%/%5+1
    
    if(numaft==0)
    {
        popInterpolated[,j]=pop[,start]
    }else
    {   
        
        slopes=(pop[,start+1]-pop[,start])/5
        # y=y_0+m(x-x_0) where x_0 is the number after
        popInterpolated[,j]=pop[,start]+slopes*numaft 
   }
}

miss_ind=which(is.na(pop[,2]))
for(j in 2:10)
{   
    print(j)
    numaft=(j-1)%%10
    start=(j-1)%/%10+1
    
    slopes=(pop[miss_ind,start+2]-pop[miss_ind,start])/5
    # y=y_0+m(x-x_0) where x_0 is the number after
    popInterpolated[miss_ind,j]=pop[miss_ind,start]+slopes*numaft 

}

write.csv(popInterpolated,"populationEst.csv")




### Now create the data set for the cartels (average )
# date: april 16, 2012

#get the population inf
pop = read.csv("MunPopulationEst.csv",header=TRUE)
hom = read.csv("MunHomicides.csv",header=TRUE)
homInd=c(seq(4,55,by=3),59,63,67)
cart = read.csv("CartelIncomeExpensesByMunicipality.csv",header=TRUE)

cartels=c("G","Z","P","F","J","S","N","D","s","a","z")
numCar=length(cartels)

car2007 = matrix(NA,nrow=2*numCar,ncol=21)

car2010 = matrix(NA,nrow=2*numCar,ncol=21)

for(car in cartels)
{
    # determine what the row is
    i= which(cartels==car)
    # for 2007
    car2007[2*i-1,]=apply(hom[cart[,6]==car,homInd],2,sum)
    car2007[2*i,]=apply(pop[cart[,6]==car,-c(1,2)],2,sum)
    # for 2008
    car2010[2*i-1,]=apply(hom[cart[,7]==car,homInd],2,sum)
    car2010[2*i,]=apply(pop[cart[,7]==car,-c(1,2)],2,sum)
}

car2007=rbind(car2007, apply(hom[,homInd],2,sum), apply(pop[,-c(1,2)],2,sum))
car2010=rbind(car2010, apply(hom[,homInd],2,sum),apply(pop[,-c(1,2)],2,sum))
colnames(car2010 )=c(1990:2010)
colnames(car2007 )=c(1990:2010)
rownames(car2010)=c(rbind( c(cartels,"national"),c(cartels,"national")))
rownames(car2007)=c(rbind( c(cartels,"national"),c(cartels,"national")))
write.csv(car2007,"cartel2007HR.csv")
write.csv(car2010,"cartel2010HR.csv")

