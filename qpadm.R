#!/usr/bin/env Rscript
library(admixtools)
library(tidyverse)
rm(list=ls())

packageVersion("admixtools")
#setwd("/home/maria_evangelinou/ptixiaki/practice/botqpadm/")
##filename = "apoikia2"
infile = "apoikia.info"
### read the file with the population information to be included in the model
## This file contains information about which model to run and which populations can be considered sources
## or refs for given targets
modinfofile = read.table(infile, sep="\t", h=TRUE)
modinfofile[modinfofile == ""] = NA

## the columns with the model are in columns 6 and 7 
modcolumns = c(6,7) #6:ncol(modinfofile)
modnames = paste("model", 1:length(modcolumns), sep="")

originalIndFile = read.table("apoikia.ind", header=F)
popinfocolumn = min(modcolumns) - 1

allPopsIndex = which(modinfofile[,popinfocolumn] != "Ignore")
allPops = unique(modinfofile[allPopsIndex, popinfocolumn])
targetPops = unique(modinfofile[!is.na(modinfofile[,modcolumns[1]]),popinfocolumn])

i = 1
for(i in 1:length(modcolumns)){
    curMod = modcolumns[i]
    allTargetRows = grep(pattern="TARGET", modinfofile[,curMod])
    allTargets = sort(unique(modinfofile[allTargetRows, curMod]))
    tar = allTargets[1]
    tarIndex = 1
    for(tar in allTargets){
        tarName = paste("Target", tarIndex, sep="")
        tarIndex = tarIndex+1
        targetRows = grep(pattern=tar, modinfofile[,curMod])
        leftrightIndex = which(modinfofile[,popinfocolumn]!="Ignore" & !(1:nrow(modinfofile) %in% targetRows))
        leftright = modinfofile[leftrightIndex,popinfocolumn]
        rightfix = grep("^R", x = modinfofile[,curMod])
        rightfixpops = unique(modinfofile[rightfix,popinfocolumn])
        target = modinfofile[targetRows, popinfocolumn]
        pops = c(leftright, target)
        myf2dir = paste('./f2blocks_', modnames[i], "_", tarName, sep="")
        ## make the ind file
        indsToUse = c(leftrightIndex, targetRows)
        oldlabs = modinfofile[indsToUse,1]
        oldlabs
        
        newlabs = modinfofile[indsToUse,popinfocolumn]
        newleftright = modinfofile[leftrightIndex,popinfocolumn]
        newtarget = rep(tarName, length(target))
        newpops = c(newleftright, newtarget)
        newIndFile = originalIndFile
        rownames(newIndFile) = newIndFile[,1]
        newIndFile[,3] = "Ignore"
        newIndFile[oldlabs,3] = newpops
        ## extract files
        newIndFile
        write.table(x=newIndFile, file=paste(modnames[i], "_", tarName, ".ind", sep=""), quote=F, row.names=F, col.names=F, sep="\t" )
        system(paste("ln -s  apoikia.geno ", paste(modnames[i], "_", tarName, ".geno", sep="")))
        system(paste("ln -s  apoikia.snp ", paste(modnames[i], "_", tarName, ".snp", sep="")))
        filename = paste(modnames[i], "_", tarName, sep="")
        prefix = paste("./", filename, sep="")
        ## extract f2
        extract_f2(prefix, myf2dir,overwrite=TRUE, maxmiss=0.1)
        f2_blocks = f2_from_precomp(myf2dir, afprod=TRUE)
################
        uleftright = unique(newleftright)
        
        utarget = unique(newtarget)
        finalLeftRight = uleftright[!(uleftright %in% rightfixpops)]
        resultsRotate = qpadm_rotate(f2_blocks, target = utarget, rightfix = rightfixpops, leftright=c(finalLeftRight) )
        nonsigIndexes = which(resultsRotate$p > 0.05)
        output1 = paste(filename, ".qpadm1", sep="")
        outdf = as.data.frame(resultsRotate)
        for(j in 1:2){
            outdf[,j] = sapply(outdf[,j], function(x){ paste(unlist(x), collapse=",")})
        }
        write.table(outdf, file=output1, quote=F, sep="\t", row.names=F, col.names=T)
        outdf
        ## check this one for inconsistency
        ##resultsRotate[546,]
        resultsRotateFull = qpadm_rotate(f2_blocks, target = utarget, rightfix = rightfixpops, leftright=c(finalLeftRight), full_results=TRUE)
        ##resultsRotateFull$popdrop[[546]]
        ##outdf[546,]
        ##resultsRotateFull$weights[[546]]
        ##resultsRotateFull$weights[[1]]
        write.table(rightfixpops, "", quote=F, row.names=F)
        nonsigrotate = resultsRotate$left[nonsigIndexes]
        leftnonsig = sapply(nonsigrotate, paste, collapse=',')
        pvaluesnonsig = resultsRotate$p[nonsigIndexes]
        ranks = resultsRotate$f4rank[nonsigIndexes]
        ##save.image(file="qpadm.RData")
        feasibility = sapply(nonsigIndexes, function(ii){sum(resultsRotateFull$weights[[ii]]$weight < 0) == 0})
        ws = sapply(nonsigIndexes, function(ii){
                                        #if( sum(resultsRotateFull$weights[[ii]]$weight < 0) == 0 ){
            return( paste(resultsRotateFull$weights[[ii]]$weight, collapse=",") )
                                        #}else{return("NULL")}
        }
        )
        zs = sapply(nonsigIndexes, function(ii){
                                        #if( sum(resultsRotateFull$weights[[ii]]$z < 0) == 0 ){
            return( paste(resultsRotateFull$weights[[ii]]$z, collapse=",") )
                                        #}else{return("NULL")}
        }
        )
        nonsigdf = data.frame(models=leftnonsig, pvalue=pvaluesnonsig, ranks=ranks)
        nonsigdf$feasibility = feasibility
        nonsigdf$weights=ws
        nonsigdf$z = zs
        df=nonsigdf[order(nonsigdf$pvalue, decreasing=TRUE),]
        output = paste(filename, ".qpadm", sep="")
        write.table(df, file=output, sep="\t", col.names=TRUE, row.names=F, quote=F)
####################
    }
}
    
