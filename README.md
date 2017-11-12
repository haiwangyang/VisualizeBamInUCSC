# VisualizeBamInUCSC
* Visualize bam (and bigWig) in the UCSC browser
# Input
* sorted.bam files in the same folder
# Output
* genreate sorted.bedGraph from sorted.bam
* genreate sorted.bigWig from sorted.bedGraph
* upload sorted.bam and sorted.bigWig to ftp
* generate UCSC track code with ftp links that you can copy and paste to the following website
<br />http://genome.ucsc.edu/cgi-bin/hgGateway
# Dependent script
* upload.sh (in the same folder)
# Usage
* ./visualize.bam.in.ucsc.sh
