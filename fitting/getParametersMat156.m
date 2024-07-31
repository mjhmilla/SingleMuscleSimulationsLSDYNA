%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function mat156 = getParametersMat156(mat156ParameterFile)

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
mat156.lp0HL2002  =getParameterFieldValue(mat156ParameterFile,'lp0HL2002');
%mat156.lceNScale  =getParameterFieldValue(mat156ParameterFile,'lceNScale');
mat156.extraLines ={''};