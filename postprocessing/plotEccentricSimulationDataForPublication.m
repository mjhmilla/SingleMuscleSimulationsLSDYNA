function [figH] = ...
    plotEccentricSimulationDataForPublication(figH,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexModel,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                       
                      referenceCurveFolder,...
                      muscleArchitecture,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

optimalFiberLength      =muscleArchitecture.lceOpt;
maximumIsometricForce   =muscleArchitecture.fiso;
tendonSlackLength       =muscleArchitecture.ltslk;
pennationAngle          =muscleArchitecture.alpha;

flag_addIsometricTrials=0;

indexInjury=4;

yLimForce = [0,40;...
             0,40;...
             0,40;...
             0,80];

xLimForce = [0,12.0;...
             0,12.0;...
             0,12.0;...
             0,18.0];

yLimRamp = [-0.5,9.5;...            
            -0.5,9.5;...
            -0.5,9.5;...
            -0.5,52.5];

xLimRamp = xLimForce;

yLimForceNorm = [0,1.76;...
                 0,1.76;...
                 0,1.76;...
                 0,4.01];

xLimRampNorm = [0.49,1.31;...                
                0.49,1.31;...
                0.49,1.31;...
                0.49,2.01];




lengthsToPlot = [9;6;3;52];

lineWidthData=1;
lineWidthModel=1;


%Plot the injury threshold
tfN = 3.41;
tfActiveMinorN    = tfN*0.7;
tfActiveMajorN    = tfN*0.9;
tfActiveRuptureN  = tfN;
tfPassiveMinorN   = tfN*0.3;
tfPassiveMajorN   = tfN*0.8;
tfPassiveRuptureN = tfN;

simRefDataMap(12) =struct('refFile',[],'refTimeColumn',0,...
    'refForceColumn',0,'refLengthColumn',0,...
    'activation',0,'plotColumn',0);
simRefDataMap(1).refFile = 'dataHerzogLeonard2002Figure7A.dat';
simRefDataMap(2).refFile = 'dataHerzogLeonard2002Figure7B.dat';
simRefDataMap(3).refFile = 'dataHerzogLeonard2002Figure7C.dat';
simRefDataMap(4).refFile = 'dataHerzogLeonard2002Figure7A.dat';
simRefDataMap(5).refFile = 'dataHerzogLeonard2002Figure7B.dat';
simRefDataMap(6).refFile = 'dataHerzogLeonard2002Figure7C.dat';
simRefDataMap(7).refFile = 'dataHerzogLeonard2002Figure7A.dat';
simRefDataMap(8).refFile = 'dataHerzogLeonard2002Figure7B.dat';
simRefDataMap(9).refFile = 'dataHerzogLeonard2002Figure7C.dat';
simRefDataMap(10).refFile ='dataHerzogLeonard2002Figure7A.dat';
simRefDataMap(11).refFile ='dataHerzogLeonard2002Figure7B.dat';
simRefDataMap(12).refFile ='dataHerzogLeonard2002Figure7C.dat';

simRefDataMap(1).refTimeColumn      = 1;
simRefDataMap(1).refForceColumn     = 12;
simRefDataMap(1).refLengthColumn    = 13;
simRefDataMap(1).plotColumn =1;
simRefDataMap(1).activation =1;

simRefDataMap(2).refTimeColumn      = 1;
simRefDataMap(2).refForceColumn     = 10;
simRefDataMap(2).refLengthColumn    = 11;
simRefDataMap(2).plotColumn =2;
simRefDataMap(2).activation =1;

simRefDataMap(3).refTimeColumn      = 1;
simRefDataMap(3).refForceColumn     = 10;
simRefDataMap(3).refLengthColumn    = 11;
simRefDataMap(3).plotColumn =3;
simRefDataMap(3).activation =1;

simRefDataMap(4).refTimeColumn      = 1;
simRefDataMap(4).refForceColumn     = 8;
simRefDataMap(4).refLengthColumn    = 9;
simRefDataMap(4).plotColumn =4;
simRefDataMap(4).activation =1;

simRefDataMap(5).refTimeColumn      = 1;
simRefDataMap(5).refForceColumn     = 8;
simRefDataMap(5).refLengthColumn    = 9;
simRefDataMap(5).plotColumn =5;
simRefDataMap(5).activation =1;

simRefDataMap(6).refTimeColumn      = 1;
simRefDataMap(6).refForceColumn     = 8;
simRefDataMap(6).refLengthColumn    = 9;
simRefDataMap(6).plotColumn =6;
simRefDataMap(6).activation =1;

simRefDataMap(7).refTimeColumn      = 1;
simRefDataMap(7).refForceColumn     = 6;
simRefDataMap(7).refLengthColumn    = 7;
simRefDataMap(7).plotColumn =7;
simRefDataMap(7).activation =1;

simRefDataMap(8).refTimeColumn      = 1;
simRefDataMap(8).refForceColumn     = 6;
simRefDataMap(8).refLengthColumn    = 7;
simRefDataMap(8).plotColumn =8;
simRefDataMap(8).activation =1;

simRefDataMap(9).refTimeColumn      = 1;
simRefDataMap(9).refForceColumn     = 6;
simRefDataMap(9).refLengthColumn    = 7;
simRefDataMap(9).plotColumn =9;
simRefDataMap(9).activation =1;

simRefDataMap(10).refTimeColumn      = 1;
simRefDataMap(10).refForceColumn     = 10;
simRefDataMap(10).refLengthColumn    = 11;
simRefDataMap(10).plotColumn         = 1;
simRefDataMap(10).activation         = 0;

simRefDataMap(11).refTimeColumn      = 1;
simRefDataMap(11).refForceColumn     = 12;
simRefDataMap(11).refLengthColumn    = 13;
simRefDataMap(11).plotColumn         = 2;
simRefDataMap(11).activation         = 0;

simRefDataMap(12).refTimeColumn      = 1;
simRefDataMap(12).refForceColumn     = 12;
simRefDataMap(12).refLengthColumn    = 13;
simRefDataMap(12).plotColumn         = 3;
simRefDataMap(12).activation         = 0;



% Add the reference data
if(flag_addReferenceData==1)

    %Load the reference data
    dataFiles = {'dataHerzogLeonard2002Figure7A.dat',...
                 'dataHerzogLeonard2002Figure7B.dat',...
                 'dataHerzogLeonard2002Figure7C.dat'};
    dataLabels = {'3mm/s','9mm/s','27mm/s'};

    %dataFig7A = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7A.csv']);
    %dataFig7B = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7B.csv']);
    %dataFig7C = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7C.csv']);  




    for indexLengths = 1:1:length(lengthsToPlot)

        indexRowA = 1;
        indexRowB = indexRowA+1;
        indexRowC = indexRowB+1;

        subPlotColOffset = (indexLengths-1)*3;
        addedReferenceForceLengthCurve = zeros(1,4);
        addHLData=0;
        switch indexLengths
            case 1
                addHLData=1;
            case 2
                addHLData=1;
            case 3
                addHLData=1;
            case 4
                addHLData=0;                
            otherwise
                assert(0,'Error: switch statement coded for [1,2]');
        end

        if(addedReferenceForceLengthCurve(1,indexLengths)==0)
            for indexColumn=1:1:3
                subplot('Position',...
                    reshape(subPlotLayout(indexRowC,indexColumn+subPlotColOffset,:),1,4));
    
%                 falFile = fullfile(referenceCurveFolder,'felineSoleus_activeForceLengthCurve.dat');
%                 fpeFile = fullfile(referenceCurveFolder,'felineSoleus_fiberForceLengthCurve.dat');
%     
%                 falFcn = readBezierCurveFromCSV(falFile);
%                 fpeFcn = readBezierCurveFromCSV(fpeFile);
%                 
%                 npts=200;
%                 xDomain = xLimRampNorm(indexLengths,:);%[falFcn.xEnd(1,1),fpeFcn.xEnd(1,2)];
%                 xDelta = xDomain(1,2)-xDomain(1,1);
%                 xSample = [xDomain(1,1):(xDelta/(npts-1)):xDomain(1,2)]';
%                 ySample = zeros(length(xSample),3);
% 
%                 for i=1:1:length(xSample)
%                     ySample(i,1)=calcQuadraticBezierYFcnXDerivative(xSample(i,1), falFcn, 0);
%                     ySample(i,2)=calcQuadraticBezierYFcnXDerivative(xSample(i,1), fpeFcn, 0);
%                     ySample(i,3)=ySample(i,1)+ySample(i,2);
%                 end
                    
                umat43FlData=...
                    dlmread(fullfile(referenceCurveFolder,'umat43ForceLengthData.csv'));
                umat41FlData=...
                    dlmread(fullfile(referenceCurveFolder,'umat41ForceLengthData.csv'));

                fill([0;umat43FlData(:,1);umat43FlData(end,1);umat43FlData(1,1)],...
                     [0;umat43FlData(:,2);0;0],...
                     [1,1,1].*0.65,...
                     'EdgeColor','none',...
                     'HandleVisibility','off');
                hold on;
    
                falFpeUmat43 = umat43FlData(:,2)+umat43FlData(:,3);

                fill([umat43FlData(:,1);umat43FlData(end,1);umat43FlData(1,1)],...
                     [umat43FlData(:,3);umat43FlData(1,3);umat43FlData(1,3)],...
                     [1,1,1].*0.55,...
                     'EdgeColor','none',...
                     'HandleVisibility','off');
                hold on;
    
                plot(umat43FlData(:,1),falFpeUmat43(:,1),'Color',[1,1,1].*0.75,...
                     'LineWidth',lineWidthData*2,'HandleVisibility','off');
                hold on;                   

%                 fill([xSample;xSample(end,1);xSample(1,1)],...
%                      [ySample(:,1);ySample(1,1);ySample(1,1)],...
%                      [1,1,1].*0.65,...
%                      'EdgeColor','none',...
%                      'HandleVisibility','off');
%                 hold on;
%     
%                 fill([xSample;xSample(end,1);xSample(1,1)],...
%                      [ySample(:,2);ySample(1,2);ySample(1,2)],...
%                      [1,1,1].*0.55,...
%                      'EdgeColor','none',...
%                      'HandleVisibility','off');
%                 hold on;
%     
%                 plot(xSample,ySample(:,3),'Color',[1,1,1].*0.75,...
%                      'LineWidth',lineWidthData*2,'HandleVisibility','off');
%                 hold on;                    
    
                addedReferenceForceLengthCurve(1,indexColumn) = 1;
            end
        end        

        for indexFile = 1:1:length(dataFiles)
            data = importdata([referenceDataFolder,filesep,dataFiles{indexFile}]);
            indexTime=1;
    
            isForceColumn     = zeros(1,length(data.colheaders));
            isLengthColumn    = zeros(1,length(data.colheaders));
            isIsometricColumn = zeros(1,length(data.colheaders));
            isPassiveColumn   = zeros(1,length(data.colheaders));
    
            fisoFl = 0;
            for indexColumnHeader = 1:1:length(data.colheaders)
                if(contains(data.colheaders{indexColumnHeader},'(N)'))
                    isForceColumn(1,indexColumnHeader) =1; 
                                    
                    if(max(data.data(:,indexColumnHeader)) < 0.5*maximumIsometricForce)
                        isPassiveColumn(indexColumnHeader)=1;
                        isPassiveColumn(indexColumnHeader+1)=1;
    
                        %Make sure that the length column is the pair to the
                        %length column
                        colId = data.colheaders{indexColumnHeader}(2:3);
                        assert( contains(data.colheaders{indexColumnHeader+1},colId));


                        
                    end
    
                    
                end
                if(contains(data.colheaders{indexColumnHeader},'(mm)'))
                    isLengthColumn(1,indexColumnHeader) =1;              
                    if(max(data.data(:,indexColumnHeader)) ...
                       -min(data.data(:,indexColumnHeader)) < min(lengthsToPlot(indexLengths,1)))
                        isIsometricColumn(1,indexColumnHeader)=1;
    
                        isIsometricColumn(1,indexColumnHeader-1)=1;
    
                        %Make sure that the force column is the pair to the
                        %length column
                        colId = data.colheaders{indexColumnHeader}(2:3);
                        assert( contains(data.colheaders{indexColumnHeader-1},colId));
    
                    end
    
                end            
            end
    
            %Plot the data
            
            %Plot the reference isometric force datda
            indexPlotedLine = 1;
            numberPlottedLines=3;
    
            trialCount=0;
            for indexForceColumn=(length(data.colheaders)-1):-2:2  
    
                indexLengthColumn = indexForceColumn+1;
    
                dl =  max(data.data(end,indexLengthColumn)) ...
                     -min(data.data(1,indexLengthColumn));
                dlErr = abs(dl-lengthsToPlot(indexLengths,1));
                flag_plotThisColumn = (dlErr < 1.5);

                if(isPassiveColumn(1,indexForceColumn)==1)
                    fprintf('%1.1f Passive\n',dl);
                    here=1;
                end

                if(   isIsometricColumn(1,indexForceColumn)==0 && flag_plotThisColumn==1)
                                 
                    %Identify the rate of lengthening
                    minL = min(data.data(:,indexLengthColumn));
                    maxL = max(data.data(:,indexLengthColumn));
    
                    dt = data.data(2,indexTime) ...
                        -data.data(1,indexTime);
                    freq=1/dt;
                    [b,a]=butter(2,5/(0.5/dt),'low');
                    rampFilt=filtfilt(b,a,data.data(:,indexLengthColumn));
                    rampFiltDiff = calcCentralDifferenceDataSeries(...
                                        data.data(:,indexTime),...
                                        rampFilt);
                    rampFiltDiff=filtfilt(b,a,rampFiltDiff);
                    rampFiltDDiff = calcCentralDifferenceDataSeries(...
                                        data.data(:,indexTime),...
                                        rampFiltDiff);
                    rampFiltDDiff=filtfilt(b,a,rampFiltDDiff);
                    rampFiltDDiff(1:freq,1)=0;
                    rampFiltDDiff(end-freq:end,1)=0;
                    [maxDlDt,idxMaxDlDt]= max(rampFiltDDiff);
                    [minDlDt,idxMinDlDt]= min(rampFiltDDiff);
                    
                    indexRampStart = idxMaxDlDt;
                    indexRampEnd   = idxMinDlDt;
                    %[timeMinL,indexRampStart] = max( data.data(:,indexLengthColumn)>(minL+1) );
                    %[timeMaxL,indexRampEnd] = min( data.data(:,indexLengthColumn)<(maxL-1) );
                    
                    timeRampStart   = data.data(indexRampStart,indexTime);
                    timeRampEnd     = data.data(indexRampEnd,indexTime);

                    lengthRampStart   = data.data(indexRampStart,indexLengthColumn);
                    lengthRampEnd     = data.data(indexRampEnd,indexLengthColumn);
    
                    rampVelRough = (lengthRampEnd-lengthRampStart)/(timeRampEnd-timeRampStart);
                    
                    errVel = [1,1,1].*rampVelRough - [3,9,27];
                    [errVelMin, indexVel] = min(abs(errVel));
                        
                    indexColumn = indexVel;
                    




    
                    subplot('Position',...
                        reshape(subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4));  
                    
                    %n = (indexVel-1)/2;
                    %referenceColor = referenceColorB.*(1-n)+referenceColorA.*n;                
                    referenceColor = referenceColorA;
                    

                    if(addHLData==1)
                        plot(data.data(:,indexTime), ...
                             data.data(:,indexForceColumn),...
                             'Color',referenceColor,'LineWidth',lineWidthData);
                        hold on;
                    end

    
                    [valMax,idxMax] = max(data.data(:,indexForceColumn));
    
                    dt = 1;
                    t0 = data.data(idxMax,indexTime);
                    t1 = t0-0.5;
    
                    f0 = valMax;
                    f1 = f0;
                                        

                    trialLabel = '';
                    if(isPassiveColumn(1,indexForceColumn) == 0 && ...
                       isIsometricColumn(1,indexForceColumn) == 0 && ...
                       flag_plotThisColumn==1)

                        if(addHLData==1)
                            plot([t0,t0+1],...
                                 [f0,f0],...
                                 '-','Color',referenceColor);
                            hold on;  
                            plot(t0,f0,...
                                 'o','Color',referenceColor,...
                                 'MarkerSize',2,...
                                 'MarkerFaceColor',[1,1,1]);
                            hold on;  
                            
                            trialLabel = sprintf('%1.1fN',f0);
                            text(t0+1,f0,trialLabel,...
                                'VerticalAlignment','bottom',...
                                'HorizontalAlignment','left');
                            hold on;
                        end
                        subplot('Position',...
                        reshape(subPlotLayout(indexRowC,indexColumn+subPlotColOffset,:),1,4));
    
                        dt = data.data(2,indexTime) ...
                            -data.data(1,indexTime);
                        [b,a]=butter(2,5/(0.5/dt),'low');
                        rampFilt=filtfilt(b,a,data.data(:,indexLengthColumn));
                        rampFiltDiff = calcCentralDifferenceDataSeries(...
                                            data.data(:,indexTime),...
                                            rampFilt);
                        rampFiltDiff=filtfilt(b,a,rampFiltDiff);
                        rampFiltDDiff = calcCentralDifferenceDataSeries(...
                                            data.data(:,indexTime),...
                                            rampFiltDiff);
                        rampFiltDDiff=filtfilt(b,a,rampFiltDDiff);
                        [maxDlDt,idxMaxDlDt]= max(rampFiltDDiff);
                        rampFiltDDiff(1:(idxMaxDlDt-10),1)=0;
                        [minDlDt,idxMinDlDt]= min(rampFiltDDiff);
                        
                        [maxVal,idxMaxF]    = max(data.data(:,indexForceColumn));
                        
                        df = data.data(idxMaxDlDt,indexForceColumn) ...
                            -data.data(idxMaxDlDt-1,indexForceColumn);
                        while(abs(df)>0.1)
                            idxMaxDlDt=idxMaxDlDt-1;
                            df = data.data(idxMaxDlDt,indexForceColumn) ...
                            -data.data(idxMaxDlDt-1,indexForceColumn);
                        end
    
                        rampIdx = [idxMaxDlDt:1:idxMaxF]';
                        lceN0 = csvread([referenceDataFolder,filesep,...
                            'simulationParametersHerzogLeonard2002.dat']);

                        if(addHLData==1)
                            columnNumber=indexColumn+subPlotColOffset;
                            dataX = lceN0(1,1)+( data.data(rampIdx,indexLengthColumn)./(1000*optimalFiberLength));
                            dataY = data.data(rampIdx,indexForceColumn)./maximumIsometricForce; 

                            plot( dataX,...
                                  dataY,...
                                  '-','Color',referenceColor,...
                                  'LineWidth',lineWidthData);
                            hold on;
                            plot( dataX(end,1),...
                                  dataY(end,1),...
                                  'o','Color',referenceColor,...
                                  'MarkerFaceColor',[1,1,1],...
                                  'MarkerSize',2,...
                                  'LineWidth',lineWidthData);
                            hold on;
                            ln2 = dataX(end,1)+0.05;
                            fn2 = dataY(end,1);
                            plot( [dataX(end,1),ln2],...
                                  [dataY(end,1),fn2],...
                                  '-','Color',referenceColor);
                            hold on;                                    
                            text(ln2,fn2,...
                                 sprintf('%1.2f %s',dataY(end,1),'$$f^M_o$$'),...
                                 'Color',[0,0,0],...
                                 'HorizontalAlignment','left');
                            hold on;
                            
                        end

                        subplot('Position',...
                        reshape(subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4));
    
                        t2 = data.data(idxMaxDlDt,indexTime);
                        f2 = data.data(idxMaxDlDt,indexForceColumn); 
                        t3 = 1.75;
                        f3 = f2+2;
                        if(addHLData==1)
                            plot([t2,t3],...
                                 [f2,f3],...
                                 '-','Color',referenceColor);
                            hold on;  
                            plot(t2,f2,...
                                 'o','Color',referenceColor,...
                                 'MarkerSize',2,...
                                 'MarkerFaceColor',[1,1,1]);
                            hold on;    
                            trialLabel = sprintf('%1.1fN',f2);
                            text(t3,f3,trialLabel,'VerticalAlignment','bottom',...
                                 'HorizontalAlignment','right');
                            hold on;
                        end
                    elseif(isPassiveColumn(1,indexForceColumn) == 1 && ...
                       isIsometricColumn(1,indexForceColumn) == 0)
                        t1=t0;
                        f1=f0;
                        
                        if(addHLData==1 && flag_plotThisColumn==1)
                            plot(t0,f0,...
                                 'o','Color',referenceColor,...
                                 'MarkerSize',2,...
                                 'MarkerFaceColor',[1,1,1]);
                            hold on;
                            plot([t0,t0+1],[f0,f0+0.5],...
                                 '-','Color',referenceColor);
                            hold on;
        
                            trialLabel = sprintf('%1.1fN',f0); 
                            text(t0+1,f0+0.5,trialLabel,...
                                'VerticalAlignment','bottom',...
                                'HorizontalAlignment','left');
                            hold on;
                        end
    
                    elseif(isPassiveColumn(1,indexForceColumn) == 0 && ...
                       isIsometricColumn(1,indexForceColumn) == 0 && ...
                       flag_plotThisColumn==1)
                        t1=t0;
                        f1=f0;
                        
                        if(addHLData==1)
                            plot(t0,f0,...
                                 'o','Color',referenceColor,...
                                 'MarkerSize',2,...
                                 'MarkerFaceColor',[1,1,1]);
                            hold on;    
                            
                            trialLabel = sprintf('%1.1fN',f0); 
                            text(t1,f1,trialLabel,...
                                'VerticalAlignment','bottom',...
                                'HorizontalAlignment','right');
                            hold on;
                        end
    
                    end
    
                    
    
                    if( isPassiveColumn(1,indexForceColumn)==0)
                        subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn+subPlotColOffset,:),1,4));
                        
                        if(addHLData==1 && flag_plotThisColumn==1)
                            rampTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMES');
                            rampTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMEE');

                            plot(data.data(:,indexTime), data.data(:,indexLengthColumn),...
                                 'Color',referenceColor,'LineWidth',lineWidthData);
                            hold on;  
                            text(data.data(idxMaxDlDt,indexTime),...
                                 data.data(idxMaxDlDt,indexLengthColumn),...
                                 sprintf('%1.2f',rampTimeS),...
                                 'FontSize',6,...
                                 'HorizontalAlignment','right',...
                                 'VerticalAlignment','bottom');
                            hold on;
                            text(data.data(idxMinDlDt,indexTime)+0.25,...
                                 data.data(idxMinDlDt,indexLengthColumn),...
                                 sprintf('%1.2f',rampTimeE),...
                                 'FontSize',6,...
                                 'HorizontalAlignment','left',...
                                 'VerticalAlignment','top');
                            hold on;
                        end
    
                    end
                    if(isPassiveColumn(1,indexForceColumn)==0 ...
                            && isIsometricColumn(1,indexForceColumn)==0)
                        trialCount=trialCount+1;
                    end
    
    
                end
    
            end
    
        end
    
        here=1;
    
        for indexSubplotColumn = 1:1:3
    
            indexRowA = 1;
            indexRowB = 2;
            indexRowC = 3;
    
            plotLabel1  = '';
            plotLabel2  = '';
            plotLabel3  = '';
            velLabel    = '';
            switch indexSubplotColumn
                case 1
                    plotLabel1 = 'A';
                    plotLabel2 = 'B';
                    plotLabel3 = 'C';
                    velLabel   = '3 mm/s';
                    
                case 2
                    plotLabel1 = 'A';
                    plotLabel2 = 'B';
                    plotLabel3 = 'C';
                    velLabel   = '9 mm/s';
                    
                case 3
                    plotLabel1 = 'A';
                    plotLabel2 = 'B';
                    plotLabel3 = 'C';
                    velLabel   = '27 mm/s';
                    
                otherwise
                    assert(0,'Error: invalid indexColumn');
            end
        
            lengthStr = num2str(lengthsToPlot(indexLengths,1));

            subplot('Position',reshape(subPlotLayout(indexRowA,indexSubplotColumn+subPlotColOffset,:),1,4));
            xlabel('Time (s)');
            ylabel('Force (N)');
            title([plotLabel1,'. Active-lengthening: ',lengthStr,'mm \& (',velLabel,')']);
            box off;
            xticks([0:2:max(xLimForce(indexLengths,:))]);
            yticks([0:10:max(yLimForce(indexLengths,:))])
            ylim(yLimForce(indexLengths,:));
            xlim(xLimForce(indexLengths,:));
            hold on;
        
            subplot('Position',reshape(subPlotLayout(indexRowB,indexSubplotColumn+subPlotColOffset,:),1,4));
            xlabel('Time (s)');
            ylabel('Length (mm)');
            title([plotLabel2,'. Ramp profile: ',lengthStr,'mm \& ',velLabel]);
            box off;
            switch(indexLengths)
                case 1
                    yticks([0,9]);
                case 2
                    yticks([0,9]);
                case 3
                    yticks([0,9]);
                case 4
                    yticks([0,52]);
                otherwise
                    assert(0,'Error: switch case not coded for that index')
            end
            ylim(yLimRamp(indexLengths,:));
            xlim(xLimRamp(indexLengths,:)); 
            hold on;
    

            subplot('Position',reshape(subPlotLayout(indexRowC,indexSubplotColumn+subPlotColOffset,:),1,4));
            xlabel('Norm. Length ($$\ell/\ell^{M}_o$$)');
            ylabel('Norm. Force ($$f/f^{M}_o$$)');
            title([plotLabel3,'. ',lengthStr,'mm \& ',velLabel]);
            box off;
            hold on;

            if(indexLengths==4)

                subplot('Position',reshape(subPlotLayout(indexRowC,indexSubplotColumn+subPlotColOffset,:),1,4));
                
                    lceNDomain =[xLimRampNorm(indexLengths,:)];
    
                    plot(lceNDomain,...
                         [1;1].*tfActiveMinorN,...
                         '--','Color',[1,1,1].*0.5,'LineWidth',0.5);
                    hold on
                    plot(lceNDomain,...
                         [1;1].*tfActiveMajorN,...
                         '-','Color',[1,1,1].*0.5,'LineWidth',0.5);
                    hold on
                    plot(lceNDomain,...
                         [1;1].*tfActiveRuptureN,...
                         '-','Color',[0,0,0],'LineWidth',1);
                    hold on


                    lceNDomainLeft = lceNDomain(1,1) + 0.025*(lceNDomain(1,2)-lceNDomain(1,1));
                    text(lceNDomainLeft,...
                         tfActiveMinorN,[sprintf('%1.2f',tfActiveMinorN), ' Minor Injury'],...
                         'HorizontalAlignment','left',...
                         'VerticalAlignment','bottom');
                    hold on;
                    text(lceNDomainLeft,...
                         tfActiveMajorN,[sprintf('%1.2f',tfActiveMajorN),  ' Major Injury'],...
                         'HorizontalAlignment','left',...
                         'VerticalAlignment','bottom');
                    hold on;
                    text(lceNDomainLeft,...
                         tfActiveRuptureN,[sprintf('%1.2f',tfActiveRuptureN), ' Rupture'],...
                         'HorizontalAlignment','left',...
                         'VerticalAlignment','bottom');
                    hold on;

                             
            end

            subplot('Position',reshape(subPlotLayout(indexRowC,indexSubplotColumn+subPlotColOffset,:),1,4));
            
            switch (indexLengths)
                case 1
                    xticks([0.5:0.1:1.3]);
                    yticks([0:0.25:1.75]);
                case 2
                    xticks([0.5:0.1:1.3]);
                    yticks([0:0.25:1.75]);    
                case 3
                    xticks([0.5:0.1:1.3]);
                    yticks([0:0.25:1.75]);
                case 4
                    xticks([0.5:0.25:2.0]);
                    yticks([0:0.25:4.0]);
                    
                otherwise
                    assert(0,'Error: switch statement not coded for indexLengths outside of [1,2]');
            end
            ylim(yLimForceNorm(indexLengths,:));
            xlim(xLimRampNorm(indexLengths,:));                     
            hold on;
            
             indexFullColumn = indexSubplotColumn+subPlotColOffset;
%             switch indexFullColumn
%                 case 4
%                     subplot('Position',reshape(subPlotLayout(indexRowA,indexSubplotColumn+subPlotColOffset,:),1,4));
%                     xticks([0:5:20]);
%                     xlim([0,20.01]);
%                     hold on;
% 
%                     subplot('Position',reshape(subPlotLayout(indexRowB,indexSubplotColumn+subPlotColOffset,:),1,4));
%                     xticks([0:5:20]);
%                     xlim([0,20.01]);
%                     hold on;
%                 case 5
%                     subplot('Position',reshape(subPlotLayout(indexRowA,indexSubplotColumn+subPlotColOffset,:),1,4));
%                     xticks([0:2:8]);
%                     xlim([0,8.5]);
%                     hold on;
% 
%                     subplot('Position',reshape(subPlotLayout(indexRowB,indexSubplotColumn+subPlotColOffset,:),1,4));
%                     xticks([0:2:8]);
%                     xlim([0,8.5]);
%                     hold on;
%                 case 6
%                     subplot('Position',reshape(subPlotLayout(indexRowA,indexSubplotColumn+subPlotColOffset,:),1,4));
%                     xticks([0:1:4]);
%                     xlim([0,4.51]);
%                     hold on;
% 
%                     subplot('Position',reshape(subPlotLayout(indexRowB,indexSubplotColumn+subPlotColOffset,:),1,4));
%                     xticks([0:1:4]);
%                     xlim([0,4.51]);
%                     hold on;
%             end
        end
    end
    flag_addReferenceData=0;

end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);

    rampSpeedLabel = {'3mmps','9mmps','27mmps'};
    rampSpeed = [3,9,27];
    indexRamp = 0;
    indexLengths = 0;

    subPlotColOffset = 0;


    for i=1:1:length(rampSpeedLabel)
        for j=1:1:length(lengthsToPlot)
            lengthStr = num2str(lengthsToPlot(j,1));
            if(contains(simulationFile,[rampSpeedLabel{i},'_',lengthStr,'mm']))
                indexRamp=i;    
                subPlotColOffset=(j-1)*3;
                indexLengths=j;
            end            
        end
    end

    indexColumn     = indexRamp;
    simulationColor = simulationColorA;

    %If we have found a ramp that has a 9mm length change, plot it
    if(indexRamp ~= 0)

        if(contains(simulationFile,'ramp_9mmps_9mm'))
            here=1;
        end

        indexRowA = 1;
        indexRowB = indexRowA+1;
        indexRowC = indexRowB+1;
    
        %Get the reference length PATHLEN0 stored in the d3hsp file
        pathLen = getParameterValueFromD3HSPFile(d3hspFileName,'PATHLENO');
        m2mm=1000;
    
        subplot('Position',reshape(...
            subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4));
    
            changeInLength = -( lsdynaBinout.nodout.z_coordinate ...
                               -lsdynaBinout.nodout.z_coordinate(1,1));
                           
            changeInLengthFromOptimal = -(lsdynaBinout.nodout.z_coordinate+pathLen);
                           
            changeInLength  = changeInLength.*(m2mm); %m to mm
            dl              = round(changeInLength(end,1)-changeInLength(1,1),0);
    
            maxStim=getParameterValueFromD3HSPFile(d3hspFileName,'STIMHIGH');

            if(dl > 2)
                plot(lsdynaBinout.elout.beam.time',...
                     lsdynaBinout.elout.beam.axial,...
                     'Color', simulationColor,...
                     'LineWidth',lineWidthModel);
                hold on;
                box off;  

                if(isempty(simRefDataMap(indexColumn+subPlotColOffset).refFile)==0)
                    rampTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMES');
                    rampTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMEE');
                    stimTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'STIMTIMEE');
                    timeE     = getParameterValueFromD3HSPFile(d3hspFileName,' TIMEE ');

                    
                    
                    %Load the reference data
                    idxPlotColumn = indexColumn+subPlotColOffset;
                    idxData=0;

                    for i=1:1:length(simRefDataMap)
                        if( (abs(simRefDataMap(i).plotColumn-idxPlotColumn) < 0.5) ...
                                && (abs(maxStim - simRefDataMap(i).activation) < 0.5 ) )
                            idxData=i;
                        end
                    end

                    if(idxData > 0)
                        refData = importdata([referenceDataFolder,filesep,...
                                    simRefDataMap(idxData).refFile]);
                        refDataTime = refData.data(:,simRefDataMap(idxData).refTimeColumn);
                        refDataForce= refData.data(:,simRefDataMap(idxData).refForceColumn);
                        refDataLength=refData.data(:,simRefDataMap(idxData).refLengthColumn);

                        
        
                        refChangeInLength=max(refDataLength)-min(refDataLength);
                        if(abs(max(changeInLength)-refChangeInLength) >= 0.5)
                            here=1;
                        end
                        assert(abs(max(changeInLength)-refChangeInLength) < 0.5);
        
                        %Calculate the ramp RMSE error
                        npts=100;
                        timeRamp = [rampTimeS:((rampTimeE-rampTimeS)/(npts-1)):rampTimeE]';
                        errorRamp = zeros(size(timeRamp));
                        for i=1:1:length(timeRamp)
                            refForce = interp1(refDataTime,... 
                                        refDataForce,...
                                        timeRamp(i,1));
                            simForce = interp1(lsdynaBinout.elout.beam.time,... 
                                        lsdynaBinout.elout.beam.axial,...
                                        timeRamp(i,1));
                            errorRamp(i,1) = simForce-refForce;        
                        end    
                        rmseRamp = sqrt(mean(errorRamp.^2)); 
    
                        %Calculate the ramp recovery RMSE error
                        timePostRamp = [rampTimeE:((stimTimeE-rampTimeE)/(npts-1)):stimTimeE]';
                        errorPostRamp = zeros(size(timePostRamp));
                        for i=1:1:length(timeRamp)
                            refForce = interp1(refDataTime,... 
                                        refDataForce,...
                                        timePostRamp(i,1));
                            simForce = interp1(lsdynaBinout.elout.beam.time,... 
                                        lsdynaBinout.elout.beam.axial,...
                                        timePostRamp(i,1));
                            errorPostRamp(i,1) = simForce-refForce;        
                        end    
                        rmsePostRamp = sqrt(mean(errorPostRamp.^2)); 
    
                        %Calculate the deactivation RMSE error
                        if(contains(lsdynaMuscleUniform.name,'umat43')==1)
                            here=1;
                        end

                        timeFinal = min(timeE,max(refDataTime));
                        timeFinal = timeFinal*0.99;
                        timeDeact = [stimTimeE:((timeFinal-stimTimeE)/(npts-1)):timeFinal]';
                        errorDeact = zeros(size(timeDeact));
                        for i=1:1:length(timeRamp)
                            refForce = interp1(refDataTime,... 
                                        refDataForce,...
                                        timeDeact(i,1));
                            simForce = interp1(lsdynaBinout.elout.beam.time,... 
                                        lsdynaBinout.elout.beam.axial,...
                                        timeDeact(i,1));
                            errorDeact(i,1) = simForce-refForce;        
                        end    
                        rmseDeact = sqrt(mean(errorDeact.^2));                    
    


                        df = 1.5;          
                        dt = 0.125;

                        %Write the ramp RMSE to the figure
                        xTxt = rampTimeS-dt;
                        yTxt=38;
                        hAlign='right';
                        if(maxStim < 0.5)
                            xTxt = rampTimeS;
                            yTxt = 15;     
                            hAlign='left';
                        end
                        if(maxStim > 0.5)
                            plot([1,1].*rampTimeS,...
                                 [39,40],'-','Color',[0,0,0]);
                            hold on;
                            plot([1,1].*rampTimeE,...
                                 [39,40],'-','Color',[0,0,0]);
                            hold on;
                            plot([rampTimeS,rampTimeE],...
                                 [40,40],'-','Color',[0,0,0]);
                            hold on;
                            plot([1,1].*stimTimeE,...
                                 [39,40],'-','Color',[0,0,0]);
                            hold on;
                            plot([rampTimeE,stimTimeE],...
                                 [40,40],'-','Color',[0,0,0]);
                            hold on;
                            plot([1,1].*12,...
                                 [39,40],'-','Color',[0,0,0]);
                            hold on;
                            plot([stimTimeE,12],...
                                 [40,40],'-','Color',[0,0,0]);
                            hold on;
                            
                        else
                            plot([1,1].*rampTimeS,...
                                 [8,9],'-','Color',[0,0,0]);
                            hold on;                            
                            plot([1,1].*rampTimeE,...
                                 [8,9],'-','Color',[0,0,0]);
                            hold on;                            
                            plot([rampTimeS,rampTimeE],...
                                 [9,9],'-','Color',[0,0,0]);
                            hold on;
                        end

                        switch lsdynaMuscleUniform.name
                            case 'mat156'
                                text(xTxt,yTxt,'RMSE','HorizontalAlignment',hAlign);
                                hold on;
                                text(xTxt,yTxt-df,sprintf('%1.1f',rmseRamp),...
                                     'HorizontalAlignment',hAlign,...
                                     'Color',simulationColor);
                                hold on;
                            case 'umat41'
                                text(xTxt,yTxt-2*df,sprintf('%1.1f',rmseRamp),...
                                     'HorizontalAlignment',hAlign,...
                                     'Color',simulationColor);
                                hold on;
                                
                            case 'umat43'
                                text(xTxt,yTxt-3*df,sprintf('%1.1f',rmseRamp),...
                                     'HorizontalAlignment',hAlign,...
                                     'Color',simulationColor);
                                hold on;
                        end
    
                        %Write the ramp-recovery RMSE to the figure
                        if(maxStim > 0.5)
                            xTxt = stimTimeE-dt;
                            yTxt=38;
                            switch lsdynaMuscleUniform.name
                                case 'mat156'
                                    text(xTxt,yTxt,'RMSE','HorizontalAlignment','right');
                                    hold on;
                                    text(xTxt,yTxt-df,sprintf('%1.1f',rmsePostRamp),...
                                         'HorizontalAlignment','right',...
                                         'Color',simulationColor);
                                    hold on;
                                case 'umat41'
                                    text(xTxt,yTxt-2*df,sprintf('%1.1f',rmsePostRamp),...
                                         'HorizontalAlignment','right',...
                                         'Color',simulationColor);
                                    hold on;
                                    
                                case 'umat43'
                                    text(xTxt,yTxt-3*df,sprintf('%1.1f',rmsePostRamp),...
                                         'HorizontalAlignment','right',...
                                         'Color',simulationColor);
                                    hold on;
                            end
                        end
    
                        %Write the deactivation RMSE to the figure
                        if(maxStim > 0.5)
                            xTxt = 12-dt;
                            yTxt = 38;
                            switch lsdynaMuscleUniform.name
                                case 'mat156'
                                    text(xTxt,yTxt,'RMSE','HorizontalAlignment','right');
                                    hold on;
                                    text(xTxt,yTxt-df,sprintf('%1.1f',rmseDeact),...
                                         'HorizontalAlignment','right',...
                                         'Color',simulationColor);
                                    hold on;
                                case 'umat41'
                                    text(xTxt,yTxt-2*df,sprintf('%1.1f',rmseDeact),...
                                         'HorizontalAlignment','right',...
                                         'Color',simulationColor);
                                    hold on;
                                    
                                case 'umat43'
                                    text(xTxt,yTxt-3*df,sprintf('%1.1f',rmseDeact),...
                                         'HorizontalAlignment','right',...
                                         'Color',simulationColor);
                                    hold on;
                            end
                        end
                    end
                end
            end
    
           
            if(dl > 2 && maxStim > 0.5)

                rampTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMES');
                rampTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMEE');

                % Annotate the isometric and peak lengthening forces
                tS   = rampTimeS;
                tE   = rampTimeE;
                idxS = interp1( lsdynaBinout.elout.beam.time, ...
                                [1:1:length(lsdynaBinout.elout.beam.time)],...
                                tS);
                idxS = round(idxS);

                idxE = interp1( lsdynaBinout.elout.beam.time, ...
                                [1:1:length(lsdynaBinout.elout.beam.time)],...
                                tE);
                idxE = round(idxE);

                fE = lsdynaBinout.elout.beam.axial(idxE,1);

                dt = lsdynaBinout.elout.beam.time(1,idxE) ...
                    -lsdynaBinout.elout.beam.time(1,idxE-1);

                idxA = idxE - round(0.1/dt);
                idxB = idxE + round(0.1/dt);

                [fMax, idxDelta] = max( lsdynaBinout.elout.beam.axial(idxA:idxB,1) );
                tMax = lsdynaBinout.elout.beam.time(1,idxDelta+idxA-1);
                
                dt = 1;
                t1 = tMax+dt;
                f1=fE;

                yTxtPeak = 0;
                yTxtStart=0;
                df=1.5;
                switch lsdynaMuscleUniform.name
                    case 'mat156'
                        yTxtPeak=25;   
                        yTxtStart = 21;
                        if(contains(simulationFile,'27mmps') ~= 0)
                            yTxtPeak=23.5;   
                            yTxtStart = 21-df;
                        end
                    case 'umat41'
                        yTxtPeak=23.5;                                                        
                        yTxtStart = 21-df;
                        if(contains(simulationFile,'27mmps') ~= 0)
                            yTxtPeak=25;   
                            yTxtStart = 21;
                        end                        
                        
                    case 'umat43'
                        yTxtPeak=fE-1;
                        yTxtStart = 21-2*df;
                        
                end

                plot(tE,fE,...
                     'o','Color',simulationColor,...
                     'MarkerSize',2,...
                     'MarkerFaceColor',[1,1,1]);
                hold on;

                plot([tE;t1],[fMax;yTxtPeak],...
                     '-','Color',simulationColor);
                hold on;
    
                text(t1,yTxtPeak,sprintf('%1.1fN',fE),...
                     'Color',simulationColor,...
                     'HorizontalAlignment','left',...
                     'VerticalAlignment','middle');
                hold on;

                tS = rampTimeS-0.01;
                fS = interp1( lsdynaBinout.elout.beam.time, ...
                              lsdynaBinout.elout.beam.axial,...
                              tS);
                t2 = tS+dt;
                f2 = fS;

                plot(tS,fS,...
                     'o','Color',simulationColor,...
                     'MarkerSize',2,...
                     'MarkerFaceColor',[1,1,1]);
                hold on;

                plot([tS;t2],[fS;yTxtStart],...
                     '-','Color',simulationColor);
                hold on;
    
                text(t2,yTxtStart,sprintf('%1.1fN',fS),...
                     'Color',simulationColor,...
                     'HorizontalAlignment','left',...
                     'VerticalAlignment','middle');
                hold on;

                %Position 3
                subplot('Position',reshape(...
                    subPlotLayout(indexRowC,indexColumn+subPlotColOffset,:),1,4));

                idxS = interp1(lsdynaMuscleUniform.time,...
                        [1:1:length(lsdynaMuscleUniform.time)]',...
                        rampTimeS);
                idxS = round(idxS);
                idxS = idxS-1;

                idxE = interp1(lsdynaMuscleUniform.time,...
                        [1:1:length(lsdynaMuscleUniform.time)]',...
                        rampTimeE);
                idxE = round(idxE);
                                

                plot(lsdynaMuscleUniform.lceN(idxS:idxE,1),...
                     lsdynaMuscleUniform.fmtN(idxS:idxE,1),...
                     '-','Color',simulationColor,...
                     'LineWidth',lineWidthModel);
                hold on;

                if(indexLengths~=indexInjury)
                    hAlign = 'left';
                    dx = 0.05;
                    if(contains(lsdynaMuscleUniform.name,'umat43'))
                        hAlign='right';
                        dx = -0.05;
                    end

                    plot(   lsdynaMuscleUniform.lceN(idxE,1),...
                            lsdynaMuscleUniform.fmtN(idxE,1),...
                     'o','Color',simulationColor,...
                     'MarkerSize',2,...
                     'MarkerFaceColor',[1,1,1],...
                     'LineWidth',lineWidthModel);
                    hold on;

                    ln1 = lsdynaMuscleUniform.lceN(idxE,1);
                    fn1 = lsdynaMuscleUniform.fmtN(idxE,1);
                    ln2 = lsdynaMuscleUniform.lceN(idxE,1)+dx;
                    fn2 = lsdynaMuscleUniform.fmtN(idxE,1);
                    vAlign='middle';
                    hAlign='right';
                    switch lsdynaMuscleUniform.name
                        case 'mat156'
                            vAlign='bottom';
                            if(contains(simulationFile,'27mmps') ~= 0)
                                vAlign='top';
                            end
                            hAlign='left';
                        case 'umat41'
                            vAlign='top';
                            if(contains(simulationFile,'27mmps') ~= 0)
                                vAlign='bottom';
                            end
                            hAlign='left';
                        otherwise
                            
                    end
                    plot( [ln1,ln2],...
                          [fn1,fn2],...
                          '-','Color',simulationColor);
                    hold on;                                    
                    text(ln2,fn2,...
                         sprintf('%1.2f%s',fn1,'$$f^M_o$$'),...
                         'Color',[0,0,0],...
                         'HorizontalAlignment',hAlign,...
                         'VerticalAlignment',vAlign,...
                         'Color',simulationColor);
                    hold on;  

                end
                                
                if(indexLengths==indexInjury)

    
    
                    idxActiveMinor = find(lsdynaMuscleUniform.fmtN >= tfActiveMinorN,1);
                    idxActiveMajor = find(lsdynaMuscleUniform.fmtN >= tfActiveMajorN,1);
                    idxActiveRupture = find(lsdynaMuscleUniform.fmtN >= tfActiveRuptureN,1);
                   
                    idxInjuryVector = [idxActiveMinor;idxActiveMajor;idxActiveRupture];
    
                    %lceNDomain=[lsdynaMuscleUniform.lceN(idxS,1);...
                    %            lsdynaMuscleUniform.lceN(idxE,1)];

    
                    for idxInjury=1:1:length(idxInjuryVector)
                        k = idxInjuryVector(idxInjury,1);
                        plot(lsdynaMuscleUniform.lceN(k,1),...
                             lsdynaMuscleUniform.fmtN(k,1),...
                             'o','Color',simulationColor,...
                             'MarkerFaceColor',[1,1,1]);
                        hold on;
                        text(lsdynaMuscleUniform.lceN(k,1),...
                             lsdynaMuscleUniform.fmtN(k,1),...
                             sprintf('%1.2f',lsdynaMuscleUniform.lceN(k,1)),...
                             'HorizontalAlignment','right',...
                             'VerticalAlignment','bottom');
                        hold on;
                    end
                    



                
                    minorInjuryN = lsdynaMuscleUniform.act.*(tfActiveMinorN-tfPassiveMinorN) ...
                                 + tfPassiveMinorN;
                    majorInjuryN = lsdynaMuscleUniform.act.*(tfActiveMajorN-tfPassiveMajorN) ...
                                 + tfPassiveMajorN;
                    ruptureInjuryN = lsdynaMuscleUniform.act.*(tfActiveRuptureN-tfPassiveRuptureN) ...
                                 + tfPassiveRuptureN;
    
    
                    subplot('Position',reshape(...
                    subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4));

                    if(indexModel==1)
                        plot(lsdynaMuscleUniform.time(:,1),...
                             minorInjuryN(:,1).*muscleArchitecture.fiso,...
                             '--','Color',[1,1,1].*0.5,'LineWidth',0.5);
                        hold on
                        plot(lsdynaMuscleUniform.time(:,1),...
                             majorInjuryN(:,1).*muscleArchitecture.fiso,...
                             '-','Color',[1,1,1].*0.5,'LineWidth',0.5);
                        hold on
                        plot(lsdynaMuscleUniform.time(:,1),...
                             ruptureInjuryN(:,1).*muscleArchitecture.fiso,...
                             '-','Color',[0,0,0],'LineWidth',1);
                        hold on;
                    end
                    
    
                    for idxInjury=1:1:length(idxInjuryVector)
                        k = idxInjuryVector(idxInjury,1);
                        plot(lsdynaMuscleUniform.time(k,1),...
                             lsdynaMuscleUniform.fmtN(k,1).*muscleArchitecture.fiso,...
                             'o','Color',simulationColor,...
                             'MarkerFaceColor',[1,1,1]);
                        hold on;
                        text(lsdynaMuscleUniform.time(k,1),...
                             lsdynaMuscleUniform.fmtN(k,1).*muscleArchitecture.fiso,...
                             sprintf('%1.2f',lsdynaMuscleUniform.fmtN(k,1).*muscleArchitecture.fiso),...
                             'HorizontalAlignment','right',...
                             'VerticalAlignment','bottom');
                        hold on;
                    end

                    subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4));
    
                    if(indexModel==1)
                        text(lsdynaMuscleUniform.time(1,1),...
                             minorInjuryN(1,1).*muscleArchitecture.fiso,'Minor Injury',...
                             'HorizontalAlignment','left',...
                             'VerticalAlignment','bottom');
                        hold on;
                        text(lsdynaMuscleUniform.lceN(1,1),...
                             majorInjuryN(1,1).*muscleArchitecture.fiso,'Major Injury',...
                             'HorizontalAlignment','left',...
                             'VerticalAlignment','bottom');
                        hold on;
                        text(lsdynaMuscleUniform.lceN(1,1),...
                             ruptureInjuryN(1,1).*muscleArchitecture.fiso,'Rupture',...
                             'HorizontalAlignment','left',...
                             'VerticalAlignment','bottom');
                        hold on;   
                    end
    
                end
                
            end
%             subplot('Position',reshape(...
%                         subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4));            
%         
%             ylim(yLimForce(indexLengths,:));
%             xlim(xLimForce(indexLengths,:));            
     
    
        subplot('Position',reshape(...
            subPlotLayout(indexRowB,indexColumn+subPlotColOffset,:),1,4));
            
            if(dl > 2)
                plot(   lsdynaBinout.elout.beam.time',...
                        changeInLengthFromOptimal.*m2mm,...
                        '--','Color', simulationColor,...
                        'LineWidth',lineWidthModel);
                hold on;
            end
    
            box off;   

        %Manually add the legend
        maxStim=getParameterValueFromD3HSPFile(d3hspFileName,'STIMHIGH');
        rampLenS=getParameterValueFromD3HSPFile(d3hspFileName,'RAMPLENS');
        rampLenE=getParameterValueFromD3HSPFile(d3hspFileName,'RAMPLENE');

        if(contains(simulationFile,'isometric')==0 && ...
           contains(simulationFile,  'passive')==0)

            for indexLegend=1:1:3

                rampTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMES');
                rampTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMEE');
                stimTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'STIMTIMEE');

                columnNumber=indexColumn+subPlotColOffset;
                switch indexLegend
                    case 1
                        subplot('Position',reshape(...
                            subPlotLayout(indexRowA,indexColumn+subPlotColOffset,:),1,4)); 
                        if(columnNumber <= 9)
                            xTxt = stimTimeE-2.5;
                            yTxt = 17;
                            dy = 40*(1.75/40);
                            dx1 = 12*(0.25/12);
                            dx2 = 12*(1/12);
                        else
                            xTxt = stimTimeE - 2;
                            yTxt = 18;
                            dy = 80*(1.75/40);
                            dx1 = 18*(0.25/12);
                            dx2 = 18*(1/12);
                        end
                    case 2
                        subplot('Position',reshape(...
                            subPlotLayout(indexRowB,indexColumn+subPlotColOffset,:),1,4)); 
                        if(columnNumber <= 9)
                            xTxt = 8;
                            yTxt = 7;
                            dy = 9*4*(1.75/40);
                            dx1 = (12)*(0.25/12);
                            dx2 = (12)*(1/12);
                        else
                            xTxt =  15;
                            yTxt =  30;
                            dy  = 52*(4*1.75/40);
                            dx1 = (20)*(0.25/12);
                            dx2 = (20)*(1/12);
                        end
                    case 3
                        subplot('Position',reshape(...
                            subPlotLayout(indexRowC,indexColumn+subPlotColOffset,:),1,4)); 
                        if(columnNumber <= 9)
                            xTxt = 0.6;
                            yTxt = 1.7;
                            dy = 1.75*(1.75/40);
                            dx1 = (1.3-0.5)*(0.25/12);
                            dx2 = (1.3-0.5)*(1/12);
                        else
                            xTxt =  0.7;
                            yTxt =  2;
                            dy  = 4*(1.75/40);
                            dx1 = (2-0.5)*(0.25/12);
                            dx2 = (2-0.5)*(1/12);
                        end                        
                        
                end

                            
                switch lsdynaMuscleUniform.name
                    case 'mat156'
                        if(columnNumber <= 9)
                            text(xTxt,yTxt,'HL2002',...
                                'HorizontalAlignment','left','FontSize',6);
                            hold on;
                            plot([xTxt-dx2,xTxt-dx1],[1,1].*yTxt,'-',...
                                'Color',[0,0,0],'LineWidth',1.5);
                            hold on;
                        end
        
                        text(xTxt,yTxt-dy,lsdynaMuscleUniform.nameLabel,...
                            'HorizontalAlignment','left','FontSize',6);
                        hold on;
                        plot([xTxt-dx2,xTxt-dx1],[1,1].*(yTxt-dy),'-',...
                            'Color',simulationColor,'LineWidth',1.);
                        hold on;
                    case 'umat41'
                        text(xTxt,yTxt-2*dy,lsdynaMuscleUniform.nameLabel,...
                            'HorizontalAlignment','left','FontSize',6);
                        hold on;
                        plot([xTxt-dx2,xTxt-dx1],[1,1].*(yTxt-2*dy),'-',...
                            'Color',simulationColor,'LineWidth',1.);
                        hold on;                
                    case 'umat43'
                        text(xTxt,yTxt-3*dy,lsdynaMuscleUniform.nameLabel,...
                            'HorizontalAlignment','left','FontSize',6);
                        hold on;
                        plot([xTxt-dx2,xTxt-dx1],[1,1].*(yTxt-3*dy),'-',...
                            'Color',simulationColor,'LineWidth',1.);
                        hold on;                
                end
            end


        end
%             ylim(yLimRamp(indexLengths,:));
%             xlim(xLimRamp(indexLengths,:));            

%         subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));
%         xlabel('Time (s)');
%         ylabel('Force (N)');
%    
%         plotLabel1 = '';
%         plotLabel2 = '';
%         velLabel = '';
%         switch indexColumn
%             case 1
%                 plotLabel1 = 'A';
%                 plotLabel2 = 'B';
%                 velLabel   = '3 mm/s';
%                 
%             case 2
%                 plotLabel1 = 'C';
%                 plotLabel2 = 'D';
%                 velLabel   = '9 mm/s';
%                 
%             case 3
%                 plotLabel1 = 'E';
%                 plotLabel2 = 'F';
%                 velLabel   = '27 mm/s';
%                 
%             otherwise
%                 assert(0,'Error: invalid indexColumn');
%         end        
%         
%         title([plotLabel1,'. ',lsdynaMuscleUniform.nameLabel]);
%         box off;
%         xticks([0:2:14]);
%         yticks([0:10:40])
%         ylim(yLimForce);
%         xlim(xLimForce);
%     
%         subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));
%         xlabel('Time (s)');
%         ylabel('Length (mm)');
%         title([plotLabel2,'. Ramps']);
%         box off;
%         xticks([0:2:14]);
%         yticks([0,9])
%         ylim(yLimRamp);
%         xlim(xLimRamp);
    end

    

end

