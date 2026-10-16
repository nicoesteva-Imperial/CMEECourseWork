## Build a random matrix
M <- matrix(rnorm(100), 10, 10)

## Take the mean of each row
rowMeans <- apply(M, 1, mean)
print (rowMeans)

## Now the variance
rowVars <- apply(M, 1, var)
print (rowVars)

## By column
ColMeans <- apply(M, 2, mean)
print (ColMeans)