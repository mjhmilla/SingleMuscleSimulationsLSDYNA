function figH = plotEccentricSimulationData(figH,...
                      lsdynaBinout,lsdynaMuscleUniform,d3hspFileName, ...
                      indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...   
                      optimalFiberLength, maximumIsometricForce, tendonSlackLength,...
                      flag_addReferenceData,...
                      flag_addSimulationData,...
                      simulationColorA, simulationColorB, ...
                      referenceColorA, referenceColorB)

figure(figH);

subplot('Position', reshape( subPlotLayout(1,indexColumn,:),1,4 ) );

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
    rampLengths = [3,6,9];

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
        indexRowA = (indexFile-1)*2+1;
        indexRowB = indexRowA+1;
        
        %Plot the reference isometric force datda
        for indexForceColumn=(length(data.colheaders)-1):-2:2     
            n = (indexForceColumn-2)/(length(data.colheaders)-1);    
            referenceColor = referenceColorB.*(1-n)+referenceColorA.*n;
            indexLengthColumn = indexForceColumn+1;

            subplot('Position',...
                    reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));   

            if(isIsometricColumn(1,indexForceColumn)==1)

                %Plot the isometric trial that takes place at 9mm
                if(  data.data(end,indexLengthColumn) > 8.5)
                    fill([data.data(1,indexTime);...
                          data.data(:,indexTime);...
                          data.data(end,indexTime)],...
                         [0;...
                          data.data(:,indexForceColumn);...
                          0],...
                         referenceColor,'EdgeColor','none','FaceAlpha',0.5);
                    hold on;

                    t0 = 2.3+9/3;
                    f0 = max(data.data(:,indexForceColumn));


                    text(   t0,f0,'Exp: f',...
                            'VerticalAlignment','top');
                    hold on;

                    
                    subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));    
                    plot(data.data(:,indexTime), data.data(:,indexForceColumn+1),...
                         'Color',referenceColor,'LineWidth',2);
                    hold on;            

                end
                
            end

        end

        trialCount=0;
        for indexForceColumn=(length(data.colheaders)-1):-2:2  
            indexLengthColumn = indexForceColumn+1;
            n = (indexForceColumn-2)/(length(data.colheaders)-1);    
            referenceColor = referenceColorB.*(1-n)+referenceColorA.*n;

            subplot('Position',...
                    reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));   

            if(   isIsometricColumn(1,indexForceColumn)==0)
             
                plot(data.data(:,indexTime), data.data(:,indexForceColumn),...
                     'Color',referenceColor,'LineWidth',2);
                hold on;

                dl = round(data.data(end,indexLengthColumn) ...
                          -data.data(1,indexLengthColumn)  , 0);

                [valMax,idxMax] = max(data.data(:,indexForceColumn));

                dt = 2;
                t0 = data.data(idxMax,indexTime);
                t1 = t0+dt;

                f0 = valMax;
                f1 = 40-(trialCount/2)*5;

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
                    
                    trialLabel = ['Exp: ', num2str(dl)];
                elseif(isPassiveColumn(1,indexForceColumn) == 1 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    trialLabel = ['Exp: ', 'p'];

                    t1=t0;
                    f1=f0;
                elseif(isPassiveColumn(1,indexForceColumn) == 0 && ...
                   isIsometricColumn(1,indexForceColumn) == 0)
                    trialLabel = ['Exp: ', 'f'];
                    t1=t0;
                    f1=f0;
                end

                text(t1,...
                     f1,...
                     trialLabel);
                hold on;

                if( isPassiveColumn(1,indexForceColumn)==0)
                    subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));

                    plot(data.data(:,indexTime), data.data(:,indexLengthColumn),...
                         'Color',referenceColor,'LineWidth',2);
                    hold on;            

                    text(0.25,...
                         data.data(1,indexLengthColumn),...
                         ['Exp: ', num2str(dl)],...
                         'VerticalAlignment','bottom',...
                         'HorizontalAlignment','left');
                    hold on;
                end
                if(isPassiveColumn(1,indexForceColumn)==0 ...
                        && isIsometricColumn(1,indexForceColumn)==0)
                    trialCount=trialCount+1;
                end
            end

        end
        subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));
        xlabel('Time (s)');
        ylabel('Force (N)');
        title(['Active lengthening (',dataLabels{indexFile},')']);
        box off;
        xticks([0:2:14]);
        yticks([0:10:40])

        subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));
        xlabel('Time (s)');
        ylabel('Length (mm)');
        title(['Active lengthening (',dataLabels{indexFile},')']);
        box off;
        xticks([0:2:14]);
        yticks([0:2:10])
        
    end

    here=1;
end

% Add the simulation data
if(flag_addSimulationData)
    n = (indexSimulation-1)/(totalSimulations-1);

    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;

    rampSpeedLabel = {'3mmps','9mmps','27mmps'};
    rampSpeed = [3,9,27];
    indexRamp = 0;
    for i=1:1:length(rampSpeedLabel)
        if(contains(simulationFile,rampSpeedLabel{i}))
            indexRamp=i;
        end
    end

    indexRowA = (indexRamp-1)*2+1;
    indexRowB = indexRowA+1;

    %Get the reference length PATHLEN0 stored in the d3hsp file
    pathLen = getParameterValueFromD3HSPFile(d3hspFileName,'PATHLENO');
    m2mm=1000;

    

    
    subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));
 
        plot(lsdynaBinout.elout.beam.time',...
             lsdynaBinout.elout.beam.axial,...
             'Color', simulationColor,...
             'LineWidth',1.0);
        hold on;
        box off;    

        changeInLength = -( lsdynaBinout.nodout.z_coordinate ...
                           -lsdynaBinout.nodout.z_coordinate(1,1));
                       
        changeInLengthFromOptimal = -(lsdynaBinout.nodout.z_coordinate+pathLen);
                       
        changeInLength=changeInLength.*(m2mm); %m to mm
        dl = round(changeInLength(end,1)-changeInLength(1,1),0);
        
        maxStim=0;
        if(isempty(lsdynaMuscleUniform))
            maxStim = max(lsdynaMuscleUniform.exc);
        end
        
                   


        if(dl > 2 && maxStim > 0.5)
            rampTimeS = getParameterValueFromD3HSPFile(d3hspFileName,'RAMPTIMES');        
            t0=rampTimeS+0.1;
            f0 = interp1(lsdynaBinout.elout.beam.time', ...
                       lsdynaBinout.elout.beam.axial,...
                       t0);                        
            dt = 1;

            t1 = 2;
            f1 = 38 - ((dl-3)/6)*5;

            plot([t0,t1],...
                 [f0,f1],...
                 'Color',simulationColor);
            hold on;
            
            plot(t0,f0,...
                 'o','Color',simulationColor,...
                 'MarkerSize',2,...
                 'MarkerFaceColor',[1,1,1]);
            hold on;

            text(t1,f1,['Sim: ',num2str(dl)],...
                 'Color',simulationColor,...
                 'HorizontalAlignment','right',...
                 'VerticalAlignment','middle');
            hold on;
        end
    
 

    subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));
        
        plot(lsdynaBinout.elout.beam.time',...
         changeInLengthFromOptimal.*m2mm,...
         'Color', simulationColor,...
         'LineWidth',1.0);
        hold on;

        if(dl > 2 && maxStim > 0.5)
            text(2.3+(9/rampSpeed(1,indexRamp))-dl/rampSpeed(1,indexRamp)+0.25,...
                 changeInLengthFromOptimal(1,1).*m2mm,...
                 ['Sim: ', num2str(dl)],...
                 'Color',simulationColor,...
                 'VerticalAlignment','bottom', ...
                 'HorizontalAlignment','left');
            hold on;
        end

        box off;            

end

