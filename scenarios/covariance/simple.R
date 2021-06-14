#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)<2) {
  stop("Usage: ./simple.R Ne m", call.=FALSE)
} 


popsize <- as.numeric(args[1])
m <- as.numeric(args[2])

d <- 1/(2*popsize)
pops <- c("p4","p5","p2", "p3")

c41 <- 850
c42 <- 100
c5  <- 100
c21 <- 500
c22 <- 100
c3  <- 600
cC  <- 500

f <- matrix(
  c( c41 + c42 , m*c41                            ,              0 ,       0,
     m*c41     , c5 + c41*m^2 + (c21+cC)*(1-m)^2      ,          (1-m)*(cC+c21),      cC,
     0         , (1-m)*(cC + c21)                         , cC + c21 + c22 ,      cC,
     0         , cC                               , cC             , cC + c3
  ), nrow = length(pops)
)

f <- d*f

rownames(f) <- pops
colnames(f) <- pops
print(paste0("Writing matrix for m=", m))
f
write.table(f, paste0("covariance.tab"),
            sep =  " ",
            row.names = TRUE,
            col.names = FALSE,
            quote = FALSE)

