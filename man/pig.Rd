% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pig.R
\docType{data}
\name{pig}
\alias{pig}
\title{Pig samples}
\format{
A list containing:
\describe{
  \item{asv}{Taxonomic abundances at the ASV level}
  \item{genera}{Taxonomic abundances at the Genera level}
  \item{antibiotic}{Yes if piglet got sick, No otherwise}
  \item{metadata}{Sampling day, ids of piglets and sows}
  \item{taxonomy}{Taxonomy for each of the ASV codes}
}
}
\usage{
pig
}
\description{
Gut taxonomic abundances (ASV and Genera level) of 153 piglets days 0, 3 and 7 post birth.
Some of the piglets suffered enteric disease between day 8 and the day of weaning and were provided with antibiotics.
}
\keyword{datasets}
