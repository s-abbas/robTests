## ----------------------------------------------------------------------------
## Two-sample location test based on difference of M-estimators
## ----------------------------------------------------------------------------

#' @title Two sample location test based on M-estimators
#'
#' @description \code{m_test} performs a two-sample location test
#'              based on M-estimators.
#'
#' @template x
#' @template y
#' @template alternative
#' @template delta
#' @template method
#' @template psi
#' @template k_mest
#' @template n_rep
#' @template na_rm
#' @template var_test
#' @template wobble_seed_mtest
#' @template scaleTau2
#'
#' @details
#'
#' The test statistic for this test is based on the difference of the M-estimates
#' of location of \code{x} and \code{y}. We implemented three different psi-functions:
#' \code{huber},\code{hampel} and \code{bisquare}. The according tuning parameter(s) can
#' be set in the \code{k} argument of the function.

#' The estimate of the location difference is scaled by a pooled estimate for
#' the standard deviation. This estimate is based on the
#' tau scale estimator. The tau scale estimate is computed with the default parameter settings
#' of the function \code{\link[robustbase]{scaleTau2}}. These can be changed if necessary
#' by setting \code{c1} and \code{c2}.
#' More details are given in the vignettes \code{vignette{"robTests-vignette"}}
#' and \code{vignette{"mTest-vignette"}}.
#'
#' We offer three versions of the test: randomization, permutation and asymptotic.
#'
#' When computing the randomization distribution based on randomly drawn splits
#' with replacement, the function \code{\link[statmod]{permp}} \insertCite{PhiSmy10perm}{robTests}
#' is used to calculate the p-value. The psi function for the the M-estimate
#' is computed via the implementations in the package \code{\link[=Mpsi]{robustbase}}.
#'
#' For the asymptotic test, the distribution of the test statistic is approximated
#' by a standard normal distribution.
#' However, this assumption is only justified under the normality assumption. In
#' case of a non-normal distribution, the test might not keep the desired significance
#' level. The test keeps the level under several distributions as long as the
#' variance exists. However, under skewed distributions, it tends to be anti-conservative.
#' The test statistic can be corrected by a factor which has to be determined
#' individually for a specific distribution.
#'
#' For \code{var.test = TRUE}, the test compares the two samples for a difference in scale.
#' This is achieved by log-transforming the original observations so that a potential
#' scale difference appears as a location difference between the transformed samples;
#' see \insertCite{Fri12onli;textual}{robTests}. The sample should not contain zeros
#' to prevent problems with the necessary log-transformation. If it contains zeros,
#' uniform noise is added to all variables in order to remove zeros. A warning is
#' printed.
#'
#' If the sample has been modified because of zeros when \code{var.test = TRUE},
#' the modified samples can be retrieved using
#'
#' \code{set.seed(wobble.seed); wobble(x, y)}
#'
#' Both samples need to contain at least 5 non-missing values.
#'
#' @return
#' A list with class "\code{htest}" containing the following components:
#' \item{statistic}{the value of the test statistic.}
#' \item{parameter}{the degrees of freedom for the test statistic.}
#' \item{p.value}{the p-value for the test.}
#' \item{estimate}{the Huber M-estimates of \code{x} and \code{y}.}
#' \item{null.value}{the specified hypothesized value of the mean difference.}
#' \item{alternative}{a character string describing the alternative hypothesis.}
#' \item{method}{a character string indicating how the p-value was computed.}
#' \item{data.name}{a character string giving the names of the data.}
#'
#' @references
#'
#' \insertRef{Fri12onli}{robTests}
#'
#' \insertRef{MarZam02robu}{robTests}
#'
#' \insertRef{PhiSmy10perm}{robTests}
#'
#' @examples
#' ## Generate random samples
#' set.seed(108)
#' x <- rnorm(20); y <- rnorm(20)
#'
#' ## Asymptotic test based on Huber M-estimator
#' m_test(x, y, method = "asymptotic", psi = "huber")
#'
#' \dontrun{
#' ## Randomization test based on Hampel M-estimator with 1000 random permutations
#' ## drawn with replacement
#'
#' m_test(x, y, method = "randomization", n.rep = 1000, psi = "hampel")
#' }
#'
#' @export

m_test <- function(x, y, alternative = c("two.sided", "greater", "less"),
                   delta = ifelse(var.test, 1, 0),
                   method = c("asymptotic", "permutation", "randomization"),
                   psi = c("huber", "hampel", "bisquare"),
                   k = robustbase::.Mpsi.tuning.default(psi),
                   n.rep = 10000, na.rm = FALSE,
                   var.test = FALSE, wobble.seed = NULL, ...) {

  # Check input arguments ----
  psi <- match.arg(psi)
  check_test_input(x = x, y = y, alternative = alternative, delta = delta,
                   method = method, psi = psi, k = k, n.rep = n.rep,
                   na.rm = na.rm, var.test = var.test,
                   wobble.seed = wobble.seed, wobble = FALSE,
                   test.name = "m_test")

  # Extract names of data sets ----
  dname <- paste(deparse(substitute(x)), "and", deparse(substitute(y)))

  # Match 'alternative' ----
  # 'method' not matched because computation of p-value depends on sample sizes
  # if no value is specified by the user
  alternative <- match.arg(alternative)

  # Data preprocessing ----
  prep <- preprocess_data(x = x, y = y, delta = delta, na.rm = na.rm,
                          wobble = FALSE, wobble.seed = wobble.seed,
                          var.test = var.test)

  if (!all(is.na(prep))) {
    x <- prep$x
    y <- prep$y
    delta <- prep$delta
  } else {
    return(NA)
  }

  # Select method for computing the p-value ----
  method <- select_method(x = x, y = y, method = method, test.name = "m_test",
                          n.rep = n.rep)

  # Test decision ----

  # Test statistic and location estimates for both samples
  stats <- m_test_statistic(x, y + delta, psi = psi, k = k, ...)
  statistic <- stats$statistic
  estimates <- stats$estimates
  estimates[2] <- stats$estimates[2] - delta

  if (method %in% c("permutation", "randomization")) {
    # Test decision for permutation or randomization test
    n.rep <- min(choose(length(x) + length(y), length(x)), n.rep)
    distribution <- m_est_perm_distribution(x = x, y = y - delta, randomization = (method == "randomization"),
                                            n.rep = n.rep, psi = psi, k = k)
    p.value <- calc_perm_p_value(statistic, distribution, m = length(x), n = length(y),
                                 randomization = (method == "randomization"), n.rep = n.rep, alternative = alternative)
  } else if (method == "asymptotic") {
    # Test decision for asymptotic test
    p.value <- switch(alternative,
                      two.sided = 2 * stats::pnorm(abs(statistic), lower.tail = FALSE),
                      greater = stats::pnorm(statistic, lower.tail = FALSE),
                      less = stats::pnorm(statistic, lower.tail = TRUE)
    )
  }

  # Prepare output ----

  # Assign names to results
  if (var.test) {
    names(estimates) <- c("M-est. of log(x^2)", "M-est. of log(y^2)")
    names(delta) <- "ratio of variances"
    delta <- exp(delta)
  } else {
    names(estimates) <- c("M-est. of x", "M-est. of y")
    names(delta) <- "location shift"
  }

  names(statistic) <- ifelse(var.test, "S", "D")

  # Information on applied test
  if (method == "randomization") {
    method <- paste("Randomization test based on", paste0(toupper(substring(psi, 1, 1)), substring(psi, 2, nchar(psi))), " M-estimator ", "(", n.rep, "random permutations)")
  } else if (method == "permutation") {
    method <- paste("Exact permutation test based on", paste0(toupper(substring(psi, 1, 1)), substring(psi, 2, nchar(psi))), "M-estimator")
  } else method <- paste("Asymptotic test based on", paste0(toupper(substring(psi, 1, 1)), substring(psi, 2, nchar(psi))), "M-estimator")

  # Results
  res <- list(statistic = statistic, parameter = NULL, p.value = p.value,
              estimate = estimates, null.value = delta, alternative = alternative,
              method = method, data.name = dname)

  class(res) <- "htest"

  return(res)
}
