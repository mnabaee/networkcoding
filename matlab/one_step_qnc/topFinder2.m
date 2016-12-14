function [resX,resY]=topFinder2(data1Xin,data1Yin);
data1X=data1Xin;
data1Y=data1Yin;

[mm1,mm2]=min(data1X);
xVal=mm1-1;
yVal=data1Y(mm2);

% xVal=0;
% yVal=0;
xVec1=[];
yVec1=[];
while(1)
    inds=find(((data1X>xVal)&(data1Y>=yVal)));
    if(isempty(inds)==1)
        size(xVec1);
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
resX=xVec1;
resY=yVec1;

data1X=data1Xin;
data1Y=data1Yin;

[mm1,mm2]=max(data1X);
xVal=mm1+1;
yVal=data1Y(mm2);
xVec1=[];
yVec1=[];
while(1)
    inds=find(((data1X<xVal)&(data1Y>=yVal)));
    if(isempty(inds)==1)
        break;
    end
    data1X=data1X(inds);
    data1Y=data1Y(inds);
    [m1,m2]=min(-data1X+xVal);
    xVal=data1X(m2(1));
    [yVal]=max(data1Y(m2));
    xVec1=[xVec1 xVal];
    yVec1=[yVec1 yVal];
end

resX=[resX xVec1];
resY=[resY yVec1];

[s1,s2]=sort(resX);
resX=resX(s2);
resY=resY(s2);