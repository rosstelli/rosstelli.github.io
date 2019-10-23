source("scripts/binfunction.R")
source("scripts/corr_script.R")


# Be able to read JSON files
library(Hmisc);
install.packages("rjson");
library(rjson);


filename <- "data/ProteinMonomer.json";
monomer_i <- fromJSON(file=filename);
filename <- "data/ProteinComplex.json";
complex_i <- fromJSON(file=filename);


#Load Protein Monomer Data
filename<-"data/protein-monomer.json";
monomer <- fromJSON(file=filename);
monomer_bins <- fillBins(monomer);


# Load RNA Data
# filename <- "data/Gene.json";
# gene_i <- fromJSON(file=filename);
filename <- "data/rna.json";
RNA <- fromJSON(file=filename);
RNA_bins <- fillBins(RNA);


# Load Protein-Complex Data
filename<-"data/protein-complex.json";
complex_ <- fromJSON(file=filename);
complex_bins <- fillBins(complex_);


# Create correlation matrices
RNA_corr <- getCorr(RNA_bins);
complex_corr <- getCorr(complex_bins);
monomer_corr <- getCorr(monomer_bins);

# Replace all NA's with > tmp2[is.na(tmp2)] <- FALSE;

# Create links with threshold and export
# use the following files for node-edge graphs
outputGraphJSON(RNA_corr, filename="output/RNA_graph_no_data.json"); # No data / color change
outputGraphJSON(RNA_corr, filename="output/RNA_graph1.json", data=RNA_bins);
outputGraphJSON(complex_corr, filename="output/complex_graph_no_data.json");
outputGraphJSON(complex_corr, filename="output/complex_graph1.json", data=complex_bins, threshold = 0.9);
outputGraphJSON(monomer_corr, filename="output/monomer_graph_no_data.json");
outputGraphJSON(monomer_corr, filename="output/monomer_graph1.json", data=monomer_bins, threshold = 0.985);
##########################################




# Get the names of the monomers
names_monomer <- rep("", times=length(monomer_i));
for (i in 1:length(monomer_i)) {
  names_monomer[i] <- (unlist(monomer_i[i])[1])
}

# Get the names of the complex
names_complex <- rep("", times=length(complex_i));
for (i in 1:length(complex_i)) {
  names_complex[i] <- (unlist(complex_i[i])[1])
}

# No names for RNA available, index names
names_RNA <- rep("RNA", time=length(RNA$data));
for (i in 1:length(names_RNA)) {
  names_RNA[i] <- paste(names_RNA[i], i, sep="");
}

# Create files for the hierarchical d3 visualization
outputEdgesJSON(monomer_corr,
                filename="output/monomer_hierarchial_edge.json",
                name=names_monomer,
                threshold = 0.985,
                NoUnconnectedNodes=TRUE);

outputEdgesJSON(complex_corr,
                filename="output/complex_hierarchial_edge.json",
                name=names_complex,
                threshold = 0.9,
                NoUnconnectedNodes=TRUE);

outputEdgesJSON(RNA_corr,
                filename="output/RNA_hierarchial_edge.json",
                name=names_RNA,
                threshold = 0.8,
                NoUnconnectedNodes=TRUE);




