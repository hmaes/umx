% Generated by roxygen2 (4.0.1): do not edit by hand
\name{residuals.MxModel}
\alias{residuals.MxModel}
\title{residuals.MxModel}
\usage{
\method{residuals}{MxModel}(model, digits = 2, suppress = NULL)
}
\arguments{
\item{model}{a (run) \code{\link{mxModel}} to get residuals from}

\item{digits}{rounding (default = 2)}

\item{suppress}{smallest deviation to print out (default = NULL = show all)}
}
\value{
- residual correlation matrix
}
\description{
Return the \code{\link{residuals}} from an OpenMx RAM model
}
\examples{
require(OpenMx)
data(demoOneFactor)
latents  = c("g")
manifests = names(demoOneFactor)
m1 <- mxModel("One Factor", type = "RAM",
	manifestVars = manifests, latentVars = latents,
	mxPath(from = latents, to = manifests),
	mxPath(from = manifests, arrows = 2),
	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
)
m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
residuals(m1)
residuals(m1, digits = 3)
residuals(m1, digits = 3, suppress = .005)
# residuals are returned as an invisible object you can capture in a variable
a = residuals(m1); a
}
\references{
- \url{https://github.com/tbates/umx}, \url{tbates.github.io}, \url{http://openmx.psyc.virginia.edu}
}
\seealso{
Other umx reporting functions: \code{\link{umxStandardizeModel}};
  \code{\link{umx_drop_ok}}; \code{\link{umx_get_time}};
  \code{\link{umx_show}}
}

