% Generated by roxygen2 (4.0.1): do not edit by hand
\name{logLik.MxModel}
\alias{logLik.MxModel}
\title{logLik.MxModel}
\usage{
\method{logLik}{MxModel}(model)
}
\arguments{
\item{model}{the \code{\link{mxModel}} from which to get the log likelihood}
}
\value{
- the log likelihood
}
\description{
Returns the log likelihood for an OpenMx model. This helper also
enables \code{\link{AIC}}(model); \code{\link{BIC}}(model).
}
\details{
hat-tip Andreas Brandmaier
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
m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
logLik(m1)
AIC(m1)
}
\references{
- \url{http://openmx.psyc.virginia.edu/thread/931#comment-4858}
}
\seealso{
- \code{\link{AIC}}, \code{\link{umxCompare}}

Other umx reporting: \code{\link{RMSEA.MxModel}};
  \code{\link{confint.MxModel}}, \code{\link{umxConfint}};
  \code{\link{plot.MxModel}}, \code{\link{umxPlot}};
  \code{\link{umxCI_boot}}; \code{\link{umxCI}};
  \code{\link{umxCompare}}; \code{\link{umxDescriptives}};
  \code{\link{umxFitIndices}}; \code{\link{umxSummary}}
}

