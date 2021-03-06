% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kernFunct.R
\name{qJacc}
\alias{qJacc}
\title{Quantitative Jaccard}
\usage{
qJacc(data)
}
\arguments{
\item{data}{A matrix or data.frame containing nondnegative values.}
}
\value{
The quantitative Jaccard kernel matrix
}
\description{
This function returns the quantitative Jaccard or min-max kernel, also known as Ruzicka similarity.
}
\examples{
example <- matrix(abs(rnorm(12)),nrow=4,ncol=3)
kmatrix <- qJacc(data=example)
}
