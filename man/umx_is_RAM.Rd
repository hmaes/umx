% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umx_is_RAM}
\alias{umx_is_RAM}
\title{umx_is_RAM}
\usage{
umx_is_RAM(obj)
}
\arguments{
\item{obj}{an object to be tested to see if it is an OpenMx RAM \code{\link{mxModel}}}
}
\value{
- Boolean
}
\description{
Utility function returning a binary answer to the question "Is this a RAM model?"
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
umxSummary(m1, show = "std")
if(umx_is_RAM(m1)){
	message("nice RAM model!")
}
if(!umx_is_RAM(m1)){
	msg("model must be a RAM model")
}
}
\references{
- \url{http://www.github.com/tbates/umx}
}
\seealso{
- \code{\link{mxModel}}

Other umx build functions: \code{\link{umxPath}};
  \code{\link{umx_add_std}};
  \code{\link{umx_fix_first_loadings}};
  \code{\link{umx_fix_latents}}
}

