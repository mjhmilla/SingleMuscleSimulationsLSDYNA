function umat43 = getParametersUmat43(umat43ParameterFile)



umat43.lceOpt     =getParameterFieldValue(umat43ParameterFile,'lceOpt');
umat43.fceOpt     =getParameterFieldValue(umat43ParameterFile,'fceOpt');
umat43.lceOptAT   =getParameterFieldValue(umat43ParameterFile,'lceOptAT');
umat43.fceOptAT   =getParameterFieldValue(umat43ParameterFile,'fceOptAT');
umat43.lmtOptAT   =getParameterFieldValue(umat43ParameterFile,'lmtOptAT');
umat43.penOpt     =getParameterFieldValue(umat43ParameterFile,'penOpt');
umat43.penOptD    =getParameterFieldValue(umat43ParameterFile,'penOptD');
umat43.ltSlk      =getParameterFieldValue(umat43ParameterFile,'ltSlk');
umat43.et         =getParameterFieldValue(umat43ParameterFile,'et');
umat43.vceMax     =getParameterFieldValue(umat43ParameterFile,'vceMax');
umat43.shiftPEE   =getParameterFieldValue(umat43ParameterFile,'shiftPEE');
umat43.scalePEE   =getParameterFieldValue(umat43ParameterFile,'scalePEE');
umat43.lambdaECM  =getParameterFieldValue(umat43ParameterFile,'lambdaECM');
umat43.lPevkPtN   =getParameterFieldValue(umat43ParameterFile,'lPevkPtN');
umat43.lceHNLb1A  =getParameterFieldValue(umat43ParameterFile,'lceHNLb1A');
umat43.beta1AHN   =getParameterFieldValue(umat43ParameterFile,'beta1AHN');
umat43.lp0HL2002  =getParameterFieldValue(umat43ParameterFile,'lp0HL2002');
umat43.dtInt      =getParameterFieldValue(umat43ParameterFile,'dtInt');
umat43.dtOut      =getParameterFieldValue(umat43ParameterFile,'dtOut');
umat43.extraLines ={''};
