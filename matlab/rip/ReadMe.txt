ReadMe file for:	 MATLAB\RIP\
RIP ANALYSIS FOLDER
**RUNNABLES*****************************************************

mainRIP.m						: RIP investigation by using norm conservation for random vectors,
									not concatinated matrices.
----------------------------------------------------------------------------------------------------
mainRIPorg.m					: RIP investigation by using norm conservation for random vectors,
									not concatinated matrices.
----------------------------------------------------------------------------------------------------
mainRIPanalyze.m				: Analyzing time concatination with normalization, i.e. (c,1-c), for
									network coding matrices.
----------------------------------------------------------------------------------------------------
maintestRIPnetCodes.m			: Test RIP for network coding coefficients by using original
								  definition of RIP (conservating norms)
----------------------------------------------------------------------------------------------------
maintestRIP.m					: Test concentration inequalities
----------------------------------------------------------------------------------------------------
mainsparseKLT.m					: Sparsity and KLT

**FUNCTIONS*****************************************************

generateQNC.m					: generates Network Coding Projection Matrix (a very old version!)
(function) 						[P,cncP,cncPnlzd,G,H]=genNCmat(conMat,GWnode,its,nrlzdFactor);
----------------------------------------------------------------------------------------------------