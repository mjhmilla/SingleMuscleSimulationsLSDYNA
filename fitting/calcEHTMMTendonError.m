function tendonError = calcEHTMMTendonError(arg, umat41, keyPointsTendon)

fceOptAT=umat41.fceOptAT;
lceOptAT=umat41.lceOptAT;

dUSEEnll= umat41.dUSEEnll;
duSEEl  = umat41.duSEEl;
lSEE0   = umat41.ltSlk;
dFSEE0  = umat41.dFSEE0;
et      = umat41.et;



%Update the parameters being adjusted
dFSEE0   = dFSEE0*arg(1,1);
duSEEl   = duSEEl*arg(2,1);
dUSEEnll = dUSEEnll*arg(3,1);

%Term 1: strain at fiso
lsee = calcFseeInverseUmat41(fceOptAT,lSEE0,dUSEEnll,duSEEl,dFSEE0);
et = (lsee-lSEE0)/lSEE0;
etError = et-keyPointsTendon.etIso;

%Term 2: stiffness at fiso
ksee = calcFseeDerUmat41(lsee,lSEE0,dUSEEnll,duSEEl,dFSEE0);
kseeN = ksee/(fceOptAT/lSEE0);
kisoNError = kseeN-keyPointsTendon.ktNIso;

%tendonError = [etError;kisoNError];

%Terms 3-n: sampling of the toe region
ftNSampleError = zeros(size(keyPointsTendon.etSample));
for i=1:1:length(keyPointsTendon.etSample)
    et = keyPointsTendon.etSample(i,1);
    lsee = et*lSEE0+lSEE0;
    fsee = calcFseeUmat41(lsee,lSEE0,dUSEEnll,duSEEl,dFSEE0);
    ftN  = fsee/fceOptAT;
    ftNSampleError(i,1)= ftN-keyPointsTendon.ftNSample(i,1);
end

tendonError = [etError;kisoNError;ftNSampleError];







