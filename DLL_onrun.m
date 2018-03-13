function[beta] = DLL_onrun(beta0,data,cusip,tdate)

  %%%%%%%%%%%%%%%%%%%%% sort and clean data %%%%%%%%%%%%%%%%

  %%%%%%%%%%%%%%%% level 1: by maturity
  %%%%%%%%%%%%%%%% level 2: by tenor

  initenor = round((data(:,7)-data(:,5))/365.25);

cusip = sortcell([cusip, num2cell(initenor), num2cell(data(:,7))],-2);
cusip = sortcell(cusip, 3);
cusip(:,2:end) = [];

data = sortrows([initenor, data],-1);
data = sortrows(data, 8);
initenor = data(:,1);
data(:,1) = [];


%%%%%%%%%%%%%%%%%%%%%% filter quotes %%%%%%%%%%%%%%%%%%%%%

%%% T-Bills
cusip(data(:,8)==0,:)=[];
initenor(data(:,8)==0,:)=[];
data(data(:,8)==0,:)=[];

%%% less than 80 days
cusip((x2mdate(data(:,7))-tdate)<80,:)=[];
initenor((x2mdate(data(:,7))-tdate)<80,:)=[];
data((x2mdate(data(:,7))-tdate)<80,:)=[];

%%% Calculate On-the-Run and First/Second Off

[onrun, tenor] = calconrun(data);
tenor(onrun~=0,1);

%%% Include Reference Notes

refnotes = grabmark2(tdate-1,cusip,1);

%%% Old Notes and Bonds
cusip(onrun==0 & refnotes==0,:)=[];
initenor(onrun==0 & refnotes==0,:)=[];
data(onrun==0 & refnotes==0,:)=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% datemtrx %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% c1: Issue Date %% c2: First Coup. Date %% c3: Maturity Date %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datemtrx = x2mdate(data(:,5:7));

%%%%%%%%%%%%%%%%%%%%%%%% coupons %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

coupons = data(:,8);

%%%%%%%%%%%%%%%%%%%%%%% settle date %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settle = ones(length(datemtrx(:,1)),1)*(busdate(tdate));
b = datemtrx(:,1)>(busdate(tdate));
c = datemtrx(:,3)==(tdate);
settle(b)=datemtrx(b,1);
settle(c)=tdate;

%%%%%%%%%%%%%%%%%%%%%%% cfdatemtrx/nmtrx%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Back out coupon payment date vectors for each security %%%%%%%
%%%%% Back out years to maturity vectors for each security %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfdatemtrx=cfdates(settle,datemtrx(:,3),2,0,1,datemtrx(:,1),datemtrx(:,2));
[rows,cols] = size(cfdatemtrx);
nmtrx = zeros(rows,cols);

for i=1:rows
	nmtrx(i,:) = (cfdatemtrx(i,:)-settle(i))/365.25;
end

cfdatemtrx=ZeroNaN(cfdatemtrx);
cfmtrx = zeros(rows,cols);

%%%%% Dirty Prices

AccruInterest = acrubond(datemtrx(:,1),settle,datemtrx(:,2),100,data(:,8)./100,2,0);
DirtyPrices   = data(:,2) + AccruInterest;

%%%%% Duration Weights

duration = bnddurp(DirtyPrices,data(:,8)./100,settle,datemtrx(:,3),2,0,1);
invdur = 1./duration;

%%%%% Cash-Flows

for i=1:rows
	for j=1:cols
		if (cfdatemtrx(i,j) == datemtrx(i,3) && cfdatemtrx(i,j) ~=0 )
		  cfmtrx(i,j)=coupons(i)/2+100;
elseif (cfdatemtrx(i,j) ~= datemtrx(i,3) && cfdatemtrx(i,j) ~=0)
cfmtrx(i,j) = coupons(i)/2;
        end
	    end
	end

	%%%%% Optimization
	combmtrx = [nmtrx, cfmtrx, invdur];
Options=optimset('lsqcurvefit');
Options = optimset(Options,'MaxFunEvals',100000,'TolFun',1e-005,'TolX',1e-005);
lb = [-Inf -Inf -Inf 0];
ub = [Inf Inf Inf 7];
[beta]=lsqcurvefit('nsprice',beta0,combmtrx,DirtyPrices.*invdur,lb,ub,Options);

