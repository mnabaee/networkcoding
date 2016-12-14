ReadMe file for:	 MATLAB\simulationRun\
SIMULATION RUNS TO COMPARE QNC WITH PACKET FORWARDING VIA SHORTEST PATH
**RUNNABLES*****************************************************

mainSimRun4.m			: Main Module to run different cases of QNC and routing with ONE block length
----------------------------------------------------------------------------------------------------
mainSimRun5.m			: Main Module to run different cases of QNC and routing with DIFFERENT block lengthes
----------------------------------------------------------------------------------------------------
mainSimRun6.m			: Main Module to run different cases of QNC and routing with DIFFERENT block lengthes
                          uses parallel network codes (not orthogonality)
----------------------------------------------------------------------------------------------------
plotFilter.m			: Plot and filters (tail data) results for QNC and routing for a single block length
						   where both delay and compression ratio are put on x axises.
----------------------------------------------------------------------------------------------------
plotFilter2.m			: Plot and filters (tail data) results for QNC and routing and over plots it for 
							different block lengthes and a single sparsity factor (sp=0.2)
----------------------------------------------------------------------------------------------------
plotFilter3.m			: Plot and filters (tail data) results for QNC and routing and over plots it for 
							different block lengthes and a single sparsity factor (sp=0.2)
----------------------------------------------------------------------------------------------------
plotFilter4.m			: Plot and filters (tail data) results for QNC and routing for different block
							lengthes and then finds the top curve among them as the best case SNR-delay curve.
----------------------------------------------------------------------------------------------------
plotResults3.m			: Plots the results (without filtering) 

**FUNCTIONS*****************************************************

simulateQNC.m		: Simulates Quantized Network Coding and calculates zTot
					[zTot]=simulateQNC(iterations,Delta,x,A,F,B);
----------------------------------------------------------------------------------------------------
calculateQNC.m		: Calculates Network Coding Transfer Function 
					[Psi,PsiTot]=calculateQNC(iterations,A,F,B);
----------------------------------------------------------------------------------------------------
L1minDec.m			: L1min Decodder
					[recErrNorm,numMeas,xRec]=L1minDec(PsiTot,zTot,phi,x);
---------------------------------------------------------------------------------------------------
pInvDec.m			: pInverse Decodder which calculates pseudo inverse of PsiTot
					[recErrNorm,xRec]=pInvDec(PsiTot,zTot,x);
---------------------------------------------------------------------------------------------------
RandOrthMat.m		: Generates a random orthonormal matrix
					M=RandOrthMat(n, tol);
---------------------------------------------------------------------------------------------------
topFinder.m			: finds the top points among a set of X,Y data (somehow convex hull but not convex hull)
					[xVec1,yVec1]=topFinder(data1X,data1Y);
---------------------------------------------------------------------------------------------------
GenMess.m			: Generates random messages of different sparsity factors and ranges (q)
					[x,phi,xNorm]=GenMess(nodes,sp,q);
---------------------------------------------------------------------------------------------------
GenNetCapsule.m		: Generates random deployment of network and B matrix
					[htList,GWnode,B]=GenNetCapsule(nodes,edges);
---------------------------------------------------------------------------------------------------
GenQNCcoef.m		: Generates random network coding coefficients, according to design1
					[A,F]=GenQNCcoef(nodes,edges,iterations,htList,xRange);
---------------------------------------------------------------------------------------------------
GenQNCcoefnonOrth.m		: Generates random network coding coefficients, according to design1
                            without forcing orthogonality condition on beta's
					[A,F]=GenQNCcoef(nodes,edges,iterations,htList,xRange);
---------------------------------------------------------------------------------------------------
RouteCapsule.m		: Performs shortest path routing and packet forwarding according to routes
					[recErrNorm]=RouteCapsule(nodes,edges,iterations,Delta,htList,x,GWnode);
---------------------------------------------------------------------------------------------------