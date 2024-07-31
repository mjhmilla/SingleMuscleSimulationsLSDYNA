%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%
function figH = addBrownScottLoeb1996ForceVelocity(...
                figH,subplotPosition, labelData, ...
                expColor,...
                vceMaxExp,...
                fileNameToAppendProcessedData,...
                idData)


fid=fopen(fileNameToAppendProcessedData,'a');

figure(figH);
subplot('Position',subplotPosition);

fileBSL1996fvCN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'force_velocity',filesep,...
           'fig_BrownScottLoeb1996_Fig8.csv']; 

fileBSL1996fvEN = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'force_velocity',filesep,...
           'fig_BrownScottLoeb1996_Fig9.csv']; 


dataBSL1996fvEN= csvread(fileBSL1996fvEN,1,0);
dataBSL1996fvCN= csvread(fileBSL1996fvCN,1,0);

plot(dataBSL1996fvEN(:,1)./vceMaxExp,...
     dataBSL1996fvEN(:,2),...
     's',...
     'Color',expColor,...
     'MarkerFaceColor',[1,1,1],...
     'MarkerSize',4,...
     'DisplayName',labelData,...
     'HandleVisibility','on');
hold on;

plot(dataBSL1996fvCN(:,1)./vceMaxExp,...
     dataBSL1996fvCN(:,2),...
     's',...
     'Color',expColor,...
     'MarkerFaceColor',[1,1,1],...
     'MarkerSize',4,...
     'DisplayName',labelData,...
     'HandleVisibility','off');
hold on;

for indexData=1:1:length(dataBSL1996fvCN(:,1))
    fprintf(fid,'%1.3f,%1.3f,%i,%i\n',...
            dataBSL1996fvCN(indexData,1)./vceMaxExp,...
            dataBSL1996fvCN(indexData,2),...
            idData,1);
end
for indexData=1:1:length(dataBSL1996fvEN(:,1))
    fprintf(fid,'%1.3f,%1.3f,%i,%i\n',...
            dataBSL1996fvEN(indexData,1)./vceMaxExp,...
            dataBSL1996fvEN(indexData,2),...
            idData,2);
end

fclose(fid);
