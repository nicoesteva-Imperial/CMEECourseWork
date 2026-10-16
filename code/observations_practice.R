# Load data: everything as text, blank cells become NA
observations <- read.csv(
  "data/bootcamp_observations/bootcamp_observations.csv",
  colClasses = "character", na.strings = "", check.names = FALSE
)
print(observations)

# Check 1: columns are site, date, count, in that order
check1 <- identical(names(observations), c("site", "date", "count"))

# Check 2: no missing site or date
check2 <- !any(is.na(observations$site)) & !any(is.na(observations$date))

# Check 3: counts are blank, or whole numbers >= 0
was_missing <- is.na(observations$count)
counts      <- as.numeric(observations$count)
bad_text    <- !was_missing & is.na(counts)
bad_number  <- !is.na(counts) & (counts < 0 | counts != round(counts))
check3 <- !any(bad_text | bad_number)

# Check 4: no repeated rows
check4 <- !any(duplicated(observations))

# Results (TRUE = pass)
cat("Columns correct:   ", check1, "\n")
cat("Site/date present: ", check2, "\n")
cat("Counts valid:      ", check3, "\n")
cat("No duplicates:     ", check4, "\n")

which(duplicated(observations))          # which row? -> 4
observations[!duplicated(observations), ] # data with the copy removed


#Claude answer:
read_observations <- function(path) {
  obs <- read.csv(path, colClasses = "character", na.strings = "", check.names = FALSE)

  # Rule 1: exact columns, in order
  if (!identical(names(obs), c("site", "date", "count"))) {
    stop("Columns must be site,date,count; found: ", paste(names(obs), collapse = ","))
  }

  # Rule 2: every row has a site and a date
  if (any(is.na(obs$site))) stop("Empty site in row(s): ", paste(which(is.na(obs$site)), collapse = ", "))
  if (any(is.na(obs$date))) stop("Empty date in row(s): ", paste(which(is.na(obs$date)), collapse = ", "))

  # Rule 3: non-missing counts must be non-negative integers
  present <- !is.na(obs$count)
  bad <- present & !grepl("^(0|[1-9][0-9]*)$", obs$count)
  if (any(bad)) {
    stop("Count is not a non-negative integer in row(s) ", paste(which(bad), collapse = ", "),
         ": ", paste(obs$count[bad], collapse = ", "))
  }

  obs$count <- as.integer(obs$count)   # safe to convert now
  obs
}

obs <- read_observations("data/bootcamp_observations/bootcamp_observations.csv")
str(obs)

  # tryCatch runs the code; if it errors, the error message is caught
  # instead of ending the script, so we can check WHY it failed.
  msg <- tryCatch(
    read_observations("data/bootcamp_observations/bootcamp_observations_invalid.csv"),
    error = function(e) conditionMessage(e)
  )
  cat("Invalid file rejected with:", msg, "\n")

# ===================================================================
# summarise_observations(data)
# Takes the validated observations and returns one row per site with:
#   total_known   = sum of the counts we actually have (NA if none)
#   missing_count = how many counts are missing
# ===================================================================

summarise_observations <- function(data) {
  # `data` is an empty box, filled with whatever table you pass in
  # when you call the function, e.g. summarise_observations(all_obs).

  # ---- Step 1 (Q1): remove exact duplicate rows ----
  # duplicated(data) goes down the rows asking "have I seen this exact row
  # already?" -> e.g. FALSE FALSE FALSE TRUE (row 4 repeats row 1).
  # ! flips it into "keep this row?"   -> TRUE  TRUE  TRUE  FALSE
  # data[ rows , columns ]: the filter goes BEFORE the comma because it picks
  # rows; nothing after the comma means "keep all columns".
  data <- data[!duplicated(data), ]

  # ---- Step 2 (Q5): a helper that handles ONE site's counts ----
  # x is an empty box that will hold one site's counts, e.g. c(2, NA).
  # is.na(x)       -> is each count empty?       e.g. FALSE TRUE
  # all(...)       -> are ALL of them empty?     e.g. FALSE
  # If every count is missing, we know nothing, so return NA (not 0:
  # 0 would falsely claim someone counted and found none).
  # Otherwise add up the known counts; na.rm = TRUE means
  # "remove the NAs first", so sum(c(2, NA), na.rm = TRUE) is 2, not NA.
  known_total <- function(x) {
    if (all(is.na(x))) {
      NA
    } else {
      sum(x, na.rm = TRUE)
    }
  }

  # ---- Step 3 (Q6): total_known for every site ----
  # tapply( what to look at , how to group it , what to do to each group )
  # It splits the counts by site, then hands each group to known_total:
  #   A: known_total(c(2, NA))  -> 2
  #   B: known_total(c(0))      -> 0
  #   C: known_total(c(NA, NA)) -> NA
  #   D: known_total(c(0))      -> 0
  totals <- tapply(data$count, data$site, known_total)

  # ---- Step 4 (Q3): missing_count for every site ----
  # is.na(data$count) turns each count into TRUE (missing) / FALSE (present).
  # sum() adds them up, and TRUE counts as 1, so the sum = number missing:
  #   A: FALSE TRUE -> 1    B: FALSE -> 0    C: TRUE TRUE -> 2    D: FALSE -> 0
  # No custom function needed here: sum() already does the job.
  missing <- tapply(is.na(data$count), data$site, sum)

  # ---- Step 5: build the results table ----
  # tapply returns its results labelled by site (A, B, C, D).
  # names(totals)  -> pulls those labels out to make the site column.
  # as.vector(...) -> strips the labels so each column is just plain values.
  # data.frame(...) puts the columns side by side, one row per site.
  # Because it's the last line, this table is what the function returns.
  data.frame(
    site          = names(totals),
    total_known   = as.vector(totals),
    missing_count = as.vector(missing)
  )
}


# ===================================================================
# Using it
# ===================================================================

# Load and validate both files with the function from yesterday.
ordinary <- read_observations("data/bootcamp_observations/bootcamp_observations.csv")
boundary <- read_observations("data/bootcamp_observations/bootcamp_observations_boundary.csv")

# Q2: rbind stacks the tables on top of each other (r = rows).
# Same columns in both, so you get one longer table (8 rows).
summary <- summarise_observations(rbind(ordinary, boundary))
print(summary)

# ---- stopifnot checks ----
# stopifnot() stops the script if any statement inside is not TRUE.
# If it prints nothing, every expected result matched.
# row("A") is a tiny helper that picks out site A's row from the summary.
# C uses is.na() because NA == NA gives NA (unknown), not TRUE.
row <- function(s) summary[summary$site == s, ]
stopifnot(
  row("A")$total_known == 2,   row("A")$missing_count == 1,
  row("B")$total_known == 0,   row("B")$missing_count == 0,
  is.na(row("C")$total_known), row("C")$missing_count == 2,
  row("D")$total_known == 0,   row("D")$missing_count == 0
)
cat("All summary checks passed.\n")

# ---- Figure: known totals per site ----
dir.create("results", showWarnings = FALSE)   # make results/ if it doesn't exist
png("results/known_totals.png", width = 800, height = 600)  # start drawing into a file

# barplot draws nothing for NA, so site C appears as a gap rather than a zero bar.
# ylim sets the y-axis range; na.rm = TRUE lets max() ignore C's NA.
bars <- barplot(summary$total_known, names.arg = summary$site,
                ylim = c(0, max(summary$total_known, na.rm = TRUE) + 1),
                xlab = "Site", ylab = "Total known count",
                main = "Known counts per site")

# Label the gap so nobody reads it as zero.
# bars holds each bar's x position; [all_missing] picks only C's.
all_missing <- is.na(summary$total_known)
text(bars[all_missing], 0.3, "no data\n(all counts missing)")

# Caption under the plot naming the all-missing site(s).
mtext(paste("Sites with every count missing (no bar, not zero):",
            paste(summary$site[all_missing], collapse = ", ")),
      side = 1, line = 4, cex = 0.9)

invisible(dev.off())   # close the file, which saves the image