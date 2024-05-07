function [umat41, fittingError] = fitEHTMMTendon(umat41, fitTendonParams)


errFcn = @(arg)calcEHTMMTendonError(arg,umat41,fitTendonParams);

x0 =[1;1;1];

options=optimset('Display','off');
[argBest,resnorm,residual,exitflag]=lsqnonlin(errFcn,x0,[],[],options);
assert(exitflag==1);

errVal = errFcn(argBest);

fittingError=errVal;

umat41.dFSEE0   = umat41.dFSEE0*argBest(1,1);
umat41.duSEEl   = umat41.duSEEl*argBest(2,1);
umat41.dUSEEnll = umat41.dUSEEnll*argBest(3,1);

fceOptAT=umat41.fceOptAT;
lceOptAT=umat41.lceOptAT;
dUSEEnll= umat41.dUSEEnll;
duSEEl  = umat41.duSEEl;
lSEE0   = umat41.ltSlk;
dFSEE0  = umat41.dFSEE0;

lsee = calcFseeInverseUmat41(fceOptAT,lSEE0,dUSEEnll,duSEEl,dFSEE0);

umat41.et = (lsee-lSEE0)/lSEE0;



here=1;


