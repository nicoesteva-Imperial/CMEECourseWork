# Poubd Hill Analysis
# Run from the coursework project root with:
# Rscript code/pound_hill_analysis.R

library(tidyr)
library(dplyr)
library(ggplot2)#

# Load the data ----------------------------------------------------------
# The first rows describe the sampling design, so do not use one as a header yet.
MyData <- as.matrix(read.csv("data/pound_hill_data.csv", header = FALSE))

# The metadata file does have a header and uses semicolons as separators.
MyMetaData <- read.csv("data/pound_hill_meta_data.csv", header = TRUE, sep = ";")

# Inspect the data -------------------------------------------------------
head(MyData)
dim(MyData)
str(MyData)
head(MyMetaData)

# Transpose so species become columns and sampled quadrats become rows.
MyData <- t(MyData) 
head(MyData)
dim(MyData)

# For this dataset, we have been told that blanks are observed absences.
# That knowledge is what allows us to record them as zero rather than NA.
print(MyMetaData[MyMetaData$FieldName == "BlankSpeciesCount", ])
MyData[MyData == ""] <- 0

# Convert the raw matrix to a data frame --------------------------------

TempData <- as.data.frame(MyData[-1, ], stringsAsFactors = FALSE)
colnames(TempData) <- MyData[1, ]
rownames(TempData) <- NULL


MyWrangledData <- TempData |>
    pivot_longer(
        cols = -c(Cultivation, Block, Plot, Quadrat),
        names_to = "Species",
        values_to = "Count"
    )

MyWrangledData$Cultivation <- as.factor(MyWrangledData$Cultivation)
MyWrangledData$Block <- as.factor(MyWrangledData$Block)
MyWrangledData$Plot <- as.factor(MyWrangledData$Plot)
MyWrangledData$Quadrat <- as.factor(MyWrangledData$Quadrat)
MyWrangledData$Count <- as.integer(MyWrangledData$Count)

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

# Save a derived table while leaving the raw files unchanged.
dir.create("results", showWarnings = FALSE)

# Checking the long table: the counts should be numeric, not missing, and not non-negative

if (!is.numeric(MyWrangledData$Count)) {
    stop("Count is not numeric")
}

if (any(is.na(MyWrangledData$Count))) {
    stop("Count contains NA values")
}

if (any(MyWrangledData$Count < 0)) {
    stop("Count conatins negative value")
}

# How many species, quadrats, and plots?
n_species <- n_distinct(MyWrangledData$Species)
n_quadrats <- nrow(distinct(MyWrangledData, Cultivation, Block, Plot, Quadrat))
n_plots <- nrow(distinct(MyWrangledData, Cultivation, Block, Plot))

cat("Species:", n_species, "Quadrats:", n_quadrats, "Plots:", n_plots, "/n")

# richness per quadrat (which is identified by all four labels together)
# richness is defined as the number of species with Count > 0 

QuadratRichness <- MyWrangledData |>
    group_by(Cultivation, Block, Plot, Quadrat) |>
    summarise (Richness = sum(Count>0), .groups = "drop")

print(QuadratRichness)
nrow(QuadratRichness)

# Averaging the quadrats within each plot to prevent plots with a higher quadrat count from having more influence
PlotRichness <- QuadratRichness |>
    group_by(Cultivation, Block, Plot) |>
    summarise(MeanRichness = mean(Richness), .groups = "drop")

if (nrow(PlotRichness) !=12) {
    stop(paste("Expected 12 plots, got", nrow(PlotRichness)))
}

print(PlotRichness)
write.csv(PlotRichness, "results/pound_hill_plot_richness.csv", row.names = FALSE)


#figure depicting plot-level mean richness by cultivation

p <- ggplot(PlotRichness, aes(x = Cultivation, y= MeanRichness)) +
    geom_point(size = 3, alpha = 0.7,
                position = position_jitter(width = 0.1, height = 0, seed = 1)) +
    stat_summary(fun = mean, geom = "crossbar", width = 0.4, colour = "grey40") +
    labs(x = "Cultivation month",
         y = "Mean species richness per quadrat (plot mean)",
         title = "Plant species richness at Pound Hill by cultivation timing") +
    theme_bw()

ggsave("results/pound_hill_plot_richness.pdf", p, width = 6, height = 4.5)

#Interpretation:
#Based on the plot created, the May cultivation timing has the highest mean 
# species richness, while March and October timings have similar mean species 
# richness, with march being slighlty higher. The variability between the 
# different timings is to be noted as the timings seem to have similar 
# range width of mean spcies richness (minimum of ~ 3.5 and max of ~4). However, 
# due to the small amount of plots per treatment (4 plots)  this is not enough
# to determine that timing is the sole source of mean species richness. 
# The plots could also be positioned differently geographically, so the range 
# width could be also due to the inherent ecological surroundings of the plot
# and less so with the timing.

# Quadrat level: sum all counts in each quadrat
QuadratAbundance <- MyWrangledData |>
    group_by(Cultivation, Block, Plot, Quadrat) |>
    summarise(Abundance = sum(Count), .groups = "drop")

# Plot level: mean quadrat abundance per plot
PlotAbundance <- QuadratAbundance |>
    group_by(Cultivation, Block, Plot) |>
    summarise(MeanAbundance = mean(Abundance), .groups = "drop")

if (nrow(PlotAbundance) != 12) {
    stop(paste("Expected 12 plots, got", nrow(PlotAbundance)))
}

print(PlotAbundance)
write.csv(PlotAbundance, "results/pound_hill_plot_abundance.csv", row.names = FALSE)

# Figure: same design as the richness plot
p_abund <- ggplot(PlotAbundance, aes(x = Cultivation, y = MeanAbundance)) +
    geom_point(size = 3, alpha = 0.7,
               position = position_jitter(width = 0.1, height = 0, seed = 1)) +
    stat_summary(fun = mean, geom = "crossbar", width = 0.4, colour = "grey40") +
    labs(x = "Cultivation month",
         y = "Mean number of individuals per quadrat (plot mean)",
         title = "Plant abundance at Pound Hill by cultivation timing")+
    theme_bw()

ggsave("results/pound_hill_plot_abundance.pdf", p_abund, width = 6, height = 4.5)