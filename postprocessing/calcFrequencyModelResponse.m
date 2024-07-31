%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function y = calcFrequencyModelResponse(k, beta, omega)

y = k + (beta*complex(0,1)).*omega;