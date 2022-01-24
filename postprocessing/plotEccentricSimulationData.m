function figH = plotEccentricSimulationData(figH,lsdynaBinout,lsdynaMuscle, ...
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
    dataFiles = {'dataHerzogLeonard2002Figure7A.csv',...
                 'dataHerzogLeonard2002Figure7B.csv',...
                 'dataHerzogLeonard2002Figure7C.csv'};
    dataLabels = {'3mm/s','9mm/s','27mm/s'};
    %dataFig7A = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7A.csv']);
    %dataFig7B = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7B.csv']);
    %dataFig7C = importdata([referenceDataFolder,'/','dataHerzogLeonard2002Figure7C.csv']);    

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

                    text(   data.data(end,indexTime),...
                            data.data(end,indexForceColumn),...
                            'f')
                    hold on;

                    subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));    
                    plot(data.data(:,indexTime), data.data(:,indexForceColumn+1),...
                         'Color',referenceColor,'LineWidth',2);
                    hold on;            

                end
                
            end

        end

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


                plot(data.data(end,indexTime).*[1.0, 1.05],...
                     data.data(end,indexForceColumn).*[1,1],...
                     '-','Color',[0,0,0]);
                hold on;

                text(data.data(end,indexTime)*1.05,...
                     data.data(end,indexForceColumn),...
                     ['Exp: ', num2str(dl)]);
                hold on;

                subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));    
                plot(data.data(:,indexTime), data.data(:,indexLengthColumn),...
                     'Color',referenceColor,'LineWidth',2);
                hold on;            
                
                text(data.data(1,indexTime)+0.025*data.data(end,indexTime),...
                     data.data(1,indexLengthColumn),...
                     ['Exp: ', num2str(dl)]);
                hold on;
                
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

    rampSpeed = {'3mmps','9mmps','27mmps'};
    
    indexRamp = 0;
    for i=1:1:length(rampSpeed)
        if(contains(simulationFile,rampSpeed{i}))
            indexRamp=i;
        end
    end

    indexRowA = (indexRamp-1)*2+1;
    indexRowB = indexRowA+1;

    subplot('Position',reshape(subPlotLayout(indexRowA,indexColumn,:),1,4));
 
        plot(lsdynaBinout.elout.beam.time',...
             lsdynaBinout.elout.beam.axial,...
             'Color', simulationColor);
        hold on;
        box off;    

        changeInLength = -( lsdynaBinout.nodout.z_coordinate ...
                           -lsdynaBinout.nodout.z_coordinate(1,1));
        changeInLength=changeInLength.*(1000); %m to mm
        dl = round(changeInLength(end,1)-changeInLength(1,1),0);
        
        [valMax,idxMax] = max(lsdynaBinout.elout.beam.axial);

        text(lsdynaBinout.elout.beam.time(1,idxMax),...
             lsdynaBinout.elout.beam.axial(idxMax,1),...
             num2str(dl),...
             'Color',simulationColor);
        hold on;

    subplot('Position',reshape(subPlotLayout(indexRowB,indexColumn,:),1,4));
 

        plot(lsdynaBinout.elout.beam.time',...
             changeInLength,...
             'Color', simulationColor);
        hold on;

        text(lsdynaBinout.nodout.time(1,1)+0.025*lsdynaBinout.nodout.time(1,end),...
             changeInLength(1,1),...
             ['Sim: ', num2str(dl)],...
             'Color',simulationColor);
        hold on;


        box off;            
end

