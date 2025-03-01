set.seed(1000)
myCov = matrix(nrow = 2, ncol = 2, byrow = T, c(1.0, 0.5, 0.5, 1.0));
xy = MASS::mvrnorm (n = 100, mu = c(0,0), Sigma = myCov);
xy = data.frame(xy);  names(xy) <- c("x", "y");
manifests = names(xy) # list all the squares in the diagram
m1 <- mxModel("x_predicts_y", type = "RAM", manifestVars = manifests, # add the manifests
    mxPath(from = "x", to = "y"),                         # manifest causes (1 arrow is the default)
    mxPath(from = manifests, to = manifests, arrows = 2), # 2-headed arrows to each manifest for residuals 
    mxPath(from = "one", to = manifests),                 # manifest means
	mxData(xy, type = "raw")
)
m1 = umxRun(m1, setLabels = T, setValues = T)
umxSummary(m1, show= "std"); # umxPlot(m1)

# ==========================================
# = 3. Test on matrix model with submodels =
# ==========================================

data(twinData, package = "OpenMx")
selDVs <- c('ht1', 'wt1', 'ht2', 'wt2') # height and weight for each twin
nVar   <- length(selDVs)/2 # number of variables
mzData <- as.matrix(subset(myTwinData, zyg == 1, selDVs)) # female MZ twins
dzData <- as.matrix(subset(myTwinData, zyg == 3, selDVs)) # female DZ twins

ACE <- mxModel("ACE_cholesky",
	mxModel("top",
		# Matrices a, c, and e to store a, c, and e path coefficients
		mxMatrix(name = "a", type = "Lower", nrow = nVar, ncol = nVar, free = T, values = .6),
		mxMatrix(name = "c", type = "Lower", nrow = nVar, ncol = nVar, free = T, values = .2), 
		mxMatrix(name = "e", type = "Lower", nrow = nVar, ncol = nVar, free = T, values = .2), 

		# Matrices A, C, and E compute variance components
		mxAlgebra( a %*% t(a), name = "A" ),
		mxAlgebra( c %*% t(c), name = "C" ),
		mxAlgebra( e %*% t(e), name = "E" ),
		mxAlgebra(A+C+E     , name = "ACE"),
		mxAlgebra(A+C       , name = "AC" ),
		mxAlgebra(.5%x%A + C, name = "hAC"),

		# Matrix & Algebra for expected means vector
		mxMatrix(type = "Full", nrow = 1, ncol = nVar, free = T, values = 1, name = "Mean"),
		mxAlgebra(cbind(Mean, Mean), name = "expMean"),

		# Algebra for expected variance/covariance matrix in MZ
		mxAlgebra(rbind (cbind(ACE, AC), 
		                 cbind(AC , ACE)), dimnames = list(selDVs, selDVs), name="mzCov"),
		mxAlgebra(rbind (cbind(ACE, hAC),
		                 cbind(hAC, ACE)), dimnames = list(selDVs, selDVs), name="dzCov")
	),
    mxModel("MZ",
        mxData(mzData, type = "raw"),
        mxFIMLObjective(covariance = "top.mzCov", means = "top.expMean", dimnames = selDVs)
    ),
    mxModel("DZ",
        mxData(dzData, type = "raw"),
        mxFIMLObjective(covariance = "top.dzCov", means = "top.expMean", dimnames = selDVs)
    ),
    mxAlgebra(MZ.objective + DZ.objective, name="modelfit"),
    mxAlgebraObjective("modelfit")
)
ACE <- mxRun(ACE); summaryACEFit(ACE)
names(omxGetParameters(ACE)) # Use this to see what parameters exist in matrices
ACE2 <- omxSetParameters(ACE, "top.a[2,1]", values = 0, free = F, name="no_genetic_covariance")
ACE2 <- mxRun(ACE2)
mxCompare(ACE, ACE2)
omxGetParameters(ACE)
ACE  <- umxLabel(ACE)
ACE3 <- mxRun(omxSetParameters(ACE, "a_r2c1", values = 0, free = F, name="no_genetic_covariance2"))

ACE25 <- omxSetParameters(ACE, c("Mean_r1c1", "Mean_r1c2"), values = 0, free = F, name="meansequal")
mxRun(ACE25)
ACE4 <- mxRun(omxSetParameters(ACE, c("c_r1c1", "c_r2c1", "c_r2c2"), values = 0, free = F, name="no_c"))
ACE5 <- mxRun(omxSetParameters(ACE, c("e_r2c1"), values = 0, free = F, name="no_c_no_e_cov"))
summaryACEFit(ACE3)
mxCompare(ACE, c(ACE2, ACE3))
mxCompare(ACE2, ACE3)



mxCompare(ACE, c(ACE3,ACE4,ACE5))
summaryACEFit(ACE4)

c("a_r1c1", "a_r2c1", "a_r2c2", , "e_r1c1", "e_r2c1", "e_r2c2", "Mean_r1c1", "Mean_r1c2")