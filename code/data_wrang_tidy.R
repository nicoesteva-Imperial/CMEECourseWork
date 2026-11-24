# Wrangle the Pound Hill dataset with dplyr and tidyr instead of reshape2.
# Run from the coursework project root with:
# Rscript code/data_wrang_tidy.R

# Load the data 

MyData <- as.matrix(read.csv("data/pound_hill_data.csv", header = FALSE))

MyMetaData <- read.csv(
  "data/pound_hill_meta_data.csv",
  header = TRUE,
  sep = ";"
)

# Inspect the data 

head(MyData)
dim(MyData)
str(MyData)
head(MyMetaData)

# Transpose so species become columns and sampled quadrats become rows.

MyData <- t(MyData)

head(MyData)
dim(MyData)

# Replace blanks with zero (observed absences).

MyData[MyData == ""] <- 0

# Convert the raw matrix to a data frame 

TempData <- as.data.frame(MyData[-1, ], stringsAsFactors = FALSE)

colnames(TempData) <- MyData[1, ]

rownames(TempData) <- NULL

# Convert from wide to long form 

MyWrangledData <- TempData |>
  tidyr::pivot_longer(
    cols = -c(Cultivation, Block, Plot, Quadrat),
    names_to = "Species",
    values_to = "Count"
  )

# TODO 1: Convert all five columns using one mutate() 

MyWrangledData <- MyWrangledData |>
  dplyr::mutate(
    Cultivation = as.factor(Cultivation),
    Block = as.factor(Block),
    Plot = as.factor(Plot),
    Quadrat = as.factor(Quadrat),
    Count = as.integer(Count)
  )

# Inspect the wrangled data 

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

# Save the derived table 

dir.create("results", showWarnings = FALSE)

# TODO 2: Save using a new filename.

write.csv(
  MyWrangledData,
  "results/pound_hill_long_tidy.csv",
  row.names = FALSE
)

# TODO 3: Check the dimensions and total count 

stopifnot(
  nrow(MyWrangledData) == 2419,
  ncol(MyWrangledData) == 6
)

# Check the total count.
# Replace the value below with the total obtained from data_wrang.R.

stopifnot(
  sum(MyWrangledData$Count) == 9733
)

