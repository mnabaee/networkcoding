ReadMe file for:	 MATLAB\QuantizedNC\

**RUNNABLES*****************************************************

mainQNC.m			: Main Module for QNC
----------------------------------------------------------------------------------------------------
mainQNCdsgn.m		: Main Module for QNC, using the developed method of QNCodes
----------------------------------------------------------------------------------------------------
mainEPRemove.m		: Main Module for Testing Removal of Early Packets
----------------------------------------------------------------------------------------------------
mainRIP.m			: Main Module for RIP Analysis
----------------------------------------------------------------------------------------------------
mainRIPGaussian.m	: Main Module for RIP Analysis of designed NCodes and compare
                      with the IID Gaussian entries, in terms of concentration of norms
----------------------------------------------------------------------------------------------------
mainRIPdsgn.m		: Main Module for RIP Analysis, using designed Network Cododing
----------------------------------------------------------------------------------------------------
mainCoherence.m		: Main Module for Coherence Analysis
----------------------------------------------------------------------------------------------------
mainNorm.m      	: Main Module for Norm Analysis
----------------------------------------------------------------------------------------------------
mainGVector.m		: Main Module for Generating Good Vectors for Simulation-based Analysis of Error Bound

**FUNCTIONS*****************************************************

generateQNC.m		: Generates network deployment, inputs, network coding coefficients 
				  and parameters of Quantization
(function) [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,[sp]);
----------------------------------------------------------------------------------------------------
generateQNCdsgn.m	: Generates network deployment, inputs, network coding coefficients 
                        and parameters of Quantization, using the developed method.
(function) [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,[sp]);
----------------------------------------------------------------------------------------------------
generateQNCnorm.m	: Generates network deployment, inputs, network coding coefficients 
                        and parameters of Quantization, using the developed method, compatible (and
                        appropriate) for norm analysis (mainNorm.m)
(function) [htList,GWnode,x,phi,A,F,B]=generateQNC(nodes, edges, iterations,Delta,q,[sp]);
----------------------------------------------------------------------------------------------------
simulateQNC.m		: Simulates Quantized Network Coding
(function) [z,n,y,y2,zTot]=simulateQNC(nodes, edges, iterations ,htList,Delta,x,A,F,B);
----------------------------------------------------------------------------------------------------
calculateQNC.m		: Calculates Network Coding Transfer Function and Effective Noise
(function) [Psi,nEff,PsiTot,nEffTot,nEffTotNorm,coef,epsilon]=calculateQNC(nodes, edges, iterations,htList,[Delta],[x],[n],A,F,B);
----------------------------------------------------------------------------------------------------
ripQNC.m			: M file to analyze satisfaction of RIP of order '2*sp'
(function) [ratio,nlzRatio,meanRatio,ratioX]=ripQNC(nodes, iterations ,x,q,sp,Psi,PsiTot,phi);
----------------------------------------------------------------------------------------------------
L1minDec.m			: Decoding using L1-minimization
(function) [xRec{t}]=L1minDec(PsiTot{t},zTot{t},phi);
----------------------------------------------------------------------------------------------------
coherenceQNC.m		: M file to calculate coherence of Psi and PsiTot
(function) [coh,cohTot]=coherenceQNC(iterations ,Psi,PsiTot);
----------------------------------------------------------------------------------------------------
cohMat.m			: M file to calculate Coherence of a Matrix
(function) res=cohMat(A);
----------------------------------------------------------------------------------------------------
RandOrthMat.m		: Generates Random Orthonormal Matrix 
(function) M=RandOrthMat(n, tol);
----------------------------------------------------------------------------------------------------
generateQNC.m		: generates Network Coding Projection Matrix(!)
(function) [P,cncP,cncPnlzd,G,H]=genNCmat(conMat,GWnode,its,nrlzdFactor);
----------------------------------------------------------------------------------------------------