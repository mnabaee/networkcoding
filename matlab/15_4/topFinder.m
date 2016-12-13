function [RESxVec1,RESyVec1]=topFinder(data1X,data1Y);
nmPts=50;
[mmm1,mmm2]=min(data1X);
xVal=mmm1-1;
yVal=data1Y(mmm2);
xVec1=[];
yVec1=[];
while(1)
    inds=find(((data1X>xVal)&(data1Y>yVal)));
    if(isempty(inds)==1)
        break;
    end
    data1X=data1X(inds);
    data1Y=data1Y(inds);
    [m1,m2]=min(data1X-xVal);
    xVal=data1X(m2(1));
    [yVal]=max(data1Y(m2));
    xVec1=[xVec1 xVal];
    yVec1=[yVec1 yVal];
end


%%%Interpolate the Curve
Xmin=min(xVec1);
Xmax=max(xVec1);
nmPts;
trgXvec=linspace(Xmin,Xmax,nmPts);

RESxVec1=trgXvec;
RESyVec1=interp1(xVec1,yVec1,RESxVec1);

%%%
RESxVec1=xVec1;
RESyVec1=yVec1;
