classdef Quantizer
    properties
        range
        intervals
        centerPts
        stepSize
    end
    methods
        %Function: Creates Quantizer for Uniform Quantization
        function Q=uniformQuantizer(Q,range,numBits)
            numIntervals=2^numBits;
            Q.range=range;
            for i=1:numIntervals
                Q.centerPts(i)=range(1)+(range(2)-range(1))/numIntervals*(i-.5);
                Q.intervals(i,1)=range(1)+(range(2)-range(1))/numIntervals*(i-1);
                Q.intervals(i,2)=range(1)+(range(2)-range(1))/numIntervals*(i);
            end
            Q.stepSize=(Q.range(2)-Q.range(1))/(numIntervals);
        end
        %Function: Creates Quantizer for Uniform QuantizationShifted
        function Q=uniformQuantizerShifted(Q,range,numBits)
            numIntervals=2^numBits;
            inds=[1:numIntervals]';
                Q.centerPts=range(1)+(range(2)-range(1))/numIntervals*(inds-0);
                Q.intervals(:,1)=range(1)+(range(2)-range(1))/numIntervals*(inds-.5);
                Q.intervals(:,2)=range(1)+(range(2)-range(1))/numIntervals*(inds+.5);
            Q.range(1)=min(Q.intervals(:,1));
            Q.range(2)=max(Q.intervals(:,2));
            Q.stepSize=(Q.range(2)-Q.range(1))/(numIntervals);
        end
        %Function: Performs Quantization
        function Qval=performQ(Q,val)
            Qval=zeros(size(val));
            for l=1:length(val)
                r=find((Q.intervals(:,1)<=val(l))&(Q.intervals(:,2)>val(l)));
                if(isempty(r))
                    if(val(l)>= Q.range(2))
                        Qval(l)=Q.centerPts(end);
                    elseif(val(l)<= Q.range(1))
                        Qval(l)=Q.centerPts(1);
                    else
                        error('Quantizer Fault!');
                    end
                else
                    Qval(l)=Q.centerPts(r);
                end
            end
        end
        %Function: Performs Uniform Quantization (Shifted)
        function Qval=performUQshifted(Q,val)
            Qval=zeros(size(val));
            for l=1:length(val)
                if((val(l)<=Q.range(2))&(val(l)>= Q.range(1)))
                    Qval(l)=(floor((val(l)-Q.range(1))/Q.stepSize)+.5)*Q.stepSize+Q.range(1);
                elseif(val(l)>= Q.range(2))
                    Qval(l)=Q.centerPts(end);
                elseif(val(l)<= Q.range(1))
                    Qval(l)=Q.centerPts(1);
                else
                    error('Quantizer Fault!'); 
                end
            end
        end
    end
end