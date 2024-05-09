function [umat41, fittingError,ehtmmCurves] = ...
    fitEHTMMTendon(umat41, keyPointsTendon,ehtmmCurves)


errFcn = @(arg)calcEHTMMTendonError(arg,umat41,keyPointsTendon);

x0 =[1;1;1];

options=optimset('Display','off');
[argBest,resnorm,residual,exitflag]=lsqnonlin(errFcn,x0,[],[],options);
assert(exitflag==1);

errVal = errFcn(argBest);

fittingError=errVal;

umat41.dFSEE0   = umat41.dFSEE0*argBest(1,1);
umat41.duSEEl   = umat41.duSEEl*argBest(2,1);
umat41.dUSEEnll = umat41.dUSEEnll*argBest(3,1);

fceOptAT= umat41.fceOptAT;
lceOptAT= umat41.lceOptAT;
dUSEEnll= umat41.dUSEEnll;
duSEEl  = umat41.duSEEl;
lSEE0   = umat41.ltSlk;
dFSEE0  = umat41.dFSEE0;

lsee = calcFseeInverseUmat41(fceOptAT,lSEE0,dUSEEnll,duSEEl,dFSEE0);

umat41.et = (lsee-lSEE0)/lSEE0;

%%
%Sample the curves
%%
etIso   = umat41.et;

npts=100;
etN = [0:(etIso/(npts-1)):etIso]';
ltN = 1+etN;
ltN = [0;ltN];
ftN = zeros(size(ltN));
ktN = zeros(size(ltN));
for i=1:1:length(ltN)
    lt = ltN(i,1)*umat41.ltSlk;
    fsee = calcFseeUmat41(lt,lSEE0,dUSEEnll,duSEEl,dFSEE0);
    ksee = calcFseeDerUmat41(lt,lSEE0,dUSEEnll,duSEEl,dFSEE0);
    ftN(i,1)=fsee/umat41.fceOptAT;
    ktN(i,1)=ksee/(umat41.fceOptAT/umat41.ltSlk);
end

ehtmmCurves.ft.ltN=ltN;
ehtmmCurves.ft.ftN=ftN;
ehtmmCurves.ft.ktN=ktN;




