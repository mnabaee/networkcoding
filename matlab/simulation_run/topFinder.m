function [xVec1,yVec1]=topFinder(data1X,data1Y);
xVal=0;
yVal=0;
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