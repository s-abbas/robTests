% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers.R
\name{check_test_input}
\alias{check_test_input}
\title{Checks for input arguments}
\usage{
check_test_input(
  x,
  y,
  alternative,
  delta,
  method,
  scale,
  n.rep,
  na.rm,
  var.test,
  wobble,
  wobble.seed,
  gamma = NULL,
  psi = NULL,
  k = NULL,
  test.name
)
}
\arguments{
\item{x}{a (non-empty) numeric vector of data values.}

\item{y}{a (non-empty) numeric vector of data values.}

\item{alternative}{a character string specifying the alternative hypothesis,
must be one of "two.sided" (default), "greater" or "less".}

\item{delta}{a numeric value indicating the true difference in the location or scale parameter, depending
on whether the test should be performed for a difference in location or in scale.
The default is \code{delta = 0} for location test and \code{delta = 1} for scale test.}

\item{scale}{a character string specifying the scale estimator used for
standardization in the test statistic; must be one of \code{"S1"},
\code{"S2"}, \code{"S3"}, and \code{"S4"}.}

\item{n.rep}{an integer value specifying the number of random splits used to
calculate the randomization distribution if \code{method = "randomization"}.
This argument is ignored if \code{method = "permutation"} or \code{method = "asymptotic"}.
The default is \code{n.rep = 10000}.}

\item{na.rm}{logical value indicating whether NA values in x and y should be stripped before the computation proceeds.}

\item{var.test}{logical value testing whether the samples should be compared for a difference in scale.}

\item{wobble}{logical value indicating whether the sample should be checked for
duplicated values that can cause the scale estimate to be zero.
If such values are present, uniform noise is added to the sample,
see \code{\link[robTests]{wobble}}.
Only necessary for the permutation and randomization version of the test.
The default is \code{wobble = FALSE}.}

\item{wobble.seed}{integer value used as a seed for the random number
generation in case of \code{wobble = TRUE} or when
\code{var.test = TRUE} and one of the vectors \code{x} and
\code{y} contains zeros. When no seed is specified, it is
set randomly and printed in a warning The argument is ignored if
\code{var.test = FALSE} and \code{wobble = FALSE}.}

\item{gamma}{numeric value in [0, 0.5] specifying the fraction of observations to be
trimmed from each end of the sample before calculating the mean. Values
of trim outside that range are taken as the nearest endpoint.}

\item{psi}{kernel used for optimization.
Must be one of \code{"bisquare"}, \code{"hampel"} and \code{"huber"}.
The default is \code{"huber"}.}

\item{k}{tuning parameter(s) for the respective kernel function,
defaults to parameters implemented in \code{\link[robustbase:lmrob.control]{.Mpsi.tuning.default(psi)}}
in the package \href{https://cran.r-project.org/package=robustbase}{robustbase}.}

\item{test.name}{character string specifying the two-sample test for which
the helper function is used.}
}
\value{
An error message if a check fails.
}
\description{
\code{check_test_input} is a helper functions that contains checks for the
input arguments of the two-sample tests.
}
\details{
The two-sample tests in this package share similar arguments. To reduce the
amount of repetitive code, this function contains the argument checks so that
only \code{check_test_input} needs to be called within the functions for
the two-sample tests.

The scale estimators \code{"S1"} and \code{"S2"} can only be used in
combination with \code{test.name = "hl1_test"} or \code{test.name = "hl2_test"}.
The estimators \code{"S3"} and \code{"S4"} can only be used with
\code{test.name = "med_test"}.
}
\keyword{internal}
