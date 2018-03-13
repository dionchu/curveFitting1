function[expDur] = exponentialDuration(beta,nmtrx,cfmtrx)


  b=isnan(nmtrx);
cfmtrx(b)=0;
nmtrx = ZeroNaN(nmtrx);
[rows,cols] = size(cfmtrx);


zerorates = beta(1)+(beta(2)+beta(3))*beta(4)./nmtrx.*(1-exp(-nmtrx./beta(4)))-beta(3)*exp(-nmtrx./beta(4));
discfn = exp(-(zerorates./100).*nmtrx);
discfn(b)=0;

expDur = zeros(rows,3);

for i=1:rows

	discCfs   = discfn(i,:).*cfmtrx(i,:);
weights   = discCfs/sum(discCfs);
Dvec      = (weights.*nmtrx(i,:));
B = factorLoadings(beta(4),nmtrx(i,:));

expDur(i,:)    = Dvec*B;

end
