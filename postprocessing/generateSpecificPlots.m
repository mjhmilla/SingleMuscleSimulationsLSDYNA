function [figSpecific,figDebug,...
          flag_figSpecificDirty,flag_figDebugDirty,...
          impedancePlotCounter] ...
            = generateSpecificPlots(...
                    figSpecific,figDebug,...
                    modelNameStr,...
                    simulationTypeStr,...
                    simulationInformationEntry,...                    
                    binout,musout,uniformModelData,d3hspFileName,...
                    indexColumn,subPlotPanelSpecific,...
                    numberOfVerticalPlotRowsSpecific,...
                    numberOfHorizontalPlotColumnsSpecific,... 
                    simulationDirectoryName,...
                    indexSimulationTrial,...
                    numberOfSimulationDirectories,...
                    referenceDataFolder,...
                    muscleArchitecture,...
                    flag_figSpecificDirty, flag_figDebugDirty,...
                    simulationColorA, simulationColorB,...
                    dataColorA, dataColorB,...
                    impedancePlotCounter)

lceOpt  = muscleArchitecture.lceOpt;
fiso    = muscleArchitecture.fiso;
ltslk   = muscleArchitecture.ltslk;
alpha   = muscleArchitecture.alpha;

switch (simulationTypeStr)
    case 'eccentric_HerzogLeonard2002'
        flag_addSimulationData=1;
        flag_addReferenceData =1;                
        if(flag_figSpecificDirty==0)
            flag_figSpecificDirty=1;
        else
          flag_addReferenceData = 0;
        end
        indexColumn=1;
        figSpecific =...
            plotEccentricSimulationData(figSpecific,...
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
    case 'concentric_Guenther2007'
        flag_addSimulationData=1;
        if(flag_figSpecificDirty==0)
          flag_addReferenceData=1;
          flag_figSpecificDirty=1;
        else
          flag_addReferenceData = 0;
        end
        indexColumn=1;
        figSpecific =...
            plotConcentricSimulationData(figSpecific,binout,uniformModelData,...
                indexColumn,subPlotPanelSpecific,...
                numberOfVerticalPlotRowsSpecific,...
                numberOfHorizontalPlotColumnsSpecific,...                              
                simulationDirectoryName,...
                indexSimulationTrial, numberOfSimulationDirectories,...
                referenceDataFolder,...
                flag_addReferenceData,flag_addSimulationData,...
                simulationColorA,simulationColorB,...
                dataColorA,dataColorB);
    case 'isometric_Guenther2007'
        flag_addSimulationData=1;
        if(flag_figSpecificDirty==0)
          flag_addReferenceData=1;
          flag_figSpecificDirty=1;
        else
          flag_addReferenceData = 0;
        end
        indexColumn=1;
        figSpecific =...
            plotIsometricSimulationData(figSpecific,binout,uniformModelData,...
                indexColumn,subPlotPanelSpecific,...
                numberOfVerticalPlotRowsSpecific,...
                numberOfHorizontalPlotColumnsSpecific,...                              
                simulationDirectoryName,...
                indexSimulationTrial, numberOfSimulationDirectories,...
                referenceDataFolder,...
                flag_addReferenceData,flag_addSimulationData,...
                simulationColorA,simulationColorB,...
                dataColorA,dataColorB);

    case 'quickrelease_Guenther2007'
        flag_addSimulationData=1;
        if(flag_figSpecificDirty==0)
          flag_addReferenceData=1;
          flag_figSpecificDirty=1;
        else
          flag_addReferenceData = 0;
        end
        indexColumn=1;
        figSpecific =...
            plotQuickReleaseSimulationData(figSpecific,binout,uniformModelData,...
                indexColumn,subPlotPanelSpecific,...
                numberOfVerticalPlotRowsSpecific,...
                numberOfHorizontalPlotColumnsSpecific,...                              
                simulationDirectoryName,...
                indexSimulationTrial, numberOfSimulationDirectories,...
                referenceDataFolder,...
                flag_addReferenceData,flag_addSimulationData,...
                simulationColorA,simulationColorB,...
                dataColorA,dataColorB);   
    case 'impedance_Kirsch1997'
        flag_addSimulationData=1;
        if(flag_figSpecificDirty==0)                        
          flag_figSpecificDirty=1;
        end
        flag_addReferenceData = flag_lastTrial;
        indexColumn=1;
        [figSpecific,impedancePlotCounterUpd] =...
            plotImpedanceSimulationData(figSpecific,...
                inputFunctions,...
                binout,uniformModelData,d3hspFileName,...
                indexColumn,subPlotPanelSpecific,...
                numberOfVerticalPlotRowsSpecific,...
                numberOfHorizontalPlotColumnsSpecific,...                              
                simulationDirectoryName,...
                indexSimulationTrial, numberOfSimulationDirectories,...
                referenceDataFolder,...         
                lceOpt,fiso,ltslk,...
                flag_addReferenceData,flag_addSimulationData,...
                impedancePlotCounter);
         impedancePlotCounter=impedancePlotCounterUpd;
    case 'force_length'
        %Only umat43 produces the curve-specific files right now.
        if( strcmp( modelNameStr, 'umat43' ) )
            %Get the curve files
            curveSubstr = {'fal','fecmH','f1H','f2H'};
            curveCount=0;
            curveFileList ={''};
            for indexFile=1:1:length(fileList)
              for indexCurveType=1:1:length(curveSubstr)
                  if(contains(fileList(indexFile).name,curveSubstr{indexCurveType}))
                    curveCount=curveCount+1;
                    if curveCount == 1
                      curveFileList = {fileList(indexFile).name};
                    else
                      curveFileList = [curveFileList;fileList(indexFile).name];
                    end                                            
                  end
              end
            end
            assert(curveCount == 4);

            flag_addSimulationData=1;
            if(flag_figSpecificDirty==0)                        
              flag_figSpecificDirty=1;
              flag_addReferenceData=1;
            else
              flag_addReferenceData=0;
            end
            indexColumn=1;

            for indexCurve=1:1:length(curveFileList)
                curveData=curvereader(curveFileList{indexCurve});
                figSpecific =...
                    plotForceLengthSimulationData(...
                        figSpecific,curveData,...
                        indexColumn,subPlotPanelSpecific,...
                        numberOfVerticalPlotRowsSpecific,...
                        numberOfHorizontalPlotColumnsSpecific,...                              
                        simulationDirectoryName,...
                        indexSimulationTrial, numberOfSimulationDirectories,...
                        referenceDataFolder,...
                        flag_addReferenceData,flag_addSimulationData,...
                        simulationColorA,simulationColorB,...
                        dataColorA,dataColorB);
                    flag_addReferenceData=0;
            end

        end
    case 'sinusoid'
        %Only umat43 produces the curve-specific files right now.                                
        if( strcmp( modelNameStr, 'umat43' ) )
           %Get the curve files
            curveSubstr = {'fal','fecmH','f1H','f2H','fv',...
                            'ftFcnN','ktFcnN','fCpFcnN'};
            curveCount=0;
            curveFileList ={''};
            for indexFile=1:1:length(fileList)
              for indexCurveType=1:1:length(curveSubstr)
                  if(contains(fileList(indexFile).name,curveSubstr{indexCurveType}))
                    curveCount=curveCount+1;
                    if curveCount == 1
                      curveFileList = {fileList(indexFile).name};
                    else
                      curveFileList = [curveFileList;fileList(indexFile).name];
                    end                                            
                  end
              end
            end
            assert(curveCount == length(curveSubstr)); 
            
            flag_addSimulationCurveData=1;
            flag_addSimulationOutputData=0;
            if(flag_figSpecificDirty==0)                        
              flag_figSpecificDirty=1;
              flag_addReferenceData=1;
            else
              flag_addReferenceData=0;
            end
            indexColumn=1;                                    

         
            for indexCurve=1:1:length(curveFileList)
                curveData=curvereader(curveFileList{indexCurve});
                figSpecific =...
                    plotSinusoidSimulationDataUmat43(...
                        figSpecific,musout,curveData,...
                        indexColumn,subPlotPanelSpecific,...
                        numberOfVerticalPlotRowsSpecific,...
                        numberOfHorizontalPlotColumnsSpecific,...                              
                        simulationDirectoryName,...
                        indexSimulationTrial, numberOfSimulationDirectories,...
                        referenceDataFolder,...
                        flag_addReferenceData,...
                        flag_addSimulationCurveData,...
                        flag_addSimulationOutputData);
                    flag_addReferenceData=0;
            end
            flag_addReferenceData      =0;
            flag_addSimulationCurveData=0;
            flag_addSimulationOutputData=1;
            figSpecific =...
                    plotSinusoidSimulationDataUmat43(...
                        figSpecific,musout,curveData,...
                        indexColumn,subPlotPanelSpecific,...
                        numberOfVerticalPlotRowsSpecific,...
                        numberOfHorizontalPlotColumnsSpecific,...                              
                        simulationDirectoryName,...
                        indexSimulationTrial, numberOfSimulationDirectories,...
                        referenceDataFolder,...
                        flag_addReferenceData,...
                        flag_addSimulationCurveData,...
                        flag_addSimulationOutputData);
            here=1;

            figDebug=...
                plotDebugDataUmat43(...
                    figDebug,musout,musdebug,...
                    subPlotPanelDebug,...
                    numberOfVerticalPlotRowsDebug,...
                    numberOfHorizontalPlotColumnsDebug);
            if(flag_figDebugDirty==0)                        
                flag_figDebugDirty=1;
            end
        end
    case 'reflex'    
        if(flag_figSpecificDirty==0)                        
            flag_figSpecificDirty=1;
        end

        normCERefLength = 0;
        lengthThreshold = 0;

        workingDirectory = pwd;
        switch modelNameStr
            case 'umat41'
                normCERefLength = musout.data(end,musout.indexLceRef);
                normCERefLength = normCERefLength/lceOpt;
                cd ..
                lengthThreshold = getLsdynaCardFieldValue(...
                    simulationInformationEntry.musclePropertyCard,...
                    'thresh');
                
                %disp('Note: matching the reflex switching time of umat41 by ');
                %disp('  post-processing is not possible because the muscle ');
                %disp('  rapidly shortens and the data is often too coarsely');
                %disp('  sampled to catch the point where the threshold is ');
                %disp('  crossed.');
                
                %lengthThreshold = lengthThreshold;%*0.999; 
                cd(workingDirectory)
            case 'umat43'
                normCERefLength = musout.data(end,musout.indexLceNRef);                                        
                cd ..
                lengthThreshold = getLsdynaCardFieldValue(...
                    simulationInformationEntry.musclePropertyCard,...
                    'ctlThrsh');
                cd(workingDirectory);
                
        end

        
        figSpecific = plotReflexSimulationData(...
                        figSpecific,...
                        modelNameStr, ...
                        lceOpt,...
                        musout,...                                                
                        uniformModelData,...
                        normCERefLength,...
                        lengthThreshold,...
                        indexColumn,subPlotPanelSpecific,...
                        numberOfVerticalPlotRowsSpecific,...
                        numberOfHorizontalPlotColumnsSpecific,...                              
                        simulationDirectoryName,...
                        indexSimulationTrial,...
                        numberOfSimulationDirectories);
                    
    case 'reflex_kN_mm_ms'    
        if(flag_figSpecificDirty==0)                        
            flag_figSpecificDirty=1;
        end

        normCERefLength = 0;
        lengthThreshold = 0;

        workingDirectory = pwd;
        switch modelNameStr
            case 'umat41'
                normCERefLength = musout.data(end,musout.indexLceRef);
                normCERefLength = normCERefLength/lceOpt;
                cd ..
                lengthThreshold = getLsdynaCardFieldValue(...
                    simulationInformationEntry.musclePropertyCard,...
                    'thresh');
                
                %disp('Note: matching the reflex switching time of umat41 by ');
                %disp('  post-processing is not possible because the muscle ');
                %disp('  rapidly shortens and the data is often too coarsely');
                %disp('  sampled to catch the point where the threshold is ');
                %disp('  crossed.');
                
                lengthThreshold = lengthThreshold*0.999; 
                cd(workingDirectory)
            case 'umat43'
                normCERefLength = musout.data(end,musout.indexLceNRef);                                        
                cd ..
                lengthThreshold = getLsdynaCardFieldValue(...
                    simulationInformationEntry.musclePropertyCard,...
                    'ctlThrsh');
                cd(workingDirectory);
                
        end

        
        figSpecific = plotReflexSimulationData(...
                        figSpecific,...
                        models(indexModel).name, ...
                        lceOpt,...
                        musout,...                                                
                        uniformModelData,...
                        normCERefLength,...
                        lengthThreshold,...
                        indexColumn,subPlotPanelSpecific,...
                        numberOfVerticalPlotRowsSpecific,...
                        numberOfHorizontalPlotColumnsSpecific,...                              
                        simulationDirectoryName,...
                        indexSimulationTrial,...
                        numberOfSimulationDirectories); 
    case 'isometric_generic'
        assert(0,'Nothing yet added for isometric_generic');                                                               
        
end