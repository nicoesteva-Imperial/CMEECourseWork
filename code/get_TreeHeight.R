# This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
#
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# The heights of the tree, same units as "distance"

TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    #print(paste("Tree height is:", height))
  
    return (height)
}

# commandArgs() returns what was typed on the command line as text.
# trailingOnly = TRUE keeps only what comes after the script name.
# [1] takes the first item, e.g. "data/trees.csv".

args <- commandArgs(trailingOnly = TRUE)


# Exactly one argument required
if (length(args) == 0) {
    stop("No input file given. Usage: Rscript code/get_TreeHeight.R data/trees.csv")
}
if (length(args) > 1) {
    stop(paste("Expected 1 input file, got", length(args)))
}

infile <- args[1]

# File must exist
if (!file.exists(infile)) {
    stop(paste("File not found:", infile))
}

# Read the input
trees <- read.csv(infile)
 
 # Inspecting the data
print(head(trees))
str(trees)

# validation checks
if (!identical(names(trees), c("Species", "Distance.m", "Angle.degrees"))) {
    stop(paste(infile, "must have exactly the columns: Species, Distance.m, Angle.degrees"))
}

if (!((is.numeric(trees$Distance.m))&(is.numeric(trees$Angle.degrees)))) 
   {stop(paste(infile," must have Distance.m and Angle.degrees as numeric values"))
}


for (col in c ("Distance.m", "Angle.degrees")) {
    if (!all(is.finite(trees[[col]])))     {
        bad_rows <- which(!is.finite(trees[[col]]))# row numbers of the bad values
        stop(paste("Column", col, "contains NA, NaN or Inf values:",
                    paste(bad_rows, collapse = ",")))
    }
}


if (!all(trees$Distance.m > 0 & trees$Distance.m <= 100)) {
    stop("Distance.m must be greater than 0 and at most 100")
}


if (!all(trees$Angle.degrees > 0 & trees$Angle.degrees < 90)) {
    stop("Angle.degrees must be greater than 0 and less than 90")
}


# Calculate heights (vectorised over all trees)
trees$height_m <- TreeHeight(trees$Angle.degrees, trees$Distance.m)


# Output name from the input's basename: data/trees.csv -> results/trees_treeheights.csv
name <- tools::file_path_sans_ext(basename(infile))
outfile <- paste0("results/", name, "_treeheights.csv")

dir.create("results", showWarnings = FALSE)
write.csv(trees, outfile, row.names = FALSE, quote = FALSE)