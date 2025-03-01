% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umxRAM}
\alias{umxRAM}
\title{umxRAM}
\usage{
umxRAM(name, ..., exog.variances = FALSE, endog.variances = FALSE,
  fix = c("none", "latents", "firstLoadings"), latentVars = NULL,
  data = NULL, independent = NA, remove_unused_manifests = TRUE)
}
\arguments{
\item{name}{friendly name for the model}

\item{...}{A list of mxPaths or mxThreshold objects}

\item{exog.variances}{If TRUE, free variance parameters are added for exogenous variables that lack them (the default is FALSE).}

\item{endog.variances}{If TRUE, free error-variance parameters are added for any endogenous variables that lack them (default is FALSE).}

\item{fix}{Whether to fix latent or first paths to 1. Options are: c("none", "latents", "firstLoadings") (defaults to "none")}

\item{latentVars}{Latents you want in your model (defaults to NULL, in which case any variable not in the data is assumed to be a latent variable)}

\item{data}{the data for the model. Can be an \code{\link{mxData}} or a data.frame}

\item{remove_unused_manifests}{Whether to remove variables in the data to which no path makes reference (defaults to TRUE)}

\item{independent}{Whether the model is independent (default = NA)}
}
\value{
- \code{\link{mxModel}}
}
\description{
Making it as simple as possible to create a RAM model, without doing things invisible to the user.
}
\details{
Like mxModel, you list the theoretical causal paths. Unlike mxModel:
\enumerate{
\item{You can request creation of error variances using \code{endog.variances = TRUE} }
\item{You can request creation of variances for exogenous variables (using \code{exog.variances = TRUE})}
\item{For identification, you can request either \code{fix = "latents"} or \code{fix = "firstLoadings"}
to fix either the variance of latents or their first factor loading at 1.}
}
Additional conveniences:
\enumerate{
\item{type defaults to "RAM"}
\item{You don't need to list manifestVars (they are assumed to map onto names in the \code{mxData})}
\item{Any variables you mention that are not found in mxData are assumed to be latents}
}
}
\examples{
# umxRAM is like ggplot2::qplot(), you give the data in a data =  parameter
# A common error is to include data in the main list, a bit like saying lm(y~x + df) instead of lm(y~x, data=dd)...
# nb: unlike mxModel, umxRAM needs data at build time.

# 1. For convenience, list up the manifests you will be using
selVars = c("mpg", "wt", "disp")

# 2. Create an mxData object
myData = cov(mtcars[,selVars], use = "complete")
myCov = mxData(myData, type = "cov", numObs = nrow(mtcars) )

# 3. Write the model and paths (see ?umxPath for more options)
m1 = umxRAM("tim", data = myCov,
	umxPath(c("wt","disp"), to = "mpg"),
	umxPath(cov = c("wt", "disp")),
	umxPath(var = c("wt", "disp", "mpg"))
)

# 4. Run the model
m1 = mxRun(m1)

# 5. Print a nice summary
umxSummary(m1, show="std")

\dontrun{
# 6. Draw a nice path diagram (needs Graphviz)
plot(m1)
}
}
\references{
- \url{https://github.com/tbates/umx}, \url{tbates.github.io}
}

