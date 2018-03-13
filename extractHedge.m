function[BcusipOut,BdataOut,parHedgeOut,parBookOut] = extractHedge(Hdata,Bdata,hedgeString,bookString,parBookIn)

  idx = zeros(length(bookString),1);
parHedgeOut = zeros(length(hedgeString),1);

for i=1:length(bookString)
	if(sum(strcmp(bookString{i},hedgeString))>0)
	  idx(i) = 1;
	else
	  idx(i) = 0;
    end
      end

    for i=1:length(hedgeString)
	    matchvec = strcmp(hedgeString(i),bookString);
if(sum(matchvec)>0)
  parHedgeOut(i) = parBookIn(matchvec==1);
 else
   parHedgeOut(i) = 0;
    end
      end


    BcusipOut = bookString(idx==0);
BdataOut  = Bdata(idx==0,:);
parBookOut = parBookIn(idx==0,:);

%% set STRIPS first coupon date equal to maturity
BdataOut(BdataOut(:,6)==0,6)=BdataOut(BdataOut(:,6)==0,7);
