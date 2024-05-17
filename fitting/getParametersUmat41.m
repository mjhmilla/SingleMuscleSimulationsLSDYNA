function umat41 = getParametersUmat41(umat41ParameterFile)

umat41.lceOpt     = getParameterFieldValue(umat41ParameterFile,'lceOpt');
umat41.fceOpt     = getParameterFieldValue(umat41ParameterFile,'fceOpt');
umat41.lceOptAT   = getParameterFieldValue(umat41ParameterFile,'lceOptAT');
umat41.fceOptAT   = getParameterFieldValue(umat41ParameterFile,'fceOptAT');
umat41.lmtOptAT   = getParameterFieldValue(umat41ParameterFile,'lmtOptAT');
umat41.penOpt     = getParameterFieldValue(umat41ParameterFile,'penOpt');
umat41.penOptD    = getParameterFieldValue(umat41ParameterFile,'penOptD');
umat41.ltSlk      = getParameterFieldValue(umat41ParameterFile,'ltSlk');
umat41.et         = getParameterFieldValue(umat41ParameterFile,'et');
umat41.dFSEE0     = getParameterFieldValue(umat41ParameterFile,'dFSEE0');
umat41.dUSEEnll   = getParameterFieldValue(umat41ParameterFile, 'dUSEEnll');
umat41.duSEEl     = getParameterFieldValue(umat41ParameterFile, 'duSEEl');
umat41.vceMax     = getParameterFieldValue(umat41ParameterFile,'vceMax');
umat41.LPEE0      = getParameterFieldValue(umat41ParameterFile, 'LPEE0');
umat41.FPEE       = getParameterFieldValue(umat41ParameterFile, 'FPEE');   
umat41.nuPEE      = getParameterFieldValue(umat41ParameterFile, 'nuPEE');
umat41.dWasc      = getParameterFieldValue(umat41ParameterFile, 'dWasc');
umat41.nuCEasc    = getParameterFieldValue(umat41ParameterFile, 'nuCEasc');
umat41.dWdes      = getParameterFieldValue(umat41ParameterFile, 'dWdes');
umat41.nuCEdes    = getParameterFieldValue(umat41ParameterFile, 'nuCEdes');
umat41.Arel   = getParameterFieldValue(umat41ParameterFile, 'Arel');
umat41.Brel   = getParameterFieldValue(umat41ParameterFile, 'Brel');
umat41.Secc   = getParameterFieldValue(umat41ParameterFile, 'Secc');
umat41.Fecc   = getParameterFieldValue(umat41ParameterFile, 'Fecc');
umat41.lp0HL2002  =getParameterFieldValue(umat41ParameterFile,'lp0HL2002');
umat41.dtInt      = getParameterFieldValue(umat41ParameterFile,'dtInt');
umat41.dtOut      = getParameterFieldValue(umat41ParameterFile,'dtOut');
umat41.extraLines ={''};
if(contains(umat41ParameterFile,'HL2002')==1)
    umat41.extraLines = {   '*PARAMETER_EXPRESSION',...
                            '$#    name expression',...
                            'R       kt &dFSEE0/(&duSEEl*&ltSlk)'};
end
