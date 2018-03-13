tdate = today;
book = 'BOND';

[cusipHeld, parHeld] = importBook('Positions_STRIP.csv');
[PCAloadings] = importPCA('PCloadings.csv');
[cusipR, dataR] = importRefcos('Refcos.csv');

[cusipT, dataT, cusipS, dataS] = importData('Prices.csv');
[fdata, commodcode, commodcode2] = grabfut3(busdate(today,-1));
%[fdata, commodcode, commodcode2] = grabfut3(tdate);

[cusipT, dataT, initenorT] = cleanData(cusipT,dataT,tdate);
[cusipS, dataS, initenorS] = cleanData(cusipS,dataS,tdate);
[cusipR, dataR, initenorR] = cleanData(cusipR,dataR,tdate);

beta0 = DLL_onrun([0 1 1 0],dataT,cusipT,busdate(tdate,-1));
svenBeta = grabcoefs(busdate(tdate,-1),1,'US');

[Hcusip, Hdata] = hedgeData(tdate, cusipT, dataT, initenorT, fdata, commodcode);
[Bcusip, Bdata, parHeld_conv] = bookData(tdate, cusipHeld, parHeld, cusipS, dataS, initenorS, cusipT, dataT, initenorT, cusipR, dataR, fdata, commodcode, commodcode2);

[Bcusip,Bdata,parHedge,parBook] = extractHedge(Hdata,Bdata,Hcusip,Bcusip,parHeld_conv);

Hprices = Hdata(:,3)/100;
Bprices = Bdata(:,3)/100;

[cfmtrxH,nmtrxH] = cashFlows(tdate,Hdata);
[cfmtrxB,nmtrxB] = cashFlows(tdate,Bdata);

bookDuration = bnddurp(Bdata(:,3),Bdata(:,8)/100,busdate(tdate),x2mdate(Bdata(:,7)))./Bdata(:,12);
bookDv01 = bookDuration.*Bprices;

hedgeDuration = bnddurp(Hdata(:,3),Hdata(:,8)/100,busdate(tdate),x2mdate(Hdata(:,7)))./Hdata(:,12);
hedgeDv01 = hedgeDuration.*Hprices;

Donrun3 = (exponentialDuration(beta0,nmtrxH,cfmtrxH)*0.0001)./[Hdata(:,12),Hdata(:,12),Hdata(:,12)];
Dbook3  = (exponentialDuration(beta0,nmtrxB,cfmtrxB)*0.0001)./[Bdata(:,12),Bdata(:,12),Bdata(:,12)];
%Donrun3(:,1) = hedgeDuration*.0001;
%Dbook3(:,1) = bookDuration*.0001;

Donrun = Donrun3;%(:,1:2);
Dbook = Dbook3;%(:,1:2);


%%%%% Optimize Hedge

HedgeRoll = Roll(ones(length(Hcusip),1), tdate, Hdata, svenBeta, cfmtrxH, nmtrxH);
[hedgeWeights,hedgeWeightsVec,riskBook,riskHedge,riskCusipB,riskCusipH] = optimizeHedge(parHedge,parBook,Hprices,Bprices,Donrun,Dbook,Hdata,Bdata,HedgeRoll);

[round(hedgeWeights), parHedge]

pause

clearDatabase;

insertHedgeFactors(book,[riskCusipH,parHedge,hedgeWeights]);

%%%%% Write to File

Bcoups = Bdata(:,8);
Bmat   = Bdata(:,7);
Bpar   = parBook;
Bhedge = real(hedgeWeightsVec);
[rows,cols]=size(Bhedge);
Bhedge2 = round(Bhedge.*repmat(riskCusipH(:,1)',rows,1));
blank  = cell(length(Bcusip),1);
Brisk  = riskCusipB;

M = [Bcoups,Bmat,Bpar,Bhedge2,Brisk];

insertBook(book,Bcusip,M);
%insertOptimHedge(book,hedgeWeights');

		pause

		%%%%% Hedge Weights - All %%%%%

		%cusip = cusipS;
		%data = dataS;

		%zeroIDx = find(data(:,1)==0);
		%cusip(zeroIDx) = [];
		%data(zeroIDx,:) = [];

		%hedgeIDx = find(ismember(cusip, Hcusip)==1);
		%cusip(hedgeIDx) = [];
		%data(hedgeIDx,:) = [];
		%prices = data(:,3)/100;
		%[cfmtrx,nmtrx] = cashFlows(tdate,data);

		%allDuration = bnddurp(data(:,2),data(:,8)/100,busdate(tdate),x2mdate(data(:,7)));
		%allDv01 = allDuration.*prices;
		%Apar = 10000000*ones(length(cusip),1);

		%N = [Acoups,Amat,Apar,Aweights2,Arisk];
		%csvwrite('allNS.csv',N);

		%insertBook_HedgeWeights(book,cusip,N);

		%[hedgeDv01,hedgeWeights,riskCusipH] = OptimalHedge(tdate,beta0,svenBeta,'NS','BOND','Positions_BOND.csv',1);%Aweights2 = round(Aweights.*repmat(riskCusipH(:,1)'*10000000,rows,1));
%Arisk  = sheetRisk;


		%[rows,~]=size(Aweights);
		%Acoups = data(:,8);
		%Amat   = data(:,7);
		%Aweights = real(sheetWeights);
		%Dall3 = (exponentialDuration(beta0,nmtrx,cfmtrx)*0.0001);


		
		%[sheetWeights,sheetRisk] = hedgeSheet(Hprices,prices,Donrun,Dall,Hdata,data,HedgeRoll);
		%Dall3(:,1) = allDuration*.0001;

		%  Dall = Dall3;

%[sheetWeights,sheetRisk] = hedgeSheet(Hprices,prices,Donrun,Dall,Hdata,data,HedgeRoll);

%Acoups = data(:,8);
%Amat   = data(:,7);
%Aweights = real(sheetWeights);
%[rows,~]=size(Aweights);
%Aweights2 = round(Aweights.*repmat(riskCusipH(:,1)'*10000000,rows,1));
		%Arisk  = sheetRisk;
		%Apar = 10000000*ones(length(cusip),1);

		%N = [Acoups,Amat,Apar,Aweights2,Arisk];
		%csvwrite('allNS.csv',N);

		%insertBook_HedgeWeights(book,cusip,N);

		%[hedgeDv01,hedgeWeights,riskCusipH] = OptimalHedge(tdate,beta0,svenBeta,'NS','BOND','Positions_BOND.csv',1);
