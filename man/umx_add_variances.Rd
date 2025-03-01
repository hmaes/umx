% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umx_add_variances}
\alias{umx_add_variances}
\title{umx_add_variances}
\usage{
umx_add_variances(model, add.to, values = NULL, free = NULL)
}
\arguments{
\item{model}{an \code{\link{mxModel}} to add variances to}

\item{add.to}{= List of variables to create variance for}

\item{free}{= List of variables to create variance for (default = NULL)}

\item{values}{= List of values (default = NULL)}
}
\value{
- \code{\link{mxModel}}
}
\description{
Convenience function to save the user specifying mxpaths adding variance to each variable
}
\examples{
require(OpenMx)
data(demoOneFactor)
m1 <- mxModel("One Factor", type = "RAM",
 manifestVars = names(demoOneFactor),
 latentVars = "g",
	mxPath(from = "g", to = names(demoOneFactor), values= .1),
	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
)
umx_show(m1, matrices = "S") # variables lack variance :-(
m1 = umx_add_variances(m1)
umx_show(m1, matrices = "S")
# Note: latent g has been treated like the manifests...
# umxFixLatents() will take care of this for you...
m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
umxSummary(m1)
}
\references{
- \url{https://github.com/tbates/umx}, \url{tbates.github.io}, \url{http://openmx.psyc.virginia.edu}
}
\seealso{
Other umx misc functions: \code{\link{demand}};
  \code{\link{umxEval}}; \code{\link{umx_apply}};
  \code{\link{umx_check_model}};
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
  \code{\link{umx_reorder}}; \code{\link{umx_rot}};
  \code{\link{umx_set_checkpointing}};
  \code{\link{umx_set_cores}};
  \code{\link{umx_set_optimizer}};
  \code{\link{umx_string_to_algebra}};
  \code{\link{umx_trim}}
}

