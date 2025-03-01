% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umx_has_means}
\alias{umx_has_means}
\title{umx_has_means}
\usage{
umx_has_means(model)
}
\arguments{
\item{model}{The \code{\link{mxModel}} to check for presence of means}
}
\value{
- TRUE or FALSE
}
\description{
A utility function to return a binary answer to the question "does this \code{\link{mxModel}} have a means model?"
}
\examples{
require(OpenMx)
data(demoOneFactor)
latents  = c("G")
manifests = names(demoOneFactor)
m1 <- mxModel("One Factor", type = "RAM",
	manifestVars = manifests, latentVars = latents,
	mxPath(from = latents, to = manifests),
	mxPath(from = manifests, arrows = 2),
	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
)
umx_has_means(m1)
m1 <- mxModel(m1,
	mxPath(from = "one", to = manifests),
	mxData(demoOneFactor, type = "raw")
)
umx_has_means(m1)
m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
umx_has_means(m1)
}
\references{
- http://www.github.com/tbates/umx/
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

