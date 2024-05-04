function tendonError = calcEHTMMTendonError(arg, umat41, fitTendonParams)

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

%Get the strain at fceOptAT;
lsee = calcFseeInverseUmat41(fceOptAT,lSEE0,dUSEEnll,duSEEl,dFSEE0);

et = (lsee-lSEE0)/lSEE0;
etError = et-fitTendonParams.etIso;

ksee = calcFseeDerUmat41(lsee,lSEE0,dUSEEnll,duSEEl,dFSEE0);

kseeN = ksee/(fceOptAT/lSEE0);

kisoNError = kseeN-fitTendonParams.ktNIso;

tendonError = [etError;kisoNError];







