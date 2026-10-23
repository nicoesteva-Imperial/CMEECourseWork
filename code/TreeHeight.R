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

# Load data (run from project root; paths relative to project root)
trees <- read.csv("data/trees.csv", header = TRUE)

# Inspecting the data
print(head(trees))
str(trees)

# validation checks
if (!all(c("Species", "Distance.m", "Angle.degrees") %in% names(trees))) 
   {stop("trees.csv must have the columns of Species, Distance.m, and Angle.degrees")
}

if (!((is.numeric(trees$Distance.m))&(is.numeric(trees$Angle.degrees)))) 
   {stop("trees.csv must have Distance.m and Angle.degrees as numeric values")
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


# Save results alongside original data
dir.create("results", showWarnings = FALSE)
write.csv(trees, "results/TreeHts.csv", row.names = FALSE, quote = FALSE)
