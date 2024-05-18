function lt = calcEHTMMTendonLength(fmt,lSEE0,dUSEEnll,duSEEl,dFSEE0)

lt = zeros(size(fmt));

for i=1:1:length(lt)
    ft = fmt(i,1);
    lsee = calcFseeInverseUmat41(ft,lSEE0,dUSEEnll,duSEEl,dFSEE0);
    lt(i,1)=lsee;
end