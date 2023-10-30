##---------network graph for qpAdm results---------##
#takes one argument, the output tsv from qpAdm
#Now, it takes into account the cumulative weight (sum) of each pop (for point size in the plot) 
#and the frequency of each pair (for the line width) over all true models
#packages requirement
if(!require('igraph',character.only = T)){
  install.packages('igraph')
}
library(igraph)

args = commandArgs(TRUE)

#reading qpAdm output --> edge list
#on edge list every row represents a connection between source and target
data=args[1]

#read the output of qpadm
qpout = read.table(data, header = T, sep = '\t')

##filter for TRUE models
qpout_true = qpout[which(qpout$feasibility==TRUE),]
all_pops = unique(unlist(strsplit(qpout$models,',')))
true_pops = unique(unlist(strsplit(qpout_true$models,',')))

#pinaka me kathe plithismo kai to varos tou se kathe modelo 
total.pops.number = length(unlist(strsplit(qpout_true$models,',')))

weight.mat.true = matrix(c(unlist(strsplit(qpout_true$models,',')),unlist(strsplit(qpout_true$weights,','))), 
                    nrow=total.pops.number, ncol=2, byrow=F)

#make the weight.sum: has the weight of each population (over all accepted models) -mean or sum ? 
weight.sum = vector('numeric',length=length(all_pops))
names(weight.sum)=all_pops
for (i in names(weight.sum)){
  if (i %in% true_pops){
    weight.sum[i]=sum(as.numeric(weight.mat.true[which(weight.mat.true[,1] ==i),2])) #could be mean instead of sum
  }
  else {weight.sum[i]=0}
}
#in case of sum weights - normalization is needed (range 0 - 1) 
weight.sum = (weight.sum-min(weight.sum))/(max(weight.sum)-min(weight.sum))


#adjacency matrix  -- all (unique)X all (unique) pops -- posa counts
adj.mat = matrix(0, nrow=length(all_pops), ncol=length(all_pops))
row.names(adj.mat)=all_pops
colnames(adj.mat)=row.names(adj.mat)

count.combs = function(x, adj.mat){
  v = unlist(strsplit(x,','))
  if (length(v)==1){
    adj.mat[v,v]=adj.mat[v,v]+1
  }
  else {
    y = combn(v,2)
    for (j in 1:ncol(y)){
      adj.mat[y[1,j],y[2,j]] = adj.mat[y[1,j],y[2,j]] +1
    }
  }
  return(adj.mat)
}
#apply the count.combs to all models
for (model in qpout_true$models){
  adj.mat = count.combs(model, adj.mat)
}

#plot the network
s = gsub('.tsv','',unlist(strsplit(data,'-'))[2])
network = graph_from_adjacency_matrix(adj.mat, weighted = TRUE,mode = 'undirected')

pdf(paste(s,'.pdf',sep = ''),width = 17, height=20)
plot(network,edge.width = E(network)$weight, vertex.size=weight.sum*10, main=paste(s,'(',nrow(qpout_true),' true models)',sep=''))
dev.off()




