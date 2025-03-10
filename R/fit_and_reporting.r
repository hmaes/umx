# devtools::document("~/bin/umx"); devtools::install("~/bin/umx"); 
# setwd("~/bin/umx"); 
# devtools::build("~/bin/umx")
# devtools::check("~/bin/umx")
# devtools::release("~/bin/umx")
# devtools::load_all("~/bin/umx")
# devtools::dev_help("umxReportCIs")
# devtools::show_news("~/bin/umx")
# http://adv-r.had.co.nz/Philosophy.html
# https://github.com/hadley/devtools

# =============================
# = Fit and Reporting Helpers =
# =============================

#' umx_drop_ok
#'
#' Print a meaningful sentence about a model comparison. SHould be merged with umxCompare
#'
#' @param model1 the base code{\link{mxModel}}
#' @param model2 the nested code{\link{mxModel}}
#' @param text name of the thing being tested, i.e., "Extraversion" or "variances"
#' @return - 
#' @export
#' @family umx reporting functions
#' @references - \url{https://github.com/tbates/umx}, \url{tbates.github.io}
#' @examples
#' \dontrun{
#' model = umx_drop_ok(model)
#' }
umx_drop_ok <- function(model1, model2, text = "parameter") {
	a = mxCompare(model1, model2)
	if(a$diffdf[2] > 1){
		are = "are"
	}else{
		are = "is"
	}
	if(a$p[2] < .05){
		if(!is.null(text)){ print(paste0("The ", text, " ", are, " significant and should be kept (p = ", umx_APA_pval(a$p[2]), ")")) }
		return(FALSE)
	} else {
		if(!is.null(text)){ print(paste0("The ", text, " ", are, " non-significant and can be dropped (p = ", umx_APA_pval(a$p[2]), ")")) }
		return(TRUE)
	}
}

#' residuals.MxModel
#'
#' Return the \code{\link{residuals}} from an OpenMx RAM model
#'
#' @rdname residuals.MxModel
#' @param model a (run) \code{\link{mxModel}} to get residuals from
#' @param digits rounding (default = 2)
#' @param suppress smallest deviation to print out (default = NULL = show all)
#' @return - residual correlation matrix
#' @export
#' @export residuals.MxModel
#' @family umx reporting functions
#' @references - \url{https://github.com/tbates/umx}, \url{tbates.github.io}, \url{http://openmx.psyc.virginia.edu}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("g")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' residuals(m1)
#' residuals(m1, digits = 3)
#' residuals(m1, digits = 3, suppress = .005)
#' # residuals are returned as an invisible object you can capture in a variable
#' a = residuals(m1); a
residuals.MxModel <- function(model, digits = 2, suppress = NULL){
	umx_check_model(model, type = NULL, hasData = TRUE)
	expCov = umxExpCov(model, latents = FALSE)
	if(model@data@type == "raw"){
		obsCov = umxHetCor(model@data@observed)
	} else {
		obsCov = model@data@observed
	}
	resid = cov2cor(obsCov) - cov2cor(expCov)
	umx_print(data.frame(resid), digits = digits, zero.print = ".", suppress = suppress)
	if(is.null(suppress)){
		print("nb: You can zoom in on bad values with, e.g. suppress = .01, which will hide values smaller than this. Use digits = to round")
	}
	invisible(resid)
}

#' confint.MxModel
#'
#' Implements confidence interval function for OpenMx models.
#' Note: Currently requested CIs are added to existing CIs, and all are run, 
#' even if they alrady exist in the output. This might change in the future.
#'
#' @details Unlike \code{\link{confint}}, if parm is missing, all CIs requested will be added to the model, 
#' but (because these can take time to run) by default only CIs already computed will be reported.
#' 
#' CIs will be run only if run is TRUE, allowing this function to be used to add
#' CIs without automatically having to run them.
#' If parm is empty, and run = FALSE, a message will alert you to add run = TRUE. 
#' Even a few CIs can take too long to make running the default.
#'
#' @aliases umxConfint
#' @rdname confint.MxModel
#' @param object An \code{\link{mxModel}}, possibly already containing \code{\link{mxCI}}s that have been \code{\link{mxRun}} with intervals = TRUE))
#' @param parm	A specification of which parameters are to be given confidence intervals. Can be "existing", "all", or a vector of names.
#' @param level	The confidence level required (default = .95)
#' @param run Whether to run the model (defaults to FALSE)
#' @param showErrorcodes (default = FALSE)
#' @param ... Additional argument(s) for methods.
#' @export
#' @export confint.MxModel
#' @return - \code{\link{mxModel}}
#' @family umx reporting
#' @seealso - \code{\link[stats]{confint}}, \code{\link{mxCI}}, \code{\link{mxRun}}
#' @references - \url{http://www.github.com/tbates/umx}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' m2 = confint(m1) # default: CIs added, but user prompted to set run = TRUE
#' m2 = confint(m2, run = TRUE) # CIs run and reported
#' m1 = confint(m1, parm = "G_to_x1", run = TRUE) # Add CIs for asymmetric paths in RAM model, report them, save m1 with this CI added
#' m1 = confint(m1, parm = "A", run = TRUE) # Add CIs for asymmetric paths in RAM model, report them, save m1 with mxCIs added
#' confint(m1, parm = "existing") # request existing CIs (none added yet...)
#' 
confint.MxModel <- function(object, parm = list("existing", c("vector", "of", "names"), "default = add all"), level = 0.95, run = FALSE, showErrorcodes = FALSE, ...) {
	defaultParmString = list("existing", c("vector", "of", "names"), "default = add all")
	# 1. Add CIs if needed
	if (isTRUE(all.equal(parm, defaultParmString))) {
		if(umx_has_CIs(object, "intervals")) {
			# TODO add a count for the user
			message("Existing CIs Will be used (", length(object@intervals), " in total)")
		} else {
			message("Adding CIs for all free parameters")
			CIs_to_set = names(omxGetParameters(object, free = TRUE))
			object = mxModel(object, mxCI(CIs_to_set, interval = level))			
		}
	} else if(parm == "existing") {
		# check there are some in existence
		if(!umx_has_CIs(object, "intervals")) {
			message("This model has no CIs yet. Perhaps you wanted just confint(model, run = TRUE) to add and run CIs on all free parameters? Or set parm to a list of labels you'd like CIs? Also see help(mxCI)")
		}
	} else {
		# add requested CIs to model
		# TODO check that these exist
		object = mxModel(object, mxCI(parm, interval = level))
	}
	# 2. Run CIs if requested
	if(run) {
		object = mxRun(object, intervals = TRUE)
	}
	# 3. Report CIs if found in output
	if(!umx_has_CIs(object, "both") & run == FALSE) {
		message("Some CIs have been requested, but have not yet been run. Add ", omxQuotes("run = TRUE"), " to your confint() call to run them.\n",
		"To store the model run capture it from confint like this:\n",
		"m1 = confint(m1, run=TRUE)")
	} else {
		model_summary = summary(object)
		model_CIs = round(model_summary$CI, 3)
		model_CI_OK = object@output$confidenceIntervalCodes
		colnames(model_CI_OK) <- c("lbound Code", "ubound Code")
		model_CIs =	cbind(round(model_CIs, 3), model_CI_OK)
		print(model_CIs)
		npsolMessages <- list(
		'1' = 'The final iterate satisfies the optimality conditions to the accuracy requested, but the sequence of iterates has not yet converged. NPSOL was terminated because no further improvement could be made in the merit function (Mx status GREEN).',
		'2' = 'The linear constraints and bounds could not be satisfied. The problem has no feasible solution.',
		'3' = 'The nonlinear constraints and bounds could not be satisfied. The problem may have no feasible solution.',
		'4' = 'The major iteration limit was reached (Mx status BLUE).',
		'5' = 'not used',
		'6' = 'The model does not satisfy the first-order optimality conditions to the required accuracy, and no improved point for the merit function could be found during the final linesearch (Mx status RED)',
		'7' = 'The function derivates returned by funcon or funobj appear to be incorrect.',
		'8' = 'not used',
		'9' = 'An input parameter was invalid')
		if(any(model_CI_OK !=0) & showErrorcodes){
			codeList = c(model_CI_OK[,"lbound Code"], model_CI_OK[,"ubound Code"])
			relevantCodes = unique(codeList); relevantCodes = relevantCodes[relevantCodes !=0]
			for(i in relevantCodes) {
			   print(paste0(i, ": ", npsolMessages[i][[1]]))
			}
		}
	}
	invisible(object)
}

#' umxSummary
#'
#' Report the fit of a model in a compact form suitable for a journal. Emits a "warning" 
#' when model fit is worse than accepted criterion (TLI >= .95 and RMSEA <= .06; (Hu & Bentler, 1999; Yu, 2002).
#' 
#' notes on CIs and Identification
#' Note, the conventional standard errors reported by OpenMx are used to produce the CIs you see in umxSummary
#' These are used to derive confidence intervals based on the formula 95%CI = estimate +/- 1.96*SE)
#' 
#' Sometimes they appear NA. This often indicates a model which is not identified (see\url{http://davidakenny.net/cm/identify.htm}).
#' This can include empirical under-identification - for instance two factors
#' that are essentially identical in structure.
#' 
#' A signature of this would be paths estimated at or close to
#' zero. Fixing one or two of these to zero may fix the standard error calculation, 
#' and alleviate the need to estimate likelihood-based or bootstrap CIs
#' 
#' If factor loadings can flip sign and provide identical fit, this creates another form of 
#' under-identification and can break confidence interval estimation, but I think
#' Fixing a factor loading to 1 and estimating factor variances can help here
#'
#' @param model The \code{\link{mxModel}} whose fit will be reported
#' @param saturatedModels Saturated models if needed for fit indices (see example below: Only needed for raw data, and then not if you've run umxRun)
#' @param report The format for the output line or table (default is "line")
#' @param showEstimates What estimates to show. Options are c("none", "raw", "std", "both", "list of column names"). 
#' Default  is "none" (just shows the fit indices)
#' @param digits How many decimal places to report to (default = 2)
#' @param RMSEA_CI Whether to compute the CI on RMSEA (Defaults to F)
#' @param matrixAddresses Whether to show "matrix address" columns (Default = FALSE)
#' @param filter whether to show significant paths (SIG) or NS paths (NS) or all paths (ALL)
#' @family umx reporting
#' @seealso - \code{\link{mxCI}}, \code{\link{umxCI_boot}}, \code{\link{umxRun}}
#' @references - Hu, L., & Bentler, P. M. (1999). Cutoff criteria for fit indexes in covariance 
#'  structure analysis: Coventional criteria versus new alternatives. Structural Equation Modeling, 6, 1-55. 
#'
#'  - Yu, C.Y. (2002). Evaluating cutoff criteria of model fit indices for latent variable models
#'  with binary and continuous outcomes. University of California, Los Angeles, Los Angeles.
#'  Retrieved from \url{http://www.statmodel.com/download/Yudissertation.pdf}
#' \url{http://www.github.com/tbates/umx}
#' @export
#' @import OpenMx
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' umxSummary(m1, show = "std")
#' umxSummary(m1, show = "std", digits = 1)
#' \dontrun{
#' umxSummary(m1, report = "table")
#' umxSummary(m1, saturatedModels = umxSaturated(m1))
#' }
umxSummary <- function(model, saturatedModels = NULL, report = "line", showEstimates = c("none", "raw", "std", "both", "list of column names"), digits = 2, RMSEA_CI = FALSE, matrixAddresses = FALSE, filter = c("ALL","NS","SIG")){
	validValuesForshowEstimates = c("none", "raw", "std", "both", "list of column names")
	showEstimates = umx_default_option(showEstimates, validValuesForshowEstimates, check = TRUE)
	validValuesForFilter = c("ALL", "NS", "SIG")
	# TODO make table take lists of models...
	report = umx_default_option(report, c("line"))	
	filter = umx_default_option(filter, validValuesForFilter)	

	# if the filter is off default, the user must want something...
	if( filter != "ALL" & showEstimates == "none") {
		showEstimates = "std"
	}
	output <- model@output
	# Stop if there is no objective function
	if ( is.null(output) ) stop("Provided model has no objective function, and thus no output. mxRun(model) first")
	# stop if there is no output
	if ( length(output) < 1 ) stop("Provided model has no output. I can only standardize models that have been mxRun() first!")
	# saturatedModels = NULL
	if(is.null(saturatedModels)) {
		# saturatedModels not passed in from outside, so get them from the model
		modelSummary = OpenMx::summary(model)		
		if(is.null(model@data)){
			# # TODO model with no data - no saturated solution?
		} else if(is.na(modelSummary$SaturatedLikelihood)){
			message("There is no saturated likelihood: computing that now...")
			saturatedModels = umxSaturated(model)
			modelSummary = OpenMx::summary(model, SaturatedLikelihood = saturatedModels$Sat, IndependenceLikelihood = saturatedModels$Ind)
		}
	} else {
		modelSummary = OpenMx::summary(model, SaturatedLikelihood = saturatedModels$Sat, IndependenceLikelihood = saturatedModels$Ind)
	}

	# DisplayColumns
	if(showEstimates != "none"){
		if(packageVersion("OpenMx") > 1.5) {
			parameterTable = mxStandardizeRAMpaths(model, SE = TRUE)
			#                       name          label matrix  row  col     Raw.Value    Std.Value       Std.SE
			# 1 big_motor_low_mpg.A[1,2]    disp_to_mpg      A  mpg disp -4.085128e-02 -0.460887806 1.594295e-01
			names(parameterTable) <- c("label", "name", "matrix", "row", "col", "Estimate", "Std.Estimate", "Std.SE")
			parameterTable$Std.Error = NA
			# TODO: Rob to add "Std.Error" to mxStandardizeRAMpaths()
		}else{
			parameterTable = modelSummary$parameters			
		}
		if(matrixAddresses){
			nameing = c("name", "matrix", "row", "col")
		} else {
			nameing = c("name")
		}
		if("Std.Estimate" %in%  names(parameterTable)){
			if(length(showEstimates) > 1) {
				namesToShow = showEstimates
			}else if(showEstimates == "both") {
				namesToShow = c(nameing, "Estimate", "Std.Error", "Std.Estimate", "Std.SE")
			} else if(showEstimates == "std"){
				namesToShow = c(nameing, "Std.Estimate", "Std.SE", "CI")
			}else{ # must be raw
				namesToShow = c(nameing, "Estimate", "Std.Error")					
			}
		} else {
			namesToShow = c(nameing, "Estimate", "Std.Error")
		}
		# TODO update for 2.0
		if("CI" %in% namesToShow){
			parameterTable$sig = TRUE
			parameterTable$CI  = ""
			for(i in 1:dim(parameterTable)[1]) {
				# i = 1
				# x = summary(m1)$parameters
				# digits = 2
				est   = parameterTable[i, "Std.Estimate"]
				CI95  = parameterTable[i, "Std.SE"] * 1.96
				bounds = c(est - CI95, est + CI95)

				if(!any(is.na(bounds))){
					# protect cases with SE == NA from evaluation for significance
					if (any(bounds < 0) & any(bounds > 0)){
						parameterTable[i, "sig"] = FALSE
					}
					if(est < 0){
						parameterTable[i, "CI"] = paste0(round(est, digits), " [", round(est - CI95, digits), ", ", round(est + CI95, digits), "]")
					} else {
						parameterTable[i, "CI"] = paste0(round(est, digits), " [", round(est - CI95, digits), ", ", round(est + CI95, digits), "]")
					}
				}
			}
		}
		if(filter == "NS"){
			print(parameterTable[parameterTable$sig == FALSE, namesToShow], digits = digits, na.print = "", zero.print = "0", justify = "none")			
		}else if(filter == "SIG"){
			print(parameterTable[parameterTable$sig == TRUE, namesToShow], digits = digits, na.print = "", zero.print = "0", justify = "none")
		}else{
			print(parameterTable[,namesToShow], digits = digits, na.print = "", zero.print = "0", justify = "none")			
		}
	} else {
		message("For estimates, add showEstimates = 'raw' 'std' or 'both")
	}
	with(modelSummary, {
		if(!is.finite(TLI)){
			TLI_OK = "OK"
		} else {
			if(TLI > .95) {
				TLI_OK = "OK"
				} else {
					TLI_OK = "bad"
				}
			}
			if(!is.finite(RMSEA)) {
				RMSEA_OK = "OK"
			} else {
				if(RMSEA < .06){
				RMSEA_OK = "OK"
				} else {
					RMSEA_OK = "bad"
				}
			}
			if(report == "table"){
				x = data.frame(cbind(model@name, round(Chi,2), formatC(p, format="g"), round(CFI,3), round(TLI,3), round(RMSEA, 3)))
				names(x) = c("model","\u03C7","p","CFI", "TLI","RMSEA") # \u03A7 is unicode for chi
				print(x)
			} else {
				if(RMSEA_CI){
					RMSEA_CI = RMSEA(model)$txt
				} else {
					RMSEA_CI = paste0("RMSEA = ", round(RMSEA, 3))
				}
				x = paste0(
					"\u03C7\u00B2(", degreesOfFreedom, ") = ", round(Chi, 2), # was A7
					", p "      , umx_APA_pval(p, .001, 3),
					"; CFI = "  , round(CFI, 3),
					"; TLI = "  , round(TLI, 3),
					"; ", RMSEA_CI
					)
				print(x)
				if(TLI_OK != "OK"){
					message("TLI is worse than desired")
				}
				if(RMSEA_OK != "OK"){
					message("RMSEA is worse than desired")
				}
			}
	})
	
	if(!is.null(model@output$confidenceIntervals)){
		print(model@output$confidenceIntervals)
	}
}

#' umxCompare
#'
#' umxCompare compares two or more \code{\link{mxModel}}s. If you leave comparison blank, it will just give fit info for the base model
#'
#' @param base The base \code{\link{mxModel}} for comparison
#' @param comparison The model (or list of models) which will be compared for fit with the base model (can be empty)
#' @param all Whether to make all possible comparisons if there is more than one base model (defaults to T)
#' @param digits rounding for p etc.
#' @param report Optionally add sentences for inclusion inline in a paper (report= 2)
#' and output to an html table which will open your default browser (report = 3).
#' (This is handy for getting tables into Word, markdown, and other text systems!)
#' @family umx reporting
#' @seealso - \code{\link{mxCompare}}, \code{\link{umxSummary}}, \code{\link{umxRun}},
#' @references - \url{http://www.github.com/tbates/umx/}
#' @family umx reporting
#' @export
#' @import OpenMx
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' m2 = umxReRun(m1, update = "G_to_x2", name = "drop_path_2_x2")
#' umxCompare(m1, m2)
#' mxCompare(m1, m2) # what OpenMx gives by default
#' umxCompare(m1, m2, report = 2) # Add English-sentence descriptions
#' umxCompare(m1, m2, report = 3) # Open table in browser
#' m3 = umxReRun(m2, update = "G_to_x3", name = "drop_path_2_x2_and_3")
#' umxCompare(m1, c(m2, m3))
#' umxCompare(c(m1, m2), c(m2, m3), all = TRUE)
umxCompare <- function(base = NULL, comparison = NULL, all = TRUE, digits = 3, report = 1) {
	if(is.null(comparison)){
		comparison <- base
	} else if (is.null(base)) {
		stop("You must provide at least a base model for umxCompare")
	}
	tableOut  = OpenMx::mxCompare(base = base, comparison = comparison, all = all)

	# | 1       |    2          | 3  | 4        | 5   | 6        | 7        | 8      | 9    |
	# | base    | comparison    | ep | minus2LL | df  | AIC      | diffLL   | diffdf | p    |
	# | twinSat | <NA>          | 13 | 333.0781 | 149 | 35.07809 | NA       | NA     | NA   |
	# | twinSat | betaSetToZero | 10 | 351.6486 | 152 | 47.64858 | 18.57049 | 3      | 0.01 |

	# tableOut  = format(tableOut, scientific = FALSE, digits = digits)
	tablePub  = tableOut[, c("comparison", "ep", "diffLL"      , "diffdf"    , "p", "AIC", "base")]
	names(tablePub)     <- c("Model"     , "EP", "&Delta; -2LL", "&Delta; df", "p", "AIC", "Compare with Model")
	# Fix problem where base model has compare set to its own name, and name set to NA
	tablePub[1, "Model"] = tablePub[1, "Compare with Model"] 
	tablePub[1, "Compare with Model"] = NA
	# digits=3
	tablePub[,"p"] = umx_APA_pval(tablePub[, "p"], min = (1/ 10^digits), rounding = digits, addComparison = NA)
	# c("1: Comparison", "2: Base", "3: EP", "4: AIC", "5: &Delta; -2LL", "6: &Delta; df", "7: p")
	# addText = 1
	if(report > 1){
		n_rows = dim(tablePub)[1]
		for (i in 1:n_rows) {
			if(!is.na(tablePub[i, "p"])){
				if(tableOut[i, 9] < .05){
					did_didnot = ". This caused a significant loss of fit "
				} else {
					did_didnot = ". This did not lower fit significantly"
				}
				message(
				"The hypothesis that ", tablePub[i,"Model"], 
				" was tested by dropping ", tablePub[i,"Model"],
				" from ", tablePub[i,"Compare with Model"], 
				did_didnot, 
				"(χ²(", tablePub[i, 4], ") = ", round(tablePub[i, 3], 2),
				", p = ", tablePub[i,"p"], ")."
				)
			}
		}
	}
	
	if(report == 3){
		R2HTML::HTML(tablePub, file = "tmp.html", Border = 0, append = FALSE, sortableDF = TRUE); system(paste0("open ", "tmp.html"))
	} else {
		umx_print(tablePub)
		# R2HTML::print(tableOut, output = output, rowlabel = "")
	}
	invisible(tablePub)
	
	# " em \u2013 dash"
   # Delta (U+0394)
   # &chi;
 	# "Chi \u03A7"
	# "chi \u03C7"
	# if(export){
	# 	fName= "Model.Fitting.xls"
	# 	write.table(tableOut,fName, row.names = FALSE,sep = "\t", fileEncoding="UTF-8") # macroman UTF-8 UTF-16LE
	# 	system(paste("open", fName));
	# }
}

#' umxCI
#'
#' umxCI adds mxCI() calls for all free parameters in a model, 
#' runs the CIs, and reports a neat summary.
#'
#' This function also reports any problems computing a CI. The codes are standard OpenMx errors and warnings
#' \itemize{
#' \item 1: The final iterate satisfies the optimality conditions to the accuracy requested, but the sequence of iterates has not yet converged. NPSOL was terminated because no further improvement could be made in the merit function (Mx status GREEN)
#' \item 2: The linear constraints and bounds could not be satisfied. The problem has no feasible solution.
#' \item 3: The nonlinear constraints and bounds could not be satisfied. The problem may have no feasible solution.
#' \item 4: The major iteration limit was reached (Mx status BLUE).
#' \item 6: The model does not satisfy the first-order optimality conditions to the required accuracy, and no improved point for the merit function could be found during the final linesearch (Mx status RED)
#' \item 7: The function derivates returned by funcon or funobj appear to be incorrect.
#' \item 9: An input parameter was invalid
#' }
#' 
#' @param model The \code{\link{mxModel}} you wish to report \code{\link{mxCI}}s on
#' @param addCIs Whether or not to add mxCIs if none are found (defaults to TRUE)
#' @param runCIs Whether or not to compute the CIs. Valid values = "no", "yes", "if necessary".                                                  
#' @param showErrorcodes Whether to show errors (TRUE)                                              
#' @details If runCIs is FALSE, the function simply adds CIs to be computed and returns the model.
#' @return - \code{\link{mxModel}}
#' @family umx reporting
#' @seealso - \code{\link{mxCI}}, \code{\link{umxLabel}}, \code{\link{umxRun}}
#' @references - http://www.github.com/tbates/umx/
#' @export
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' umxCI(m1)
#' \dontrun{
#' umxCI(model, addCIs = TRUE) # add Cis for all free parameters if not present
#' umxCI(model, runCIs = "yes") # force update of CIs
#' umxCI(model, runCIs = "if necessary") # don't force update of CIs, but if they were just added, then calculate them
#' umxCI(model, runCIs = "no") # just add the mxCI code to the model, don't run them
#' }

umxCI <- function(model = NULL, addCIs = TRUE, runCIs = "if necessary", showErrorcodes = TRUE) {
	# TODO add code to not-run CIs
	# TODO superceed this with confint? just need parameters to hold the 95% etc...
	message("### CIs for model ", model@name)
	if(addCIs){
		CIs   = names(omxGetParameters(model, free= TRUE))
		model = mxModel(model, mxCI(CIs))
	}
    
	if(tolower(runCIs) == "yes" | (!umx_has_CIs(model) & tolower(runCIs) != "no")) {
		model = mxRun(model, intervals = TRUE)
	}

	if(umx_has_CIs(model)){
		confint(model, showErrorcodes = showErrorcodes)
		# model_summary = summary(model)
		# model_CIs = round(model_summary$CI, 3)
		# model_CI_OK = model@output$confidenceIntervalCodes
		# colnames(model_CI_OK) <- c("lbound Code", "ubound Code")
		# model_CIs =	cbind(round(model_CIs, 3), model_CI_OK)
		# print(model_CIs)
		# npsolMessages <- list(
		# '1' = 'The final iterate satisfies the optimality conditions to the accuracy requested, but the sequence of iterates has not yet converged. NPSOL was terminated because no further improvement could be made in the merit function (Mx status GREEN).',
		# '2' = 'The linear constraints and bounds could not be satisfied. The problem has no feasible solution.',
		# '3' = 'The nonlinear constraints and bounds could not be satisfied. The problem may have no feasible solution.',
		# '4' = 'The major iteration limit was reached (Mx status BLUE).',
		# '5' = 'not used',
		# '6' = 'The model does not satisfy the first-order optimality conditions to the required accuracy, and no improved point for the merit function could be found during the final linesearch (Mx status RED)',
		# '7' = 'The function derivates returned by funcon or funobj appear to be incorrect.',
		# '8' = 'not used',
		# '9' = 'An input parameter was invalid')
		# if(any(model_CI_OK !=0) & showErrorcodes){
		# 	codeList = c(model_CI_OK[,"lbound Code"], model_CI_OK[,"ubound Code"])
		# 	relevantCodes = unique(codeList); relevantCodes = relevantCodes[relevantCodes !=0]
		# 	for(i in relevantCodes) {
		# 	   print(paste0(i, ": ", npsolMessages[i][[1]]))
		# 	}
		# }
	}
	invisible(model)
}

#' umxCI_boot
#'
#' Compute boot-strapped Confidence Intervals for parameters in an \code{\link{mxModel}}
#' The function creates a sampling distribution for parameters by repeatedly drawing samples
#' with replacement from your data and then computing the statistic for each redrawn sample.
#' @param model is an optimized mxModel
#' @param rawData is the raw data matrix used to estimate model
#' @param type is the kind of bootstrap you want to run. "par.expected" and "par.observed" 
#' use parametric Monte Carlo bootstrapping based on your expected and observed covariance matrices, respectively.
#' "empirical" uses empirical bootstrapping based on rawData.
#' @param std specifies whether you want CIs for unstandardized or standardized parameters (default: std = TRUE)
#' @param rep is the number of bootstrap samples to compute (default = 1000).
#' @param conf is the confidence value (default = 95)
#' @param dat specifies whether you want to store the bootstrapped data in the output (useful for multiple analyses, such as mediation analysis)
#' @param digits rounding precision
#' @return - expected covariance matrix
#' @export
#' @examples
#' \dontrun{
#' 	require(OpenMx)
#' 	data(demoOneFactor)
#' 	latents  = c("G")
#' 	manifests = names(demoOneFactor)
#' 	m1 <- mxModel("One Factor", type = "RAM", 
#' 		manifestVars = manifests, latentVars = latents, 
#' 		mxPath(from = latents, to = manifests),
#' 		mxPath(from = manifests, arrows = 2),
#' 		mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 		mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' 	)
#' 	m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' 	umxCI_boot(m1, type = "par.expected")
#'}
#' @references - \url{http://openmx.psyc.virginia.edu/thread/2598}
#' Original written by \url{http://openmx.psyc.virginia.edu/users/bwiernik}
#' @seealso - \code{\link{umxExpMeans}}, \code{\link{umxExpCov}}
#' @family umx reporting
umxCI_boot <- function(model, rawData = NULL, type = c("par.expected", "par.observed", "empirical"), std = TRUE, rep = 1000, conf = 95, dat = FALSE, digits = 3) {
	require(MASS); require(OpenMx); require(umx)
	type = umx_default_option(type, c("par.expected", "par.observed", "empirical"))
	if(type == "par.expected") {
		exp = umxExpCov(model, latents = FALSE)
	} else if(type == "par.observed") {
		if(model$data@type == "raw") {
			exp = var(mxEval(data, model))
		} else { 
			if(model$data@type == "sscp") {
				exp = mxEval(data, model) / (model$data@numObs - 1)
			} else {
				exp = mxEval(data, model)
			}
		}
	}
	N = round(model@data@numObs)
	pard = t(data.frame("mod" = summary(model)$parameters[, 5 + 2 * std], row.names = summary(model)$parameters[, 1]))
	pb   = txtProgressBar(min = 0, max = rep, label = "Computing confidence intervals", style = 3)
	#####
	if(type == "empirical") {
		if(length(rawData) == 0) {
			if(model$data@type == "raw"){
				rawData = mxEval(data, model)
			} else {
				stop("No raw data supplied for empirical bootstrap.")	
			}
		}
		for(i in 1:rep){
			bsample.i = sample.int(N, size = N, replace = TRUE)
			bsample   = var(rawData[bsample.i, ])
			mod       = mxRun(mxModel(model, mxData(observed = bsample, type = "cov", numObs = N)), silent = TRUE)
			pard      = rbind(pard, summary(mod)$parameters[, 5 + 2*std])
			rownames(pard)[nrow(pard)] = i
			setTxtProgressBar(pb, i)
		}
	} else {
		for(i in 1:rep){
			bsample = var(MASS::mvrnorm(N, rep(0, nrow(exp)), exp))
			mod     = mxRun(mxModel(model, mxData(observed = bsample, type = "cov", numObs = N)), silent = TRUE)
			pard    = rbind(pard, summary(mod)$parameters[, 5 + 2 * std])
			rownames(pard)[nrow(pard)] = i
			setTxtProgressBar(pb, i)
		}
	}
	low = (1-conf/100)/2
	upp = ((1-conf/100)/2) + (conf/100)
	LL  = apply(pard, 2, FUN = quantile, probs = low) #lower limit of confidence interval
	UL  = apply(pard, 2, FUN = quantile, probs = upp) #upper quantile for confidence interval
	LL4 = round(LL, 4)
	UL4 = round(UL, 4)
	ci  = cbind(LL4, UL4)
	colnames(ci) = c(paste((low*100), "%", sep = ""), paste((upp*100), "%", sep = ""))
	p = summary(model)$parameters[, c(1, 2, 3, 4, c(5:6 + 2*std))]
	cols <- sapply(p, is.numeric)
	p[, cols] <- round(p[,cols], digits) 
	
	if(dat) {
		return(list("Type" = type, "bootdat" = data.frame(pard), "CI" = cbind(p, ci)))
	} else {
		return(list("CI" = cbind(p, ci)))
	}
}

#' umxSaturated
#'
#' Computes the saturated and independence forms of a RAM model (needed to return most 
#' fit statistics when using raw data). umxRun calls this automagically.
#'
#' @param model an \code{\link{mxModel}} to get independence and saturated fits to
#' @param evaluate FALSE
#' @param verbose How much feedback to give.
#' @return - A list of the saturated and independence models, from which fits can be extracted
#' @export
#' @family umx build functions, umx reporting functions
#' @seealso - \code{\link{umxSummary}}, \code{\link{umxRun}}
#' @references - \url{http://www.github.com/tbates/umx}
#' @examples
#' \dontrun{
#' model_sat = umxSaturated(model)
#' summary(model, SaturatedLikelihood = model_sat$Sat, IndependenceLikelihood = model_sat$Ind)
#' }
umxSaturated <- function(model, evaluate = TRUE, verbose = TRUE) {
	# TODO: Update to omxSaturated() and omxIndependenceModel()
	# TODO: Update IndependenceModel to analytic form
	if (!(isS4(model) && is(model, "MxModel"))) {
		stop("'model' must be an mxModel")
	}

	if (length(model@submodels)>0) {
		stop("Cannot yet handle submodels")
	}
	if(! model@data@type == "raw"){
		stop("You don't need to run me for cov or cor data - only raw")
	}
	theData = model@data@observed
	if (is.null(theData)) {
		stop("'model' does not contain any data")
	}
	manifests           = model@manifestVars
	nVar                = length(manifests)
	dataMeans           = colMeans(theData, na.rm = TRUE)
	meansLabels         = paste("mean", 1:nVar, sep = "")
	covData             = cov(theData, use = "pairwise.complete.obs")
	factorLoadingStarts = t(chol(covData))
	independenceStarts  = diag(covData)
	loadingsLabels      = paste0("F", 1:nVar, "loading")

	# Set latents to a new set of 1 per manifest
	# Set S matrix to an Identity matrix (i.e., variance fixed@1)
	# Set A matrix to a Cholesky, manifests by manifests in size, free to be estimated 
	# TODO: start the cholesky at the cov values
	m2 <- mxModel("sat",
    	# variances set at 1
		# mxMatrix(name = "factorVariances", type="Iden" , nrow = nVar, ncol = nVar), # Bunch of Ones on the diagonal
	    # Bunch of Zeros
		mxMatrix(name = "factorMeans"   , type = "Zero" , nrow = 1   , ncol = nVar), 
	    mxMatrix(name = "factorLoadings", type = "Lower", nrow = nVar, ncol = nVar, free = TRUE, values = factorLoadingStarts), 
		# labels = loadingsLabels),
	    mxAlgebra(name = "expCov", expression = factorLoadings %*% t(factorLoadings)),

	    mxMatrix(name = "expMean", type = "Full", nrow = 1, ncol = nVar, values = dataMeans, free = TRUE, labels = meansLabels),
	    mxFIMLObjective(covariance = "expCov", means = "expMean", dimnames = manifests),
	    mxData(theData, type = "raw")
	)
	m3 <- mxModel("independence",
	    # TODO: slightly inefficient, as this has an analytic solution
	    mxMatrix(name = "variableLoadings" , type="Diag", nrow = nVar, ncol = nVar, free = TRUE, values = independenceStarts), 
		# labels = loadingsLabels),
	    mxAlgebra(name = "expCov", expression = variableLoadings %*% t(variableLoadings)),
	    mxMatrix(name  = "expMean", type = "Full", nrow = 1, ncol = nVar, values = dataMeans, free = TRUE, labels = meansLabels),
	    mxFIMLObjective(covariance = "expCov", means = "expMean", dimnames = manifests),
	    mxData(theData, type = "raw")
	)
	m2 <- mxOption(m2, "Calculate Hessian", "No")
	m2 <- mxOption(m2, "Standard Errors"  , "No")
	m3 <- mxOption(m3, "Calculate Hessian", "No")
	m3 <- mxOption(m3, "Standard Errors"  , "No")
	if(evaluate) {
		m2 = mxRun(m2)
		m3 = mxRun(m3)
	}
	if(verbose) {
		message("note: umxRun() will compute saturated for you...")
	}
	return(list(Sat = m2, Ind = m3))
}

# ============
# = Graphics =
# ============
#' plot.MxModel
#'
#' Create graphical path diagrams from your OpenMx models!
#'
#' @aliases umxPlot
#' @rdname plot.MxModel
#' @param model an \code{\link{mxModel}} to make a path diagram from
#' @param std Whether to standardize the model.
#' @param digits The number of decimal places to add to the path coefficients
#' @param dotFilename A file to write the path model to. if you leave it at the default "name", then the model's internal name will be used
#' @param pathLabels Whether to show labels on the paths. both will show both the parameter and the label. ("both", "none" or "labels")
#' @param showFixed Whether to show fixed paths (defaults to FALSE)
#' @param showMeans Whether to show means
#' @param showError Whether to show errors
#' @export
#' @export plot.MxModel
#' @seealso - \code{\link{umxLabel}}, \code{\link{umxRun}}, \code{\link{umxValues}}
#' @family umx reporting
#' @references - \url{http://www.github.com/tbates/umx}
#' @examples
#' \dontrun{
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' plot(m1)
#' }

plot.MxModel <- function(model = NA, std = TRUE, digits = 2, dotFilename = "name", pathLabels = c("none", "labels", "both"), showFixed = FALSE, showMeans = TRUE, showError = TRUE) {
	# ==========
	# = Setup  =
	# ==========
	valid_PathLabels = c("none", "labels", "both")
	pathLabels = umx_default_option(pathLabels, valid_PathLabels, check = TRUE)

	latents = model@latentVars   # 'vis', 'math', and 'text' 
	selDVs  = model@manifestVars # 'visual', 'cubes', 'paper', 'general', 'paragrap'...
	if(std){ model = umxStandardizeModel(model, return = "model") }

	# ========================
	# = Get Symmetric & Asymmetric Paths =
	# ========================
	out = "";
	out = xmu_dot_make_paths(mxMat = model@matrices$A, stringIn = out, heads = 1, showFixed = showFixed, pathLabels = pathLabels, comment = "Single arrow paths", digits = digits)
	out = xmu_dot_make_paths(mxMat = model@matrices$S, stringIn = out, heads = 2, showFixed = showFixed, pathLabels = pathLabels, comment = "Variances", digits = digits)
	tmp = xmu_dot_make_residuals(model@matrices$S, style = NULL, showFixed = TRUE, digits = digits)
	variances     = tmp$variances
	varianceNames = tmp$varianceNames
	# ============================
	# = Make the manifest shapes =
	# ============================
	# x1 [label="E", shape = square];
	preOut = "";
	for(var in selDVs) {
	   preOut = paste0(preOut, "\t", var, " [shape = square];\n")
	}
	# ================
	# = handle means =
	# ================
	if(umx_has_means(model) & showMeans){
		out = paste0(out, "\n\t# Means paths\n")
		# Add a triangle to the list of shapes
		preOut = paste0(preOut, "\t one [shape = triangle];\n")
		mxMat = model@matrices$M
		mxMat_vals   = mxMat@values
		mxMat_free   = mxMat@free
		mxMat_labels = mxMat@labels
		meanVars = colnames(mxMat@values)
		for(target in meanVars) {
			thisPathLabel = mxMat_labels[1, target]
			thisPathFree  = mxMat_free[1, target]
			thisPathVal   = round(mxMat_vals[1, target], digits)
			if(thisPathFree){ labelStart = ' [label="' } else { labelStart = ' [label="@' }

			# TODO find a way of showing means fixed at zero?
			if(thisPathFree | showFixed ) {
			# if(thisPathFree | (showFixed & thisPathVal != 0) ) {
				out = paste0(out, "\tone -> ", target, labelStart, thisPathVal, '"];\n')
			}else{
				# cat(paste0(out, "\tone -> ", target, labelStart, thisPathVal, '"];\n'))
				# return(thisPathVal != 0)
			}
		}
	}
	# ===========================
	# = Make the variance lines =
	# ===========================
	# x1_var [label="0.21", shape = plaintext];
	for(var in variances) {
	   preOut = paste0(preOut, "\t", var, ";\n")
	}
	# ======================
	# = Set the ranks e.g. =
	# ======================
	# {rank=same; x1 x2 x3 x4 x5 };
	# TODO more intelligence possible in plot() perhaps hints like "MIMIC" or "ACE"
	rankVariables = paste0("\t{rank=min ; ", paste(latents, collapse = "; "), "};\n")
	rankVariables = paste0(rankVariables, "\t{rank=same; ", paste(selDVs, collapse = " "), "};\n")
	if(umx_has_means(model)){ append(varianceNames, "one")}

	rankVariables = paste0(rankVariables, "\t{rank=max ; ", paste(varianceNames, collapse = " "), "};\n")

	# ===================================
	# = Assemble full text to write out =
	# ===================================
	digraph = paste("digraph G {\n", preOut, out, rankVariables, "\n}", sep = "\n");

	print("nb: see ?plot.MxModel for options - std, digits, dotFilename, pathLabels, showFixed, showMeans, showError")
	if(!is.na(dotFilename)){
		if(dotFilename == "name"){
			dotFilename = paste0(model@name, ".dot")
		}
		cat(digraph, file = dotFilename) # write to file
		system(paste("open", shQuote(dotFilename)));
		# invisible(cat(digraph))
	} else {
		return (cat(digraph));
	}
}

#' umxMI
#'
#' Report modifications which would improve fit.
#'
#' @param model An \code{\link{mxModel}} for which to report modification indices
#' @param numInd How many modifications to report
#' @param typeToShow Whether to shown additions or deletions (default = "both")
#' @param decreasing How to sort (default = TRUE, decreasing)
#' @param cache = Future function to cache these time-consuming results
#' @seealso - \code{\link{umxAdd1}}, \code{\link{umxDrop1}}, \code{\link{umxRun}}, \code{\link{umxSummary}}
#' @family umx modify model, umx reporting
#' @references - \url{http://www.github.com/tbates/umx}
#' @export
#' @examples
#' \dontrun{
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' umxMI(model)
#' umxMI(model, numInd=5, typeToShow="add") # valid options are "both|add|delete"
#' }

umxMI <- function(model = NA, numInd = 10, typeToShow = "both", decreasing = TRUE, cache = TRUE) {
	# depends on xmuMI(model)
	if(typeof(model) == "list"){
		mi.df = model
	} else {
		mi = xmuMI(model, vector = TRUE)
		mi.df = data.frame(path= as.character(attributes(mi$mi)$names), value=mi$mi);
		row.names(mi.df) = 1:nrow(mi.df);
		# TODO: could be a helper: choose direction
		mi.df$from = sub(pattern="(.*) +(<->|<-|->) +(.*)", replacement="\\1", mi.df$path)
		mi.df$to   = sub(pattern="(.*) +(<->|<-|->) +(.*)", replacement="\\3", mi.df$path)
		mi.df$arrows = 1
		mi.df$arrows[grepl("<->", mi.df$path)]= 2		

		mi.df$action = NA 
		mi.df  = mi.df[order(abs(mi.df[,2]), decreasing = decreasing),] 
		mi.df$copy = 1:nrow(mi.df)
		for(n in 1:(nrow(mi.df)-1)) {
			if(grepl(" <- ", mi.df$path[n])){
				tmp = mi.df$from[n]; mi.df$from[n] = mi.df$to[n]; mi.df$to[n] = tmp 
			}
			from = mi.df$from[n]
			to   = mi.df$to[n]
			a = (model@matrices$S@free[to,from] |model@matrices$A@free[to,from])
			b = (model@matrices$S@values[to,from]!=0 |model@matrices$A@values[to,from] !=0)
			if(a|b){
				mi.df$action[n]="delete"
			} else {
				mi.df$action[n]="add"
			}
			inc= min(4,nrow(mi.df)-(n))
			for (i in 1:inc) {
				if((mi.df$copy[(n)])!=n){
					# already dirty
				}else{
					# could be a helper: swap two 
					from1 = mi.df[n,"from"]     ; to1   = mi.df[n,"to"]
					from2 = mi.df[(n+i),"from"] ; to2   = mi.df[(n+i),'to']
					if((from1==from2 & to1==to2) | (from1==to2 & to1==from2)){
						mi.df$copy[(n+i)]<-n
					}
				}		
			}
		}
	}
	mi.df = mi.df[unique(mi.df$copy),] # c("copy")
	if(typeToShow != "both"){
		mi.df = mi.df[mi.df$action == typeToShow,]
	}
	print(mi.df[1:numInd, !(names(mi.df) %in% c("path","copy"))])
	invisible(mi.df)		
}

# ======================
# = Path tracing rules =
# ======================
#' umxUnexplainedCausalNexus
#'
#' umxUnexplainedCausalNexus report the effect of a change (delta) in a variable (from) on an output (to)
#'
#' @param from A variable in the model that you want to imput the effect of a change
#' @param delta A the amount to simulate changing \"from\" by. 
#' @param to The dependent variable that you want to watch changing
#' @param model The model containing from and to
#' @seealso - \code{\link{umxRun}}, \code{\link{mxCompare}}
#' @references - http://www.github.com/tbates/umx/
#' @export
#' @examples
#' \dontrun{
#' umxUnexplainedCausalNexus(from="yrsEd", delta = .5, to = "income35", model)
#' }

umxUnexplainedCausalNexus <- function(from, delta, to, model) {
	manifests = model@manifestVars
	partialDataRow <- matrix(0, 1, length(manifests))  # add dimnames to support string varnames 
	dimnames(partialDataRow) = list("val", manifests)
	partialDataRow[1, from] <- delta # delta is in raw "from" units
	partialDataRow[1, to]   <- NA
	completedRow <- umxConditionalsFromModel(model, partialDataRow, meanOffsets = TRUE)
	# by default, meanOffsets = FALSE, and the results take expected means into account
	return(completedRow[1, to])
}

umxConditionalsFromModel <- function(model, newData = NULL, returnCovs = FALSE, meanOffsets = FALSE) {
	# original author: [Timothy Brick](http://www.github.com/tbates/umx/users/tbrick)
	# [history](http://www.github.com/tbates/umx/thread/2076)
	# Called by: umxUnexplainedCausalNexus
	# TODO:  Special case for latent variables
	# FIXME: Update for fitfunction/expectation
	expectation <- model$objective
	A <- NULL
	S <- NULL
	M <- NULL
	
	# Handle missing data
	if(is.null(newData)) {
		data <- model$data
		if(data@type != "raw") {
			stop("Conditionals requires either new data or a model with raw data.")
		}
		newData <- data@observed
	}
	
	if(is.list(expectation)) {  # New fit-function style
		eCov  <- model$fitfunction@info$expCov
		eMean <- model$fitfunction@info$expMean
		expectation <- model$expectation
		if(!length(setdiff(c("A", "S", "F"), names(getSlots(class(expectation)))))) {
			A <- eval(substitute(model$X@values, list(X=expectation@A)))
			S <- eval(substitute(model$X@values, list(X=expectation@S)))
			if("M" %in% names(getSlots(class(expectation))) && !is.na(expectation@M)) {
				M <- eval(substitute(model$X@values, list(X=expectation@M)))
			}
		}
	} else { # Old objective-style
		eCov <- model$objective@info$expCov
		eMean <- model$objective@info$expMean
		if(!length(setdiff(c("A", "S", "F"), names(getSlots(class(expectation)))))) {
			A <- eval(substitute(model$X@values, list(X=expectation@A)))
			S <- eval(substitute(model$X@values, list(X=expectation@S)))
			if("M" %in% names(getSlots(class(expectation))) && !is.na(expectation@M)) {
				M <- eval(substitute(model$X@values, list(X=expectation@M)))
			}
		}
	}

	if(!is.null(A)) {
		# RAM model: calculate total expectation
		I <- diag(nrow(A))
		Z <- solve(I-A)
		eCov <- Z %*% S %*% t(Z)
		if(!is.null(M)) {
			eMean <- Z %*% t(M)
		}
		latents <- model@latentVars
		newData <- data.frame(newData, matrix(NA, ncol=length(latents), dimnames=list(NULL, latents)))
	}
	
	# No means
	if(meanOffsets || !dim(eMean)[1]) {
		eMean <- matrix(0.0, 1, ncol(eCov), dimnames=list(NULL, colnames(eCov)))
	}
	
	# TODO: Sort by pattern of missingness, lapply over patterns
	nRows = nrow(newData)
	outs <- omxApply(newData, 1, umxComputeConditionals, sigma=eCov, mu=eMean, onlyMean=!returnCovs)
	if(returnCovs) {
		means <- matrix(NA, nrow(newData), ncol(eCov))
		covs <- rep(list(matrix(NA, nrow(eCov), ncol(eCov))), nRows)
		for(i in 1:nRows) {
			means[i,] <- outs[[i]]$mu
			covs[[i]] <- outs[[i]]$sigma
		}
		return(list(mean = means, cov = covs))
	}
	return(t(outs))
}

umxComputeConditionals <- function(sigma, mu, current, onlyMean = FALSE) {
	# Usage: umxComputeConditionals(model, newData)
	# Result is a replica of the newData data frame with missing values and (if a RAM model) latent variables populated.
	# original author: [Timothy Brick](http://www.github.com/tbates/umx/users/tbrick)
	# [history](http://www.github.com/tbates/umx/thread/2076)
	# called by umxConditionalsFromModel()
	if(dim(mu)[1] > dim(mu)[2] ) {
		mu <- t(mu)
	}

	nVar <- length(mu)
	vars <- colnames(sigma)

	if(!is.matrix(current)) {
		current <- matrix(current, 1, length(current), dimnames=list(NULL, names(current)))
	}
	
	# Check inputs
	if(dim(sigma)[1] != nVar || dim(sigma)[2] != nVar) {
		stop("Non-conformable sigma and mu matrices in conditional computation.")
	}
	
	if(is.null(vars)) {
		vars <- rownames(sigma)
		if(is.null(vars)) {
			vars <- colnames(mu)
			if(is.null(vars)) {
				vars <- names(current)
				if(is.null(vars)) {
					vars <- paste("X", 1:dim(sigma)[1], sep="")
					names(current) <- vars
				}
				names(mu) <- vars
			}
			dimnames(sigma) <- list(vars, vars)
		}
		rownames(sigma) <- vars
	}
	
	if(is.null(colnames(sigma))) {
		colnames(sigma) <- vars
	}
	
	if(is.null(rownames(sigma))) {
		rownames(sigma) <- colnames(sigma)
	}

	if(!setequal(rownames(sigma), colnames(sigma))) {
		stop("Rows and columns of sigma do not match in conditional computation.")
	}
	
	if(!setequal(rownames(sigma), vars) || !setequal(colnames(sigma), vars)) {
		stop("Names of covariance and means in conditional computation fails.")
	}
	
	if(length(current) == 0) {
		if(onlyMean) {
			return(mu)
		}
		return(list(sigma=covMat, mu=current))
	}
	
	if(is.null(names(current))) {
		if(length(vars) == 0 || ncol(current) != length(vars)) {
			print(paste("Got data vector of length ", ncol(current), " and names of length ", length(vars)))
			stop("Length and names of current values mismatched in conditional computation.")
		}
		names(current) <- vars[1:ncol(current)]
	}
	
	if(is.null(names(current))) {
		if(length(vars) == 0 || ncol(current) != length(vars)) {
			if(length(vars) == 0 || ncol(current) != length(vars)) {
				print(paste("Got mean vector of length ", ncol(current), " and names of length ", length(vars)))
				stop("Length and names of mean values mismatched in conditional computation.")
			}
		}
		names(mu) <- vars
	}
	
	# Get Missing and Non-missing sets
	if(!setequal(names(current), vars)) {
		newSet <- setdiff(vars, names(current))
		current[newSet] <- NA
		current <- current[vars]
	}
	
	# Compute Schur Complement
	# Calculate parts:
	missing <- names(current[is.na(current)])
	nonmissing <- setdiff(vars, missing)
	ordering <- c(missing, nonmissing)
	
	totalCondCov <- NULL

	# Handle all-missing and none-missing cases
	if(length(missing) == 0) {
		totalMean = current
		names(totalMean) <- names(current)
		totalCondCov = sigma
	} 

	if(length(nonmissing) == 0) {
		totalMean = mu
		names(totalMean) <- names(mu)
		totalCondCov = sigma
	}

	# Compute Conditional expectations
	if(is.null(totalCondCov)) {
		
		covMat <- sigma[ordering, ordering]
		missMean <- mu[, missing]
		haveMean <- mu[, nonmissing]

		haves <- current[nonmissing]
		haveNots <- current[missing]

		missCov <- sigma[missing, missing]
		haveCov <- sigma[nonmissing, nonmissing]
		relCov <- sigma[missing, nonmissing]
		relCov <- matrix(relCov, length(missing), length(nonmissing))

		invHaveCov <- solve(haveCov)
		condMean <- missMean + relCov %*% invHaveCov %*% (haves - haveMean)

		totalMean <- current * 0.0
		names(totalMean) <- vars
		totalMean[missing] <- condMean
		totalMean[nonmissing] <- current[nonmissing]
	}

	if(onlyMean) {
		return(totalMean)
	}
	
	if(is.null(totalCondCov)) {
		condCov <- missCov - relCov %*% invHaveCov %*% t(relCov)
	
		totalCondCov <- sigma * 0.0
		totalCondCov[nonmissing, nonmissing] <- haveCov
		totalCondCov[missing, missing] <- condCov
	}	
	return(list(sigma=totalCondCov, mu=totalMean))
	
}


# =========================
# = Pull model components =
# =========================

#' extractAIC.MxModel
#'
#' Returns the AIC for an OpenMx model
#' helper function for \code{\link{logLik.MxModel}} (which enables AIC(model); logLik(model); BIC(model)
#' Original Author: brandmaier
#'
#' @method extractAIC MxModel
#' @rdname extractAIC.MxModel
#' @export
#' @param model an \code{\link{mxModel}} to get the AIC from
#' @return - AIC value
#' @seealso - \code{\link{AIC}}, \code{\link{umxCompare}}, \code{\link{logLik.MxModel}}
#' @references - \url{http://www.github.com/tbates/umx/thread/931#comment-4858}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' extractAIC(m1)
#' # -2.615998
#' AIC(m1)
extractAIC.MxModel <- function(model) {
	require(umx)
	a = umx::umxCompare(model)
	return(a[1, "AIC"])
}

#' coef.MxModel
#'
#' Returns the coeficients from an OpenMx RAM model
#'
#' @method coef MxModel
#' @rdname coef.MxModel
#' @export
#' @param model an \code{\link{mxModel}} to get the AIC from
#' @return - coefficients
#' @seealso - \code{\link{AIC}}, \code{\link{umxCompare}}, \code{\link{mxStandardizeRAMpaths}}
#' @references - 
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' coef(m1)
#' # -2.615998
coef.MxModel <- function(model) {
	# TODO implement this
	message("Not implemented")
	message("TODO implement this using wrapper around mxStandardizeRAMpaths")
}

#' umxExpCov
#'
#' extract the expected covariance matrix from an \code{\link{mxModel}}
#'
#' @param model an \code{\link{mxModel}} to get the covariance matrix from
#' @param latents Whether to select the latent variables (defaults to TRUE)
#' @param manifests Whether to select the manifest variables (defaults to TRUE)
#' @param digits precision of reporting. Leave NULL to do no rounding.
#' @return - expected covariance matrix
#' @export
#' @references - \url{http://openmx.psyc.virginia.edu/thread/2598}
#' Original written by \url{http://openmx.psyc.virginia.edu/users/bwiernik}
#' @seealso - \code{\link{umxRun}}, \code{\link{umxCI_boot}}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' umxExpCov(m1)
#' umxExpCov(m1, digits = 3)
umxExpCov <- function(model, latents = FALSE, manifests = TRUE, digits = NULL){
	# umx_has_been_run(m1)
	if(model@data@type == "raw"){
		manifestNames = names(model$data@observed)
	} else {
		manifestNames = dimnames(model$data@observed)[[1]]
	}
	if(umx_is_RAM(model)){
		if(manifests & !latents){
			# TODO # test umxExpCov under 1.4?
			if(mxVersion(verbose = FALSE) > "2.0"){
				# expCov = attr(model$objective[[2]]$result, "expCov")
				thisFit = paste0(model$name, ".fitfunction")
				expCov <- attr(model@output$algebras[[thisFit]], "expCov")
			} else {
				# version 1.4 or below
				expCov = model$objective@info$expCov
			}
			dimnames(expCov) = list(manifestNames, manifestNames)
		} else {
			A <- mxEval(A, model)
			S <- mxEval(S, model)
			I <- diag(1, nrow(A))
			E <- solve(I - A)
			expCov <- E %&% S # The model-implied covariance matrix
			mV <- NULL
			if(latents) {
				mV <- model@latentVars 
			}
			if(manifests) {
				mV <- c(mV, model@manifestVars)
			}
			expCov = expCov[mV, mV]
		}
	} else {
		if(latents){
			stop("I don't know how to reliably get the latents for non-RAM models... Sorry :-(")
		} else {
			if(mxVersion(verbose = FALSE) > "1.5.0"){
				expCov <- attr(model@output$algebras[[paste0(model$name, ".fitfunction")]], "expCov")
			} else {
				expCov = model$objective@info$expCov
			}
			dimnames(expCov) = list(manifestNames, manifestNames)
		}
	}
	if(!is.null(digits)){
		expCov = round(expCov, digits)
	}
	return(expCov) 
}
#' umxExpMean
#'
#' Extract the expected means matrix from an \code{\link{mxModel}}
#'
#' @param model an \code{\link{mxModel}} to get the means from
#' @param latents Whether to select the latent variables (defaults to TRUE)
#' @param manifests Whether to select the manifest variables (defaults to TRUE)
#' @param digits precision of reporting. Leave NULL to do no rounding.
#' @return - expected means
#' @export
#' @references - \url{http://openmx.psyc.virginia.edu/thread/2598}
#' @seealso - \code{\link{umxExpCov}}, \code{\link{umxCI_boot}}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = "one", to = manifests),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(demoOneFactor, type = "raw")
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' umxExpMeans(model = m1)
#' umxExpMeans(m1, digits = 3)
umxExpMeans <- function(model, manifests = TRUE, latents = NULL, digits = NULL){
	# TODO # what does umxExpMeans do under 1.4?
	umx_check_model(model, beenRun = TRUE)
	if(!umx_has_means(model)){
		stop("Model has no means expectation to get: Are there any means in the data? (type='raw', or type = 'cov' with means?)")
	}
	
	if(umx_is_RAM(model)){
		# TODO something nice to do here?
	}
	if(!is.null(latents)){
		# TODO should a function called expMeans get expected means for latents... why not.
		stop("Haven't thought about getting means for latents yet... Bug me about it :-)")
	}
	expMean <- attr(model@output$algebras[[paste0(model$name, ".fitfunction")]], "expMean")
	
	if(model@data@type == "raw"){
		manifestNames = names(model$data@observed)
	} else {
		manifestNames = dimnames(model$data@observed)[[1]]
	}
	dimnames(expMean) = list("mean", manifestNames)
	if(!is.null(digits)){
		expMean = round(expMean, digits)
	}
	return(expMean)
}

#' logLik.MxModel
#'
#' Returns the log likelihood for an OpenMx model. This helper also 
#' enables \code{\link{AIC}}(model); \code{\link{BIC}}(model).
#'
#' hat-tip Andreas Brandmaier
#'
#' @method logLik MxModel
#' @rdname  logLik
#' @export
#' @param model the \code{\link{mxModel}} from which to get the log likelihood 
#' @return - the log likelihood
#' @seealso - \code{\link{AIC}}, \code{\link{umxCompare}}
#' @family umx reporting
#' @references - \url{http://openmx.psyc.virginia.edu/thread/931#comment-4858}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' logLik(m1)
#' AIC(m1)
logLik.MxModel <- function(model) {
	Minus2LogLikelihood <- NA
	if (!is.null(model@output) & !is.null(model@output$Minus2LogLikelihood)){
		Minus2LogLikelihood <- (-0.5) * model@output$Minus2LogLikelihood		
	}
	if (!is.null(model@data)){
		attr(Minus2LogLikelihood,"nobs") <- model@data@numObs
	}else{ 
		attr(Minus2LogLikelihood,"nobs") <- NA
	}
	if (!is.null(model@output)){
		attr(Minus2LogLikelihood,"df") <- length(model@output$estimate)	
	} else {
		attr(Minus2LogLikelihood, "df") <- NA
	}
	class(Minus2LogLikelihood) <- "logLik"
	return(Minus2LogLikelihood);
}

#' umxFitIndices
#'
#' A list of fit indices
#'
#' @param model the \code{\link{mxModel}} you want fit indices for
#' @param indepfit an (optional) saturated \code{\link{mxModel}}
#' @return \code{NULL}
#' @export
#' @family umx reporting
#' @references - \url{http://www.github.com/tbates/umx}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' umxFitIndices(m1, m1_ind)
#' # TODO use means and compute independence model here for example...
umxFitIndices <- function(model, indepfit) {
	options(scipen = 3)
	indepSummary     <- summary(indepfit)
	modelSummary <- summary(model)
	N         <- modelSummary$numObs
	N.parms   <- modelSummary$estimatedParameters
	N.manifest <- length(model@manifestVars)
	deviance  <- modelSummary$Minus2LogLikelihood
	Chi       <- modelSummary$Chi
	df        <- modelSummary$degreesOfFreedom
	p.Chi     <- 1 - pchisq(Chi, df)
	Chi.df    <- Chi/df
	indep.chi <- indepSummary$Chi
	indep.df  <- indepSummary$degreesOfFreedom
	q <- (N.manifest*(N.manifest+1))/2
	N.latent     <- length(model@latentVars)
	observed.cov <- model@data@observed
	observed.cor <- cov2cor(observed.cov)

	A <- model@matrices$A@values
	S <- model@matrices$S@values
	F <- model@matrices$F@values
	I <- diag(N.manifest+N.latent)
	estimate.cov <- F %*% (qr.solve(I-A)) %*% S %*% (t(qr.solve(I-A))) %*% t(F)
	estimate.cor <- cov2cor(estimate.cov)
	Id.manifest  <- diag(N.manifest)
	residual.cov <- observed.cov-estimate.cov
	residual.cor <- observed.cor-estimate.cor
	F0       <- max((Chi-df)/(N-1),0)
	NFI      <- (indep.chi-Chi)/indep.chi
	NNFI.TLI <- (indep.chi-indep.df/df*Chi)/(indep.chi-indep.df)
	PNFI     <- (df/indep.df)*NFI
	RFI      <- 1 - (Chi/df) / (indep.chi/indep.df)
	IFI      <- (indep.chi-Chi)/(indep.chi-df)
	CFI      <- min(1.0-(Chi-df)/(indep.chi-indep.df),1)
	PRATIO   <- df/indep.df
	PCFI     <- PRATIO*CFI
	NCP      <- max((Chi-df),0)
	RMSEA    <- sqrt(F0/df) # need confidence intervals
	MFI      <- exp(-0.5*(Chi-df)/N)
	GH       <- N.manifest / (N.manifest+2*((Chi-df)/(N-1)))
	GFI      <- 1 - (
		 sum(diag(((solve(estimate.cor) %*% observed.cor)-Id.manifest) %*% ((solve(estimate.cor) %*% observed.cor) - Id.manifest))) /
	    sum(diag((solve(estimate.cor) %*% observed.cor) %*% (solve(estimate.cor) %*% observed.cor)))
	)
	AGFI     <- 1 - (q/df)*(1-GFI)
	PGFI     <- GFI * df/q
	AICchi   <- Chi+2*N.parms
	AICdev   <- deviance+2*N.parms
	BCCchi   <- Chi + 2*N.parms/(N-N.manifest-2)
	BCCdev   <- deviance + 2*N.parms/(N-N.manifest-2)
	BICchi   <- Chi+N.parms*log(N)
	BICdev   <- deviance+N.parms*log(N)
	CAICchi  <- Chi+N.parms*(log(N)+1)
	CAICdev  <- deviance+N.parms*(log(N)+1)
	ECVIchi  <- 1/N*AICchi
	ECVIdev  <- 1/N*AICdev
	MECVIchi <- 1/BCCchi
	MECVIdev <- 1/BCCdev
	RMR      <- sqrt((2*sum(residual.cov^2))/(2*q))
	SRMR     <- sqrt((2*sum(residual.cor^2))/(2*q))
	indices  <-
	rbind(N,deviance,N.parms,Chi,df,p.Chi,Chi.df,
		AICchi,AICdev,
		BCCchi,BCCdev,
		BICchi,BICdev,
		CAICchi,CAICdev,
		RMSEA,SRMR,RMR,
		GFI,AGFI,PGFI,
		NFI,RFI,IFI,
		NNFI.TLI,CFI,
		PRATIO,PNFI,PCFI,NCP,
		ECVIchi,ECVIdev,MECVIchi,MECVIdev,MFI,GH
	)
	return(indices)
}

# define generic RMSEA...
#' Generic RMSEA function
#'
#' See \code{\link[umx]{RMSEA.MxModel}} to access the RMSEA of MxModels
#'
#' @param x an object to get the RMSEA for
#' @return - RMSEA object containing value (and perhaps a CI)
#' @export
#' @seealso - \code{\link[umx]{RMSEA.MxModel}}
#' @references - \url{https://github.com/tbates/umx}, \url{tbates.github.io}, \url{http://openmx.psyc.virginia.edu}
RMSEA <- function(x) UseMethod("RMSEA", x)

#' RMSEA function for MxModels
#'
#' Compute the confidence interval on RMSEA
#'
#' @param model an \code{\link{mxModel}} to get CIs on RMSEA for
#' @param ci.lower the lower CI to compute
#' @param ci.upper the upper CI to compute
#' @return - object containing the RMSEA and lower and upper bounds
#' @rdname RMSEA.MxModel
#' @export
#' @family umx reporting
#' @references - \url{https://github.com/simsem/semTools/wiki/Functions}, \url{https://github.com/tbates/umx}
#' @examples
#' require(OpenMx)
#' data(demoOneFactor)
#' latents  = c("G")
#' manifests = names(demoOneFactor)
#' m1 <- mxModel("One Factor", type = "RAM", 
#' 	manifestVars = manifests, latentVars = latents, 
#' 	mxPath(from = latents, to = manifests),
#' 	mxPath(from = manifests, arrows = 2),
#' 	mxPath(from = latents, arrows = 2, free = FALSE, values = 1.0),
#' 	mxData(cov(demoOneFactor), type = "cov", numObs = 500)
#' )
#' m1 = umxRun(m1, setLabels = TRUE, setValues = TRUE)
#' RMSEA(m1)
RMSEA.MxModel <- function(model, ci.lower = .05, ci.upper = .95) { 
	sm <- summary(model)
	if (is.na(sm$Chi)) return(NA);
	X2 <- sm$Chi
	df <- sm$degreesOfFreedom
	N  <- sm$numObs 
    N.RMSEA <- max(N, X2 * 4)
    G <- max(length(model@submodels), 1)

    if (is.na(X2) || is.na(df)) {
        RMSEA <- as.numeric(NA)
    } else if (df > 0) {
        GG <- 0
        RMSEA <- sqrt(max(c((X2/N)/df - 1/(N - GG), 0))) *  sqrt(G)
    } else {
        RMSEA <- 0
    }

	lower.lambda <- function(lambda) {
		pchisq(X2, df = df, ncp = lambda) - ci.upper
	}
	upper.lambda <- function(lambda) {
		(pchisq(X2, df = df, ncp = lambda) - ci.lower)
	}

	if (is.na(X2) || is.na(df)) {
		rmsea.lower <- NA
	} else if (df < 1 || lower.lambda(0) < 0) {
		rmsea.lower <- 0
	} else {
		lambda.l <- try(uniroot(f = lower.lambda, lower = 0, upper = X2)$root)
		if (inherits(lambda.l, "try-error")) {
			lambda.l <- NA
		}
		GG <- 0
		rmsea.lower <- sqrt(lambda.l/((N - GG) * df)) * sqrt(G)
	}
	if (is.na(X2) || is.na(df)) {
		rmsea.upper <- NA
	} else if (df < 1 || upper.lambda(N.RMSEA) > 0 || upper.lambda(0) < 0) {
		rmsea.upper <- 0
	} else {
		lambda.u <- try(uniroot(f = upper.lambda, lower = 0, upper = N.RMSEA)$root)
		if (inherits(lambda.u, "try-error")) {
			lambda.u <- NA
		}
		GG <- 0
		rmsea.upper <- sqrt(lambda.u/((N - GG) * df)) * sqrt(G)
	}
	# compute p-value
	if (is.na(X2) || is.na(df)) {
		rmsea.pvalue <- as.numeric(NA)
	} else if (df > 0) {
		GG <- 0
		ncp <- (N - GG) * df * 0.05^2/G
		rmsea.pvalue <- (1 - pchisq(X2, df = df, ncp = ncp))
	} else {
		rmsea.pvalue <- 1
	}
	
	txt = paste0("RMSEA = ", round(RMSEA, 3), " CI", sub("^0?\\.", replacement = "", ci.upper), "[", round(rmsea.lower, 3), ", ", round(rmsea.upper, 3), "], p = ", umx_APA_pval(rmsea.pvalue))
	print(txt)
	invisible(list(RMSEA = RMSEA, RMSEA.lower = rmsea.lower, RMSEA.upper = rmsea.upper, CI.lower = ci.lower, CI.upper = ci.upper, RMSEA.pvalue = rmsea.pvalue, txt = txt)) 
}

#' umxDescriptives
#'
#' Summarize data for an APA style subjects table
#'
#' @param data          data.frame to compute descriptive statistics for
#' @param measurevar    The data column to summarise
#' @param groupvars     A list of columns to group the data by
#' @param na.rm         whether to remove NA from the data
#' @param conf.interval The size of the CI you request - 95 by default
#' @param .drop         Whether to drop TODO
#' @family umx reporting
#' @export
#' @references - \url{http://www.cookbook-r.com/Manipulating_data/Summarizing_data}
#' @examples
#' \dontrun{
#' umxDescriptives(data)
#' }

umxDescriptives <- function(data = NULL, measurevar, groupvars = NULL, na.rm = FALSE, conf.interval = .95, .drop = TRUE) {
    require(plyr)
    # New version of length which can handle NA's: if na.rm == T, don't count them
    length2 <- function (x, na.rm=FALSE) {
        if (na.rm){
			sum(!is.na(x))        	
        } else { 
            length(x)
		}
    }

    # The summary; it's not easy to understand...
    datac <- plyr::ddply(data, groupvars, .drop = .drop,
           .fun = function(xx, col, na.rm) {
                   c( N    = length2(xx[,col], na.rm=na.rm),
                      mean = mean   (xx[,col], na.rm=na.rm),
                      sd   = sd     (xx[,col], na.rm=na.rm)
                      )
                  },
            measurevar,
            na.rm
    )
    # Rename the "mean" column
    datac    <- umx_rename(datac, c("mean" = measurevar))
    datac$se <- datac$sd / sqrt(datac$N) # Calculate standard error of the mean

    # Confidence interval multiplier for standard error
    # Calculate t-statistic for confidence interval: 
    # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
    ciMult <- qt(conf.interval/2 + .5, datac$N - 1)
    datac$ci <- datac$se * ciMult
    return(datac)
}
