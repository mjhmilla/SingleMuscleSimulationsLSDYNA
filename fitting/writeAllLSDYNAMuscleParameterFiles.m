%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function success = writeAllLSDYNAMuscleParameterFiles(...
                        commonParameterFolder,expAbbrv,...
                        mat156,umat41,umat43,...
                        kbr1994ExtraParams)

mat156ParameterFile = fullfile(commonParameterFolder,...
                      ['catsoleus',expAbbrv,'Mat156Parameters.k']);

umat41ParameterFile = fullfile(commonParameterFolder,...
                      ['catsoleus',expAbbrv,'Umat41Parameters.k']);

umat43ParameterFile = fullfile(commonParameterFolder,...
                      ['catsoleus',expAbbrv,'Umat43Parameters.k']);


success156  = writeLSDYNAMuscleParameterFile(mat156ParameterFile,...
                                             mat156,mat156.extraLines);
success41   = writeLSDYNAMuscleParameterFile(umat41ParameterFile,...
                                             umat41,umat41.extraLines);
success43   = writeLSDYNAMuscleParameterFile(umat43ParameterFile,...
                                             umat43,umat43.extraLines);


if(contains(expAbbrv,'HL2002'))
    umat43KBR1994Fig3ParameterFile = fullfile(commonParameterFolder,...
                    ['catsoleusKBR1994Fig3Umat43Parameters.k']);

    umat43KBR1994Fig3           = umat43;
    umat43KBR1994Fig3.kxIsoN    = kbr1994ExtraParams.Fig3.kxIsoN;
    umat43KBR1994Fig3.dxIsoN    = kbr1994ExtraParams.Fig3.dxIsoN;

    success43KBR1994Fig3   = writeLSDYNAMuscleParameterFile(...
                                umat43KBR1994Fig3ParameterFile,...
                                umat43KBR1994Fig3,...
                                []);

    umat43KBR1994Fig12ParameterFile = fullfile(commonParameterFolder,...
                    ['catsoleusKBR1994Fig12Umat43Parameters.k']);

    umat43KBR1994Fig12          = umat43;
    umat43KBR1994Fig12.kxIsoN   = kbr1994ExtraParams.Fig12.kxIsoN;
    umat43KBR1994Fig12.dxIsoN   = kbr1994ExtraParams.Fig12.dxIsoN;

    success43KBR1994Fig12  = writeLSDYNAMuscleParameterFile(...
                                umat43KBR1994Fig12ParameterFile,...
                                umat43KBR1994Fig12,...
                                []);    
end


success = (success156 && success41 && success43);






