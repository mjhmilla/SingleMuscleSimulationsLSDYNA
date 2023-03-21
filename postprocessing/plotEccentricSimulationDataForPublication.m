function figH = plotEccentricSimulationDataForPublication(figH,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexModel,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...   
                      optimalFiberLength, maximumIsometricForce, tendonSlackLength,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

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
        indexRowA = 1;%(indexFile-1)*2+1;
        indexRowB = indexRowA+1;
        
        %Plot the reference isometric force datda
        indexPlotedLine = 1;
        numberPlottedLines=3;

%         for indexForceColumn=(length(data.colheaders)-1):-2:2     
% 
%             
%             indexLengthColumn = indexForceColumn+1;
%
%             subplot('Position',...
%                     reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));   
% 
% 
%             if(isIsometricColumn(1,indexForceColumn)==1 ...
%                     && flag_addIsometricTrials==1)
% 
% 
%                 %Plot the isometric trial that takes place at 9mm
%                 if(  data.data(end,indexLengthColumn) < 0.5)
%                     referenceColor = referenceColorA;
%                     fill([data.data(1,indexTime);...
%                           data.data(:,indexTime);...
%                           data.data(end,indexTime)],...
%                          [0;...
%                           data.data(:,indexForceColumn);...
%                           0],...
%                          referenceColor,'EdgeColor','none','FaceAlpha',0.5);
%                     hold on;
% 
%                     t0 = 2.3+9/3;
%                     f0 = max(data.data(:,indexForceColumn));
% 
% 
%                     text(   t0,f0,'Exp: f',...
%                             'VerticalAlignment','top');
%                     hold on;
% 
%                     
%                     subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));    
%                     plot(data.data(:,indexTime), data.data(:,indexForceColumn+1),...
%                          'Color',referenceColor,'LineWidth',0.5);
%                     hold on;   
% 
%                     indexPlotedLine=indexPlotedLine+1;
% 
%                 end
%                 
%             end
%
%        end

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
                t1 = t0-dt;

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

                elseif(isPassiveColumn(1,indexForceColumn) == 1 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    t1=t0;
                    f1=f0;
                    trialLabel = sprintf('%1.1fN',f0); 

                    plot(t0,f0,...
                         'o','Color',referenceColor,...
                         'MarkerSize',2,...
                         'MarkerFaceColor',[1,1,1]);
                    hold on;                      

                elseif(isPassiveColumn(1,indexForceColumn) == 0 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    t1=t0;
                    f1=f0;
                    trialLabel = sprintf('%1.1fN',f0); 

                    plot(t0,f0,...
                         'o','Color',referenceColor,...
                         'MarkerSize',2,...
                         'MarkerFaceColor',[1,1,1]);
                    hold on;                      

                end

                text(t1,f1,trialLabel,...
                    'VerticalAlignment','bottom',...
                    'HorizontalAlignment','right');
                hold on;

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

        plotLabel1  = '';
        plotLabel2  = '';
        velLabel    = '';
        switch indexSubplotColumn
            case 1
                plotLabel1 = 'A';
                plotLabel2 = 'B';
                velLabel   = '3 mm/s';
                
            case 2
                plotLabel1 = 'C';
                plotLabel2 = 'D';
                velLabel   = '9 mm/s';
                
            case 3
                plotLabel1 = 'E';
                plotLabel2 = 'F';
                velLabel   = '27 mm/s';
                
            otherwise
                assert(0,'Error: invalid indexColumn');
        end
    
        subplot('Position',reshape(subPlotLayout(indexRowA,indexSubplotColumn,:),1,4));
        xlabel('Time (s)');
        ylabel('Force (N)');
        title([plotLabel1,'. Active lengthening (',velLabel,')']);
        box off;
        xticks([0:2:14]);
        yticks([0:10:40])
        ylim(yLimForce);
        xlim(xLimForce);
    
        subplot('Position',reshape(subPlotLayout(indexRowB,indexSubplotColumn,:),1,4));
        xlabel('Time (s)');
        ylabel('Length (mm)');
        title([plotLabel2,'. Ramp profile: 9mm \& ',velLabel]);
        box off;
        xticks([0:2:14]);
        yticks([0:2:10])
        ylim(yLimRamp);
        xlim(xLimRamp);    
    end


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
                rampTimeE = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMEE');

                t0   = rampTimeE;
                idx0 = interp1( lsdynaBinout.elout.beam.time, ...
                                [1:1:length(lsdynaBinout.elout.beam.time)],...
                                t0 );
                idx0 = round(idx0);

                dt = lsdynaBinout.elout.beam.time(1,idx0) ...
                    -lsdynaBinout.elout.beam.time(1,idx0-1);

                idxA = idx0 - round(0.1/dt);
                idxB = idx0 + round(0.1/dt);

                [f0, idxDelta] = max( lsdynaBinout.elout.beam.axial(idxA:idxB,1) );
                t0 = lsdynaBinout.elout.beam.time(1,idxDelta+idxA-1);
                %f0 = interp1(   lsdynaBinout.elout.beam.time', ...
                %                lsdynaBinout.elout.beam.axial,...
                %                t0);

                dt = 1;
                t1 = t0+dt;
                f1 = f0;

                plot(t0,f0,...
                     'o','Color',simulationColor,...
                     'MarkerSize',2,...
                     'MarkerFaceColor',[1,1,1]);
                hold on;

                plot([t0;t1],[f0;f1],...
                     '-','Color',simulationColor);
                hold on;
    
                text(t1,f1,sprintf('%1.1fN',f0),...
                     'Color',simulationColor,...
                     'HorizontalAlignment','left',...
                     'VerticalAlignment','middle');
                hold on;
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

