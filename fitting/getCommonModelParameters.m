function [mat156,umat41,umat43] = ...
    getCommonModelParameters(commonParameterFolder,expAbbrv,...
                                flag_assertCommonParamsIdentical)

tol=1e-5;

mat156ParameterFile = fullfile(commonParameterFolder,...
                            ['catsoleus',expAbbrv,'Mat156Parameters.k']);

umat41ParameterFile = fullfile(commonParameterFolder,...
                            ['catsoleus',expAbbrv,'Umat41Parameters.k']);

umat43ParameterFile = fullfile(commonParameterFolder,...
                            ['catsoleus',expAbbrv,'Umat43Parameters.k']);

mat156CardFile = fullfile(commonParameterFolder,...
                            ['catsoleus',expAbbrv,'Mat156.k']);

umat41CardFile = fullfile(commonParameterFolder,...
                            ['catsoleus',expAbbrv,'Umat41.k']);

umat43CardFile = fullfile(commonParameterFolder,...
                            ['catsoleus',expAbbrv,'Umat43.k']);


%getLsdynaCardFieldValue(...
%                                  simulationInformation(indexSimulationInfo).musclePropertyCard,...
%                                  simulationInformation(indexSimulationInfo).pennationAngleDegrees);

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
umat41.vceMax     = getParameterFieldValue(umat41ParameterFile,'vceMax');
umat41.dtInt      = getParameterFieldValue(umat41ParameterFile,'dtInt');
umat41.dtOut      = getParameterFieldValue(umat41ParameterFile,'dtOut');
umat41.lceNScale  = getParameterFieldValue(umat41ParameterFile,'lceNScale');

umat41.LPEE0      = getParameterFieldValue(umat41ParameterFile, 'LPEE0');
umat41.FPEE       = getParameterFieldValue(umat41ParameterFile, 'FPEE');   
umat41.nuPEE      = getParameterFieldValue(umat41ParameterFile, 'nuPEE');
umat41.dWasc      = getParameterFieldValue(umat41ParameterFile, 'dWasc');
umat41.nuCEasc    = getParameterFieldValue(umat41ParameterFile, 'nuCEasc');
umat41.dWdes      = getParameterFieldValue(umat41ParameterFile, 'dWdes');
umat41.nuCEdes    = getParameterFieldValue(umat41ParameterFile, 'nuCEdes');

umat41.dUSEEnll   = getLsdynaCardFieldValue(umat41CardFile, 'dUSEEnll');
umat41.duSEEl     = getLsdynaCardFieldValue(umat41CardFile, 'duSEEl');




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
umat43.dtInt      =getParameterFieldValue(umat43ParameterFile,'dtInt');
umat43.dtOut      =getParameterFieldValue(umat43ParameterFile,'dtOut');
umat43.lceNScale  =getParameterFieldValue(umat43ParameterFile,'lceNScale');

if(flag_assertCommonParamsIdentical==1)

    assert( abs(umat43.lceOpt    -umat41.lceOpt   )<tol,...
        'Error: umat41 and umat43 differ at lceOpt'   ); 
    assert( abs(umat43.fceOpt    -umat41.fceOpt   )<tol,...
        'Error: umat41 and umat43 differ at fceOpt'   ); 
    assert( abs(umat43.lceOptAT  -umat41.lceOptAT )<tol,...
        'Error: umat41 and umat43 differ at lceOptAT' ); 
    assert( abs(umat43.fceOptAT  -umat41.fceOptAT )<tol,...
        'Error: umat41 and umat43 differ at fceOptAT' ); 
    assert( abs(umat43.lmtOptAT  -umat41.lmtOptAT )<tol,...
        'Error: umat41 and umat43 differ at lmtOptAT' ); 
    assert( abs(umat43.penOpt    -umat41.penOpt   )<tol,...
        'Error: umat41 and umat43 differ at penOpt'   ); 
    assert( abs(umat43.penOptD   -umat41.penOptD  )<tol,...
        'Error: umat41 and umat43 differ at penOptD'  ); 
    assert( abs(umat43.ltSlk     -umat41.ltSlk    )<tol,...
        'Error: umat41 and umat43 differ at ltSlk '   ); 
    assert( abs(umat43.et        -umat41.et       )<tol,...
        'Error: umat41 and umat43 differ at et    '   ); 
    if( abs(umat41.vceMax    -umat43.vceMax   )<tol )
        disp('Note: mat156 and umat43 differ at vceMax (expected due to pennation)');
    end    
    assert( abs(umat43.dtOut     -umat41.dtOut    )<tol,...
        'Error: umat41 and umat43 differ at dtOut '   ); 
    assert( abs(umat43.lceNScale -umat41.lceNScale)<tol,...
        'Error: umat41 and umat43 differ at lceNScale'); 

end


mat156.lceOpt     =getParameterFieldValue(mat156ParameterFile,'lceOpt');
mat156.fceOpt     =getParameterFieldValue(mat156ParameterFile,'fceOpt');
mat156.lceOptAT   =getParameterFieldValue(mat156ParameterFile,'lceOptAT');
mat156.fceOptAT   =getParameterFieldValue(mat156ParameterFile,'fceOptAT');
mat156.lmtOptAT   =getParameterFieldValue(mat156ParameterFile,'lmtOptAT');
mat156.penOpt     =getParameterFieldValue(mat156ParameterFile,'penOpt');
mat156.penOptD    =getParameterFieldValue(mat156ParameterFile,'penOptD');
mat156.ltSlk      =getParameterFieldValue(mat156ParameterFile,'ltSlk');
mat156.et         =getParameterFieldValue(mat156ParameterFile,'et');
mat156.vceMax     =getParameterFieldValue(mat156ParameterFile,'vceMax');
mat156.dtInt      =getParameterFieldValue(mat156ParameterFile,'dtInt');
mat156.dtOut      =getParameterFieldValue(mat156ParameterFile,'dtOut');
mat156.lceNScale  =getParameterFieldValue(mat156ParameterFile,'lceNScale');


if(flag_assertCommonParamsIdentical==1)

    assert( abs(mat156.lceOpt    -umat43.lceOpt   )<tol,...
        'Error: mat156 and umat43 differ at lceOpt'   ); 
    assert( abs(mat156.fceOpt    -umat43.fceOpt   )<tol,...
        'Error: mat156 and umat43 differ at fceOpt'   ); 
    assert( abs(mat156.lceOptAT  -umat43.lceOptAT )<tol,...
        'Error: mat156 and umat43 differ at lceOptAT' ); 
    assert( abs(mat156.fceOptAT  -umat43.fceOptAT )<tol,...
        'Error: mat156 and umat43 differ at fceOptAT' ); 
    assert( abs(mat156.penOpt    -umat43.penOpt   )<tol,...
        'Error: mat156 and umat43 differ at penOpt'   ); 
    assert( abs(mat156.penOptD   -umat43.penOptD  )<tol,...
        'Error: mat156 and umat43 differ at penOptD'  ); 
    assert( abs(mat156.et        -umat43.et       )<tol,...
        'Error: mat156 and umat43 differ at et    '   ); 
    if( abs(mat156.vceMax    -umat43.vceMax   )<tol )
        disp('Note: mat156 and umat43 differ at vceMax (expected due to pennation)');
    end
    assert( abs(mat156.dtOut     -umat43.dtOut    )<tol,...
        'Error: mat156 and umat43 differ at dtOut '   ); 
    assert( abs(mat156.lceNScale -umat43.lceNScale)<tol,...
        'Error: mat156 and umat43 differ at lceNScale'); 

end