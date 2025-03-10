% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umx_is_MxMatrix}
\alias{umx_is_MxMatrix}
\title{umx_is_MxMatrix}
\usage{
umx_is_MxMatrix(obj)
}
\arguments{
\item{obj}{an object to be tested to see if it is an OpenMx \code{\link{mxMatrix}}}
}
\value{
- Boolean
}
\description{
Utility function returning a binary answer to the question "Is this an OpenMx mxMatrix?"
}
\examples{
x = mxMatrix(name="expMean", type="Full", nrow=3, ncol=3, free=T, values=.3, byrow=T)
if(umx_is_MxModel(x)){
	message("nice OpenMx matrix!")
}
}
\references{
- \url{http://www.github.com/tbates/umx}
}
\seealso{
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
  \code{\link{umx_is_MxModel}}; \code{\link{umx_is_cov}};
  \code{\link{umx_is_endogenous}};
  \code{\link{umx_is_exogenous}};
  \code{\link{umx_is_ordered}}; \code{\link{umx_msg}};
  \code{\link{umx_paste_names}}; \code{\link{umx_rename}};
  \code{\link{umx_reorder}}; \code{\link{umx_rot}};
  \code{\link{umx_set_checkpointing}};
  \code{\link{umx_set_cores}};
  \code{\link{umx_set_optimizer}};
  \code{\link{umx_string_to_algebra}};
  \code{\link{umx_trim}}
}

