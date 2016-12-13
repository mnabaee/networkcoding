classdef packet_general < handle
	properties (Hidden)
		mSize;
		mBitStream;
	end
	methods
		function newP = packet_general(p)
			if(nargin==0)
				newP.mSize = 0;
				newP.mBitStream = [];
			else
				newP.mSize = p.mSize;
				newP.mBitStream = p.mBitStream;
			end
		end
		function newP = clone(p)
			newP = packet_general;
			newP.mSize = p.mSize;
			newP.mBitStream = p.mBitStream;
		end
		function addToEnd(p,newBitStream)
			if(length(newBitStream)>0)
				if(size(newBitStream,1)==1)
					p.mBitStream = [p.mBitStream newBitStream];
					p.mSize = p.mSize + length(newBitStream);
				elseif(size(newBitStream,2)==1)
					p.mBitStream = [p.mBitStream newBitStream'];
					p.mSize = p.mSize + length(newBitStream);
				else
					error('addToEnd Error!');
				end
			end
		end
		function [poppedBits]=popFromBegin(p,numBits)
			poppedBits = [];
			if(numBits>0)
				if(numBits>p.mSize)
					error('popFromBegin Error!');
				end
				poppedBits = p.mBitStream(1:numBits);
				p.mBitStream(1:numBits)=[];
				p.mSize = p.mSize - numBits;
			end
		end
		function [bitString] = get_all(p)
			bitString = p.mBitStream;
		end
		function [readBits]=readSubBits(p,init_index,len)
			readBits = [];
			if(init_index<1)
				error('readSubBits Error!');
			end
			if(init_index + len -1 > p.mSize)
				error('readSubBits Error!');
			end
			readBits = p.mBitStream(init_index:init_index+len-1);
		end
		function return_size = getSize(p)
			return_size = p.mSize;
		end
		function [resDist]=calculate_Hamming_dist(p1,p2)
			if(p1.getSize ~= p2.getSize)
				resDist = -1;
			else
				resDist = sum(abs(p1.mBitStream-p2.mBitStream));
			end
		end
		function print_this(p)
			disp(['--mSize=' num2str(p.mSize) ' mBitStream= ' num2str(p.mBitStream)]);
		end
	end
end
