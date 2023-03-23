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

yLimForce = [0,40];
xLimForce = [0,14];

yLimRamp = [-0.5,9.5];
xLimRamp = xLimForce;

% Plot: 9mm ramps at the 3 different speeds on one plot
%
% Row 1: Forces
% Row 2: Ramp length change (much skinnier)

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

    rampVelocities=[3,9,27];
    rampLengths = [9];

    addedReferenceForceLengthCurve = zeros(1,3);

    for indexFile = 1:1:length(dataFiles)
        data = importdata([referenceDataFolder,'/',dataFiles{indexFile}]);
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
                   -min(data.data(:,indexColumnHeader)) < min(rampLengths))
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
        indexRowA = 1;
        indexRowB = indexRowA+1;
        indexRowC = indexRowB+1;
        
        %Plot the reference isometric force datda
        indexPlotedLine = 1;
        numberPlottedLines=3;

        trialCount=0;
        for indexForceColumn=(length(data.colheaders)-1):-2:2  

            indexLengthColumn = indexForceColumn+1;

            if(   isIsometricColumn(1,indexForceColumn)==0)
                             
                %Identify the rate of lengthening
                minL = min(data.data(:,indexLengthColumn));
                maxL = max(data.data(:,indexLengthColumn));

                [timeMinL,indexRampStart] = max( data.data(:,indexLengthColumn)>(minL+1) );
                [timeMaxL,indexRampEnd] = min( data.data(:,indexLengthColumn)<(maxL-1) );
                
                timeRampStart   = data.data(indexRampStart,indexTime);
                timeRampEnd     = data.data(indexRampEnd,indexTime);

                rampVelRough = (maxL-minL)/(timeRampEnd-timeRampStart);
                
                errVel = [1,1,1].*rampVelRough - [3,9,27];
                [errVelMin, indexVel] = min(abs(errVel));

                indexColumn = indexVel;

                if(addedReferenceForceLengthCurve(1,indexColumn)==0)
                    subplot('Position',...
                    reshape(subPlotLayout(indexRowC,indexColumn,:),1,4));

                    falFile = fullfile(referenceCurveFolder,'felineSoleus_activeForceLengthCurve.dat');
                    fpeFile = fullfile(referenceCurveFolder,'felineSoleus_fiberForceLengthCurve.dat');

                    falFcn = readBezierCurveFromCSV(falFile);
                    fpeFcn = readBezierCurveFromCSV(fpeFile);
                    
                    npts=200;
                    xDomain = [falFcn.xEnd(1,1),fpeFcn.xEnd(1,2)];
                    xDelta = xDomain(1,2)-xDomain(1,1);
                    xSample = [xDomain(1,1):(xDelta/(npts-1)):xDomain(1,2)]';
                    ySample = zeros(length(xSample),3);
                    for i=1:1:length(xSample)
                        ySample(i,1)=calcQuadraticBezierYFcnXDerivative(xSample(i,1), falFcn, 0);
                        ySample(i,2)=calcQuadraticBezierYFcnXDerivative(xSample(i,1), fpeFcn, 0);
                        ySample(i,3)=ySample(i,1)+ySample(i,2);
                    end
                    
%                     fill([xSample;xSample(end,1);xSample(1,1)],...
%                          [ySample(:,3);ySample(1,3);ySample(1,3)],...
%                          [1,1,1].*0.75,...
%                          'EdgeColor','none',...
%                          'HandleVisibility','off');
%                     hold on;

                    fill([xSample;xSample(end,1);xSample(1,1)],...
                         [ySample(:,1);ySample(1,1);ySample(1,1)],...
                         [1,1,1].*0.65,...
                         'EdgeColor','none',...
                         'HandleVisibility','off');
                    hold on;

                    fill([xSample;xSample(end,1);xSample(1,1)],...
                         [ySample(:,2);ySample(1,2);ySample(1,2)],...
                         [1,1,1].*0.55,...
                         'EdgeColor','none',...
                         'HandleVisibility','off');
                    hold on;

                    plot(xSample,ySample(:,3),'Color',[1,1,1].*0.75,...
                         'LineWidth',2,'HandleVisibility','off');
                    hold on;                    

                    addedReferenceForceLengthCurve(1,indexColumn) = 1;
                end

                subplot('Position',...
                    reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));  
                
                %n = (indexVel-1)/2;
                %referenceColor = referenceColorB.*(1-n)+referenceColorA.*n;                
                referenceColor = referenceColorA;

                plot(data.data(:,indexTime), ...
                     data.data(:,indexForceColumn),...
                     'Color',referenceColor,'LineWidth',0.5);
                hold on;

                dl = round(data.data(end,indexLengthColumn) ...
                          -data.data(1,indexLengthColumn)  , 0);

                [valMax,idxMax] = max(data.data(:,indexForceColumn));

                dt = 1;
                t0 = data.data(idxMax,indexTime);
                t1 = 1;

                f0 = valMax;
                f1 = f0;
                
                trialLabel = '';
                if(isPassiveColumn(1,indexForceColumn) == 0 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    plot([t0,t1],...
                         [f0,f1],...
                         '-','Color',referenceColor);
                    hold on;  
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

                    subplot('Position',...
                    reshape(subPlotLayout(indexRowC,indexColumn,:),1,4));

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
                        'simulationParametersHerzogLeonard2002.csv']);
                    plot( lceN0(1,1)+( data.data(rampIdx,indexLengthColumn)./(1000*optimalFiberLength)),...
                          data.data(rampIdx,indexForceColumn)./maximumIsometricForce,...
                          '-','Color',referenceColor);
                    hold on;

                    subplot('Position',...
                    reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));

                    t2 = data.data(idxMaxDlDt,indexTime);
                    f2 = data.data(idxMaxDlDt,indexForceColumn); 
                    t3 = 1;
                    f3 = f2;

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
                elseif(isPassiveColumn(1,indexForceColumn) == 1 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    t1=t0;
                    f1=f0;
                    

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

                elseif(isPassiveColumn(1,indexForceColumn) == 0 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    t1=t0;
                    f1=f0;
                    

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

                

                if( isPassiveColumn(1,indexForceColumn)==0)
                    subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));
                    plot(data.data(:,indexTime), data.data(:,indexLengthColumn),...
                         'Color',referenceColor,'LineWidth',0.5);
                    hold on;            

                end
                if(isPassiveColumn(1,indexForceColumn)==0 ...
                        && isIsometricColumn(1,indexForceColumn)==0)
                    trialCount=trialCount+1;
                end


            end

        end

    end


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
                plotLabel1 = 'D';
                plotLabel2 = 'E';
                plotLabel3 = 'F';
                velLabel   = '9 mm/s';
                
            case 3
                plotLabel1 = 'G';
                plotLabel2 = 'H';
                plotLabel3 = 'I';
                velLabel   = '27 mm/s';
                
            otherwise
                assert(0,'Error: invalid indexColumn');
        end
    
        subplot('Position',reshape(subPlotLayout(indexRowA,indexSubplotColumn,:),1,4));
        xlabel('Time (s)');
        ylabel('Force (N)');
        title([plotLabel1,'. Active-lengthening: 9mm \& (',velLabel,')']);
        box off;
        xticks([0:2:14]);
        yticks([0:10:40])
        ylim(yLimForce);
        xlim(xLimForce);
    
        subplot('Position',reshape(subPlotLayout(indexRowB,indexSubplotColumn,:),1,4));
        xlabel('Time (s)');
        ylabel('Length (mm)');
        title([plotLabel2,'. Length profile: 9mm \& ',velLabel]);
        box off;
        xticks([0:2:14]);
        yticks([0:2:10])
        ylim(yLimRamp);
        xlim(xLimRamp); 

        subplot('Position',reshape(subPlotLayout(indexRowC,indexSubplotColumn,:),1,4));
        xlabel('Norm. Length ($$\ell/\ell^{M}_o$$)');
        ylabel('Norm. Force ($$f/f^{M}_o$$)');
        title([plotLabel3,'. Active-lengthening 9mm \& ',velLabel]);
        box off;
        xticks([0.4:0.2:1.6]);
        yticks([0:0.2:1.6])
        ylim([0,1.65]);
        xlim([0.45,1.65]); 
        here=1;
    end
    flag_addReferenceData=0;

end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);

    rampSpeedLabel = {'3mmps','9mmps','27mmps'};
    rampSpeed = [3,9,27];
    indexRamp = 0;

    for i=1:1:length(rampSpeedLabel)
        if(contains(simulationFile,[rampSpeedLabel{i},'_9mm']))
            indexRamp=i;

        end

    end

    indexColumn     = indexRamp;
    simulationColor = simulationColorA;

    %If we have found a ramp that has a 9mm length change, plot it
    if(indexRamp ~= 0)

        indexRowA = 1;
        indexRowB = indexRowA+1;
        indexRowC = indexRowB+1;
    
        %Get the reference length PATHLEN0 stored in the d3hsp file
        pathLen = getParameterValueFromD3HSPFile(d3hspFileName,'PATHLENO');
        m2mm=1000;
    
        subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));
    
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
                     'LineWidth',1);
                hold on;
                box off;    
                                        
            end
    
           
            if(dl > 2 && maxStim > 0.5)
                rampTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMES');
                rampTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMEE');

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

                plot(tE,fE,...
                     'o','Color',simulationColor,...
                     'MarkerSize',2,...
                     'MarkerFaceColor',[1,1,1]);
                hold on;

                plot([tE;t1],[fMax;fMax],...
                     '-','Color',simulationColor);
                hold on;
    
                text(t1,f1,sprintf('%1.1fN',fE),...
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

                plot([t2;tS],[f2;fS],...
                     '-','Color',simulationColor);
                hold on;
    
                text(t2,f2,sprintf('%1.1fN',fS),...
                     'Color',simulationColor,...
                     'HorizontalAlignment','left',...
                     'VerticalAlignment','middle');
                hold on;

                %Position 3
                subplot('Position',reshape(subPlotLayout(indexRowC,indexColumn,:),1,4));

                    idxS = interp1(lsdynaMuscleUniform.time,...
                            [1:1:length(lsdynaMuscleUniform.time)]',...
                            rampTimeS);
                    idxS = round(idxS);

                    idxE = interp1(lsdynaMuscleUniform.time,...
                            [1:1:length(lsdynaMuscleUniform.time)]',...
                            rampTimeE);
                    idxE = round(idxE);
                    
                    plot(lsdynaMuscleUniform.lceN(idxS:idxE,1),...
                         lsdynaMuscleUniform.fmtN(idxS:idxE,1),...
                         '-','Color',simulationColor);
                    hold on;
    
                

                subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));
                
            end
        
            ylim(yLimForce);
            xlim(xLimForce);            
     
    
        subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));
            
            if(dl > 2)
                plot(   lsdynaBinout.elout.beam.time',...
                        changeInLengthFromOptimal.*m2mm,...
                        '--','Color', simulationColor,...
                        'LineWidth',1);
                hold on;
            end
    
            box off;           
            ylim(yLimRamp);
            xlim(xLimRamp);            

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

