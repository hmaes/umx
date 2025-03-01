% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umxGetParameters}
\alias{umxGetParameters}
\title{umxGetParameters}
\usage{
umxGetParameters(inputTarget, regex = NA, free = NA, verbose = FALSE)
}
\arguments{
\item{inputTarget}{An object to get parameters from: could be a RAM \code{\link{mxModel}}}

\item{regex}{A regular expression to filter the labels defaults to NA - just returns all labels)}

\item{free}{A Boolean determining whether to return only free parameters.}

\item{verbose}{How much feedback to give}
}
\description{
Get the parameter labels from a model. Like \code{\link{omxGetParameters}},
but supercharged with regular expressions for more power and ease!
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
m1 = umxRun(m1)
umxGetParameters(m1)
m1 = umxRun(m1, setLabels = TRUE)
umxGetParameters(m1)
umxGetParameters(m1, free = TRUE) # only the free parameter
umxGetParameters(m1, free = FALSE) # only parameters which are fixed
\dontrun{
# Complex regex patterns
umxGetParameters(m2, regex = "S_r_[0-9]c_6", free = TRUE) # Column 6 of matrix "as"
}
}
\references{
- \url{http://www.github.com/tbates/umx}
}
\seealso{
Other umx model updating and comparison: \code{\link{umxEquate}}
}

