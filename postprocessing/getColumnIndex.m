%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%%
function index = getColumnIndex(columnName, cellArrayOfColumnNames)

index=NaN;
i = 1;
while (i <= length(cellArrayOfColumnNames) && isnan(index)==1)
    if(strcmp(columnName,cellArrayOfColumnNames{i}))
        index=i;
    end
    i=i+1;
end

