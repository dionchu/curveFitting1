function[hedgeWeights,hedgeWeightsVec,riskBook,riskHedge,riskCusipB,riskCusipH] = optimizeHedge(parHedge,parBook,Hprices,Bprices,Donrun,Dbook,Hdata,Bdata,maxVecH)

  %%%%% Optimize Hedge

  currentWeights = parHedge.*Hprices;
Pbook  = parBook.*Bprices;

Options=optimset('fmincon');
Options = optimset(Options,'MaxFunEvals',100000,'TolFun',1e-005,'TolX',1e-005,'algorithm','interior-point');

[optimWeights] = fmincon('hedgePortfolio',currentWeights,[],[],Donrun',Dbook'*Pbook,[],[],[],Options);

optimPar = optimWeights./Hprices;

%%%%% Optimize Hedge Max Roll

bidAskH = 1+(Hdata(:,1)-Hdata(:,3))./Hdata(:,2);
bidAskB = 1+(Bdata(:,1)-Bdata(:,3))./Bdata(:,2);

A = Donrun';
B = diag(bidAskH.*bidAskH);
b = Dbook'*Pbook;
c = maxVecH;

x = laGrange(c,A,-b,B);
riskHedge = Donrun'*x;
riskBook = Dbook'*Pbook;

hedgeWeights = x./Hprices;
%hedgePar = x./Hprices;

%%%%% Optimize Hedge Max Roll

hedgeWeightsVec = zeros(length(Bprices),length(Hprices));

for i=1:length(Bprices)

	b = Dbook(i,:)'*Bprices(i);
  hedgeWeightsVec(i,:) =parBook(i)*laGrange(c,A,b,B)'./Hprices';

end

riskCusipB = Dbook.*[Pbook,Pbook,Pbook];
riskCusipH = Donrun.*[Hprices,Hprices,Hprices];
