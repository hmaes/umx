% Generated by roxygen2 (4.0.1): do not edit by hand
\name{umx_get_CI_as_APA_string}
\alias{umx_get_CI_as_APA_string}
\title{umx_get_CI_as_APA_string}
\usage{
umx_get_CI_as_APA_string(model, cellLabel, prefix = "top.", suffix = "_std",
  digits = 2, verbose = FALSE)
}
\arguments{
\item{model}{an \code{\link{mxModel}} to get CIs from}

\item{cellLabel}{the label of the cell to interogate for a CI, e.g. "ai_r1c1"}

\item{prefix}{This submodel to look in (i.e. "top.")}

\item{suffix}{The suffix for algebras ("_std")}

\item{digits}{= 2}

\item{verbose}{= FALSE}
}
\value{
- the CI string, e.g. ".73 [-.2, .98]"
}
\description{
Look up CIs for free parameters in a model, and return as APA-formatted text string
}
\examples{
\dontrun{
umx_get_CI_as_APA_string(fit_IP, cellLabel = "ai_r1c1", prefix = "top.", suffix = "_std")
}
}
\references{
- \url{https://github.com/tbates/umx}, \url{tbates.github.io}
}

