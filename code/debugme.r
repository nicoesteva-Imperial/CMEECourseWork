# Define nested functions
outer_function <- function(a) {
  middle_function(a)
}

middle_function <- function(b) {
  inner_function(b)
}

inner_function <- function(c) {
  # Intentional error: division by zero
  result <- c / d
  return(result)
}

# Call the outer function
outer_function(1)