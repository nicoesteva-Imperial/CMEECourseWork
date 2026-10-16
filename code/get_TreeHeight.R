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
    print(paste("Tree height is:", height))
  
    return (height)
}

# commandArgs() returns what was typed on the command line as text.
# trailingOnly = TRUE keeps only what comes after the script name.
# [1] takes the first item, e.g. "../data/trees.csv".
infile <- commandArgs(trailingOnly = TRUE)[1]
 
# Read the file into a data frame (a table). No quotes around infile
# because it's a variable holding the path, not literal text.
data <- read.csv(infile)
 
# Pull out the angle and distance columns with $, calculate heights,
# and save them as a new column (assigning to a new name creates it).
data$Tree.Height.m <- TreeHeight(data$Angle.degrees, data$Distance.m) 

# Build the output name, reading inside out:
#   basename()           "../data/trees.csv" -> "trees.csv"  (drops folders)
#   file_path_sans_ext() "trees.csv"         -> "trees"      (drops .csv)
#   tools::              use this function from R's built-in tools package
name <- tools::file_path_sans_ext(basename(infile))
 
# paste0() glues text together with no spaces:
# "../results/" + "trees" + "_treeheights.csv"
outfile <- paste0("../results/", name, "_treeheights.csv")
 
# Save the table. row.names = FALSE stops R adding a row-number column.
write.csv(data, outfile, row.names = FALSE)
 


