function[fitprices] = nsprice(beta, combmtrx)

  [~,cols] = size(combmtrx);

nmtrx=combmtrx(1:end,1:(cols-1)/2);
cfmtrx=combmtrx(1:end,(cols-1)/2+1:(cols-1));
invdur=combmtrx(1:end,cols);
b=isnan(nmtrx);
cfmtrx(b)=0;

zerorates = beta(1)+(beta(2)+beta(3))*beta(4)./nmtrx.*(1-exp(-nmtrx./beta(4)))-beta(3)*exp(-nmtrx./beta(4));
discfn = exp(-(zerorates./100).*nmtrx);
discfn(b)=0;
fitprices = sum(discfn.*cfmtrx,2).*invdur;
