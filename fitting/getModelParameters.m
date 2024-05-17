function [mat156,umat41,umat43] = ...
    getModelParameters(commonParameterFolder,expAbbrv,...
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


%umat41 = getParametersUmat41(umat41ParameterFile);
umat41 = getAllParameterFieldsAndValues(umat41ParameterFile);
umat41.extraLines ={''};
if(contains(umat41ParameterFile,'HL2002')==1)
    umat41.extraLines = {   '*PARAMETER_EXPRESSION',...
                            '$#    name expression',...
                            'R       kt &dFSEE0/(&duSEEl*&ltSlk)'};
end

%umat43 = getParametersUmat43(umat43ParameterFile);
umat43 = getAllParameterFieldsAndValues(umat43ParameterFile);
umat43.extraLines = {''};



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
%    assert( abs(umat43.lceNScale -umat41.lceNScale)<tol,...
%        'Error: umat41 and umat43 differ at lceNScale'); 

end

%mat156 = getParametersMat156(mat156ParameterFile);
mat156 = getAllParameterFieldsAndValues(mat156ParameterFile);
mat156.extraLines = {''};


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
%    assert( abs(mat156.lceNScale -umat43.lceNScale)<tol,...
%        'Error: mat156 and umat43 differ at lceNScale'); 

end