function[loadMatrix] = factorLoadings(lambda,nmtrx)

  [~,cols] = size(nmtrx);

f1Loading = ones(1,cols);
f2Loading = lambda./nmtrx.*(1-exp(-nmtrx./lambda));
f3Loading = lambda./nmtrx.*(1-exp(-nmtrx./lambda))-exp(-nmtrx./lambda);

loadMatrix = [f1Loading',f2Loading',f3Loading'];
loadMatrix = ZeroNaN(loadMatrix);
