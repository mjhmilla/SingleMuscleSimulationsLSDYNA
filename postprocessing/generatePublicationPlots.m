function [figPublication,...
          flag_figPublicationDirty] ...
            = generatePublicationPlots(...
                    figPublication,...
                    simulationTypeStr,...
                    binout,uniformModelData,d3hspFileName,...
                    indexColumn,subPlotPanelSpecific,...
                    numberOfVerticalPlotRowsSpecific,...
                    numberOfHorizontalPlotColumnsSpecific,... 
                    simulationDirectoryName,...
                    indexSimulationTrial,...
                    numberOfSimulationDirectories,...
                    referenceDataFolder,...
                    muscleArchitecture,...
                    flag_figPublicationDirty,...
                    simulationColorA, simulationColorB,...
                    dataColorA, dataColorB)

lceOpt  = muscleArchitecture.lceOpt;
fiso    = muscleArchitecture.fiso;
ltslk   = muscleArchitecture.ltslk;
alpha   = muscleArchitecture.alpha;

switch (simulationTypeStr)
    case 'eccentric'
        flag_addSimulationData=1;
        flag_addReferenceData =1;                
        if(flag_figPublicationDirty==0)
            flag_figPublicationDirty=1;
        else
          flag_addReferenceData = 0;
        end
        indexColumn=1;
        figPublication =...
            plotEccentricSimulationDataForPublication(figPublication,...
                binout,uniformModelData,d3hspFileName,...
                indexColumn,subPlotPanelSpecific,...
                numberOfVerticalPlotRowsSpecific,...
                numberOfHorizontalPlotColumnsSpecific,...                              
                simulationDirectoryName,...
                indexSimulationTrial, numberOfSimulationDirectories,...
                referenceDataFolder,...         
                lceOpt,fiso,ltslk,...
                flag_addReferenceData,flag_addSimulationData,...
                simulationColorA,simulationColorB,...
                dataColorA,dataColorB);
    case 'concentric'
        disp('No concentric publication plot');
    case 'isometric'
        disp('No isometric publication plot');
    case 'quickrelease'
        disp('No quickrelease publication plot'); 
    case 'impedance'
        disp('No impedance publication plot'); 
    case 'force_length'
        disp('No force_length publication plot'); 
    case 'sinusoid'
        disp('No sinusoid publication plot'); 
    case 'reflex'    
        disp('No reflex publication plot'); 
    case 'reflex_kN_mm_ms'    
        disp('No reflex_kN_mm_ms publication plot'); 
                                           
        
end