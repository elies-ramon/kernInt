% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kernFunct.R
\name{RBF}
\alias{RBF}
\title{RBF kernel}
\usage{
RBF(data, h = NULL)
}
\arguments{
\item{data}{A matrix or data.frame with real numbers}

\item{h}{Gamma hyerparameter. If NULL, the euclidian distances are returned}
}
\value{
The RBF kernel matrix
}
\description{
RBF kernel
}
\examples{
example <- matrix(rnorm(12),nrow=4,ncol=3)
kmatrix <- RBF(data=example)
}
