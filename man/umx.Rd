% Generated by roxygen2 (4.0.1): do not edit by hand
\docType{package}
\name{umx}
\alias{umx}
\alias{umx-package}
\title{Helper functions for OpenMx}
\description{
umx allows you to more easily build, run, modify, and report models using OpenMx
with code. The core functions are linked below (see "family")
}
\details{
All the functions have explanatory examples, so use the help, even if you think it won't help :-)
Have a look, for example at \code{\link{umxRun}}
There's also a working example below and in demo(umx)
When I have a vignette, it will be: vignette("umx", package = "umx")

umx lives on github at present \url{http://github.com/tbates/umx}

There is a helpful blog at \url{http://tbates.github.io}

To install:
install.packages("devtools")
library("devtools")

install_github("tbates/umx")
library("umx")
}
\examples{
require("OpenMx")
require("umx")
data(demoOneFactor)
latents = c("G")
manifests = names(demoOneFactor)
m1 <- mxModel("One Factor", type = "RAM",
	manifestVars = manifests,
	latentVars  = latents,
	mxPath(from = latents, to = manifests),
	mxPath(from = manifests, arrows = 2),
	mxPath(from = latents  , arrows = 2, free = FALSE, values = 1),
	mxData(cov(demoOneFactor), type = "cov", numObs = nrow(demoOneFactor))
)

omxGetParameters(m1) # nb: By default, paths have no labels, and starts of 0

# With \\code{link{umxLabel}}, you can easily add informative and predictable labels to each free path (works with matrix style as well!)
# and use \\code{link{umxValues}}, to set sensible guesses for start values...
m1 = umxLabel(m1)
m1 = umxValues(m1)

# Re-run omxGetParameters...
omxGetParameters(m1) # Wow! Now your model has informative labels, & better starts

# umxRun the model (calculates saturated models for raw data, & repeats if the model is not code green)
m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE) # not needed given we've done this above. But you can see how umxRun enables 1-line setup and run

# Let's get some journal-ready fit information

umxSummary(m1)
umxSummary(m1, show = "std") #also display parameter estimates

# ==================
# = Model updating =
# ==================
# Can we set the loading of X5 on G to zero?
m2 = omxSetParameters(m1, labels = "G_to_x1", values = 0, free = FALSE, name = "no_effect_of_g_on_X5")
m2 = mxRun(m2)
# Compare the two models
umxCompare(m1, m2)

# Use umxReRun to do the same thing in 1-line
m2 = umxReRun(m1, "G_to_x1", name = "no_effect_of_g_on_X5", comparison = TRUE)

# =================================
# = Get some Confidence intervals =
# =================================

confint(m1, run = TRUE) # lots more to learn about ?confint.MxModel

# And make a Figure it dot format!
# If you have installed GraphViz, the next command will open it for you to see!

# umxPlot(m1, std = TRUE)
# Run this instead if you don't have GraphViz
plot(m1, std = TRUE, dotFilename = NA)
}
\references{
- \url{"http://www.github.com/tbates/umx"}
}
\seealso{
Other umx core functions: \code{\link{umxLabel}};
  \code{\link{umxReRun}}; \code{\link{umxRun}};
  \code{\link{umxValues}}; \code{\link{umx_cov_diag}};
  \code{\link{umx_get_checkpointing}}
}

