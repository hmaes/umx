% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umx_reorder}
\alias{umx_reorder}
\title{umx_reorder}
\usage{
umx_reorder(old, newOrder)
}
\arguments{
\item{old}{a square matrix of correlation or covariances to reorder}

\item{newOrder}{The order you'd like the variables to be in}
}
\value{
- the re-ordered (and/or resized) matrix
}
\description{
Reorder the variables in a correlation matrix. Can also remove one or more variables from a matrix using this function
}
\examples{
oldMatrix = cov(mtcars)
umx_reorder(oldMatrix, newOrder = c("mpg", "cyl", "disp")) # first 3
umx_reorder(oldMatrix, newOrder = c("hp", "disp", "cyl")) # subset and reordered
}
\references{
- \url{http://www.github.com/tbates/umx}
}
\seealso{
- \code{\link{umxLabel}}, \code{\link{umxRun}}, \code{\link{umxValues}}

Other umx misc functions: \code{\link{demand}};
  \code{\link{umxEval}}; \code{\link{umx_add_variances}};
  \code{\link{umx_apply}}; \code{\link{umx_check_model}};
  \code{\link{umx_check_names}}; \code{\link{umx_explode}};
  \code{\link{umx_get_bracket_addresses}};
  \code{\link{umx_get_cores}};
  \code{\link{umx_get_optimizer}};
  \code{\link{umx_has_CIs}};
  \code{\link{umx_has_been_run}};
  \code{\link{umx_has_means}};
  \code{\link{umx_has_square_brackets}};
  \code{\link{umx_is_MxMatrix}};
  \code{\link{umx_is_MxModel}}; \code{\link{umx_is_cov}};
  \code{\link{umx_is_endogenous}};
  \code{\link{umx_is_exogenous}};
  \code{\link{umx_is_ordered}}; \code{\link{umx_msg}};
  \code{\link{umx_paste_names}}; \code{\link{umx_rename}};
  \code{\link{umx_rot}};
  \code{\link{umx_set_checkpointing}};
  \code{\link{umx_set_cores}};
  \code{\link{umx_set_optimizer}};
  \code{\link{umx_string_to_algebra}};
  \code{\link{umx_trim}}
}

