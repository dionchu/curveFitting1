function[cusipOut, dataOut] = hedgeData(tdate, cusip, data, initenor, fdata, commodcode)

  %%% Calculate On-the-Run and First/Second Off

  [onrun, tenor] = calconrun(data);

%%% Include Reference Notes

[refcusips,convfactors] = CTD(tdate, initenor, cusip, data, fdata,1);
    refmtrx = [commodcode',refcusips];

    data = [data,convfactors];

%%% Extract Hedge Instruments

      %%% refcusips [1 - WN; 2 - US; 3 - TY; 4 - FV; 5 - TU]

onrun(find(ismember(cusip, refcusips(2))==1)) = 1;
cusip(find(ismember(cusip, refcusips(2))==1)) = refmtrx(find(ismember(refmtrx(:,2), refcusips(2))==1),1);
onrun(find(ismember(cusip, refcusips(1))==1)) = 1;
cusip(find(ismember(cusip, refcusips(1))==1)) = refmtrx(find(ismember(refmtrx(:,2), refcusips(1))==1),1);

%%% Old Notes and Bonds

    cusipOut = cusip(onrun==1,:);
    initenorOut = initenor(onrun==1,:);
    dataOut = data(onrun==1,:);
   
