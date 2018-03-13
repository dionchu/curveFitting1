function[Roll] = Roll(currentWeights, tdate, data, svenBeta, cfmtrx, nmtrx)

  beta = svenBeta;
[rows,cols] = size(nmtrx);
adjmtrx = ones(rows,cols)*(1/12);
b=isnan(nmtrx);
adjmtrx(b)=NaN;
fmtrx = nmtrx-adjmtrx;

zerorates = beta(1)+(beta(2)+beta(3))*beta(5)./nmtrx.*(1-exp(-nmtrx./beta(5)))-beta(3)*exp(-nmtrx./beta(5))+beta(4).*((1-exp(-nmtrx./beta(6))).*(beta(6)./nmtrx)-exp(-nmtrx./beta(6)));

zeroratesF = beta(1)+(beta(2)+beta(3))*beta(5)./fmtrx.*(1-exp(-fmtrx./beta(5)))-beta(3)*exp(-fmtrx./beta(5))+beta(4).*((1-exp(-fmtrx./beta(6))).*(beta(6)./fmtrx)-exp(-fmtrx./beta(6)));


%forwardrates = (1./mmtrx).*(matmtrx.*zerorates-nmtrx.*zeroratesN);


discfn = exp(-(zerorates./100).*nmtrx);
discfn(b)=0;

fdiscfn = exp(-(zeroratesF./100).*fmtrx);
fdiscfn(b)=0;

tFitprices = sum(discfn.*cfmtrx,2);
fFitprices = sum(fdiscfn.*cfmtrx,2);

yield = bndyield(data(:,2),data(:,8)/100,busdate(tdate),x2mdate(data(:,7)))/12;

Roll = (fFitprices - tFitprices)./tFitprices;
RollRtn = -sum(Roll.*currentWeights);
