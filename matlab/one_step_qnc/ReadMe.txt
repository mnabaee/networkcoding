ReadMe file for:	 MATLAB\QuantizedNC\

**RUNNABLES*****************************************************
****************************************************************
mainSimRun1.m       : Runs a complete GUI-less simulation for sparse QNC

****************************************************************
**FUNCTIONS*****************************************************
****************************************************************
GenNetCapsule.m (function)		: Generates network deployment randomly based on a uniform edge distribution.
								 [htList,GWnode,B]=GenNetCapsule(nodes,perNodeEdges);
----------------------------------------------------------------------------------------------------
GenSQNCcoef.m (function)        : Generates SPARSE network coding coefficients with densityRow parameter.
								 [A,F]=GenSQNCcoef(nodes,edges,iterations,htList,densityRow);
----------------------------------------------------------------------------------------------------
GencoefOneStep.m (function)     : Generates SPARSE network coding coefficients for One-Step QNC with densityRow parameter.
								 [A,F]=GencoefOneStep(nodes,edges,iterations,htList,densityRow);
----------------------------------------------------------------------------------------------------
GenMess.m (function)			: Generates random phi and messages in a sparse-phi fashion.
								[x,phi,xNorm]=GenMess(nodes,htList,phiSparsityOrder,sparsityFactor,xRange,sigmaSmall,sigmaBig);
----------------------------------------------------------------------------------------------------
simulateQNC.m (function)		: Simulates QNC with uniform quantizers
								[zTot,nEffTot,z]=simulateQNC(iterations,DeltaQ,xRange,x,A,F,B,PsiTot);
----------------------------------------------------------------------------------------------------
L1MINdecoder.m (function)		: L1-min Decoding using the calculated epsilonSquared (as in theorem)
								[recXl1min,recErrNorml1min]=L1MINdecoder(zTot,PsiTot,phi,x,DeltaQ,A,F,B);
----------------------------------------------------------------------------------------------------
PINVdecoder.m (function)		: Pseudo-inverse Decoding
								[recXPinv,recErrNormPinv]=PINVdecoder(zTot,PsiTot,phi,x);
----------------------------------------------------------------------------------------------------