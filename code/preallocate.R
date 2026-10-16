# Pre allocation: When using loops, repeatedly resizing an object can be slow because R must repeatedly allocate memory. For example, a loop that extends a vector on every iteration makes R re-allocate memory each time. Try this:
NoPreallocFun <- function(x) {
    a <- vector() # empty vector
    for (i in 1:x) {
        a <- c(a, i) # concatenate
        print(a)
        print(object.size(a))
    }
}

system.time(NoPreallocFun(10))

#On the other hand, if you “pre-allocate” a vector that fits all the values, R doesn’t have to re-allocate memory each iteration. Here’s how you’d do that for the above case:
PreallocFun <- function(x) {
    a <- rep(NA, x) # pre-allocated vector
    for (i in 1:x) {
        a[i] <- i # assign
        print(a)
        print(object.size(a))
    }
}

system.time(PreallocFun(10))