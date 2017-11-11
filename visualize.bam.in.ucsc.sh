#!/bin/bash
############################################################
### Name: visualize.bam.in.ucsc.sh                       ###
### Author: Haiwang Yang (Oliver Lab)                    ###
### Contact: haiwang.yang@nih.gov; haiwangyang@gmail.com ###
### This script is to achieve the following functions    ###
### (0) First you need just some sorte.bam files (num    ###
###     < 10) in the current folder; then run this scrit ###
### (1) sorted.bam => sorted.bedGraph                    ###  
### (2) sorted.bedGraph => sorted.bigWig                 ###    
### (3) sorted.bam & sorted.bigWig to ftp                ###
###     Another upload.sh should be in this folder too   ###
### (4) output UCSC track code                           ###
############################################################
echo -ne "Checking for sorted.bam files in this folder\n";
n1=`ls *.sorted.bam | wc -l`

echo -ne "\tThere are "$n1" sorted.bam files:\n"
if [[ $n1 > 0 ]]; then for i in *.sorted.bam; do echo -ne "\t\t"$i"\n"; done; else echo -ne "Error! No sorted.bam files under this folder!\n"; fi

echo -ne "Generating batch.bam2bedGraph.swarm\n";
for i in *.sorted.bam; do echo "module load bedtools; cd "$PWD"; bedtools genomecov -bg -ibam $i -g /data/yangh13/annotation/dm3.genome | grep -v ERCC >${i/sorted.bam/sorted.bedGraph}"; done >batch.bam2bedGraph.swarm

echo -ne "Running batch.bam2bedGraph.swarm\n";  
swarm -R gpfs -t auto --autobundle -f batch.bam2bedGraph.swarm
echo "a temp file" > sw000.o

echo -ne "Waiting for all bedGraph files";
while true; 
do n2=`ls sw*.o | wc -l`;
    if [[ $n1 == `expr $n2 - 1` ]]; 
    then echo -ne "\n\tDone\n";
        rm sw*.[oe];
        echo -ne "Generating batch.bedGraph2bigWig.swarm\n"; 
        for i in *.sorted.bedGraph; 
        do echo -ne "module load ucsc; bedGraphToBigWig $i /data/yangh13/annotation/dm3.genome ${i/sorted.bedGraph/sorted.bw}\n"; 
        done >batch.bedGraph2bigWig.swarm;
        
        echo -ne "Running batch.bedGraph2bigWig.swarm\n";  
        swarm -R gpfs -t auto --autobundle -f batch.bedGraph2bigWig.swarm;
        echo "a temp file" > sw000.o;
        echo -ne "Waiting for all bigWig files";
        while true; 
        do n2=`ls sw*.o | wc -l`;
             if [[ $n1 == `expr $n2 - 1` ]];
             then echo -ne "\n\tDone\n";
                 rm sw*.[oe];
                 rm *.swarm;
                 echo -ne "Uploading sorted.bam and sorted.bw to ftp\n";
                 for filename in *.sorted.bam *.sorted.bam.bai *.sorted.bw;
                 do
                     ./upload.sh $filename
                 done;
                 echo -ne "Congrats! All files uploaded\n";
                 echo -ne "################################################\n";
                 echo -ne "### Now you can go to the website of UCSC    ###\n";
                 echo -ne "### http://genome.ucsc.edu/cgi-bin/hgGateway ###\n";
                 echo -ne "### Click [manage custom tracks]             ###\n";
                 echo -ne "### Click [add custom tracks]                ###\n";
                 echo -ne "### Copy and Paste the following codes       ###\n";
                 echo -ne "################################################\n";
                 echo -ne "\n";
                 for i in *.sorted.bam;
                 do
                     echo -ne "track type=bam visibility=dense name=\""${i/.sorted.bam/_reads}"\" bigDataUrl=ftp://helix.nih.gov/pub/temp/"$i"\n";
                 done;
                 for i in *.sorted.bw;
                 do
                     echo -ne "track type=bigWig visibility=full name=\""${i/.sorted.bw/_coverage}"\" bigDataUrl=ftp://helix.nih.gov/pub/temp/"$i"\n";
                 done;
                 break;
             else echo -ne ".";
             fi; sleep 5;
        done;
        break;
    else echo -ne ".";
    fi; sleep 5;
done;
