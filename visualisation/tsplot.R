#!/usr/bin/Rscript
#This R script reads an FSL time series file and plots it. Arg 1 should be the ts and arg 2 should be the output file.
args=commandArgs(trailingOnly=TRUE)
ts = read.table(args[1])
png(args[2])
plot(scale(ts[,1], scale=FALSE) ~ as.numeric(rownames(ts)), type="o", pch="+", ylim=c(-300,300))
