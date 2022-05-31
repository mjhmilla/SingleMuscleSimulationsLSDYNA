function figH = plotSinusoidSimulationDataUmat43(figH, musout, curveData, indexColumn,...
                      subPlotLayout,subPlotRows,subPlotColumns,...                      
                      simulationFile,indexSimulation, totalSimulations,... 
                      referenceDataFolder,...                      
                      flag_addReferenceData,...
                      flag_addSimulationCurveData,...
                      flag_addSimulationOutputData)

figure(figH);


simulationColor = [0,0,1];%simulationColorA;
referenceColor=[1,1,1].*0.75;%referenceColorA;
lineType = '-';

if( max(musout.data(:,musout.indexAct)) > 0.5 )
    simulationColor = [1,0,0];
    referenceColor=[1,1,1].*0.75;
    lineType = '--';    
end


% Add the reference data
if(flag_addReferenceData==1)


    files = dir(referenceDataFolder);
    for indexFiles=3:1:length(files)
        found=0;
        xlabelText = '';
        ylabelText = '';
        y1DerlabelText = '';
        y2DerlabelText = '';
        titleText = '';
        subplotA = [];
        subplotB = [];
        subplotC = [];  
        
        if( contains( files(indexFiles).name, 'fortran_activeForceLengthCurveFeline'))
            data = csvread([referenceDataFolder,'/',files(indexFiles).name],1,0); 
            subplotA = reshape( subPlotLayout(1,1,:),1,4 );
            subplotB = reshape( subPlotLayout(1,2,:),1,4 );
            subplotC = reshape( subPlotLayout(1,3,:),1,4 );                         
            found=1  ; 
            
            xlabelText = 'Norm. Length ($\ell^{\mathrm{M}}_n$)';
            ylabelText = '$f^{L}$)';
            y1DerlabelText = '$d f^{L}/ d \ell^{\mathrm{M}}_n$';
            y2DerlabelText = '$d^2 f^{L}/ d (\ell^{\mathrm{M}}_n)^2$';
            titleText = 'Active-Force Length (feline)';
        end
        if( contains( files(indexFiles).name, 'fortran_forceLengthECMHalfCurve'))
            data = csvread([referenceDataFolder,'/',files(indexFiles).name],1,0); 
            subplotA = reshape( subPlotLayout(2,1,:),1,4 );
            subplotB = reshape( subPlotLayout(2,2,:),1,4 );
            subplotC = reshape( subPlotLayout(2,3,:),1,4 ); 
            found=1  ;  
            
            xlabelText = 'Norm. Half Length ($\frac{1}{2}\ell^{\mathrm{M}}_n$)';
            ylabelText = '$f^{ECM}$)';
            y1DerlabelText = '$d f^{ECM}/ d \frac{1}{2} \ell^{\mathrm{M}}_n$';
            y2DerlabelText = '$d^2 f^{ECM}/ d (\frac{1}{2} \ell^{\mathrm{M}}_n)^2$';
            titleText = 'ECM Force-Length';
        end
        
        if( contains( files(indexFiles).name, 'fortran_forceLengthProximalTitinFelineCurve'))
            data = csvread([referenceDataFolder,'/',files(indexFiles).name],1,0); 
            subplotA = reshape( subPlotLayout(3,1,:),1,4 );
            subplotB = reshape( subPlotLayout(3,2,:),1,4 );
            subplotC = reshape( subPlotLayout(3,3,:),1,4 ); 
            found=1  ;  
            
            xlabelText = 'Norm. Half Length ($\frac{1}{2}\ell^{\mathrm{M}}_n$)';
            ylabelText = '$f^{P}$)';
            y1DerlabelText = '$d f^{P}/ d \frac{1}{2} \ell^{\mathrm{M}}_n$';
            y2DerlabelText = '$d^2 f^{P}/ d (\frac{1}{2} \ell^{\mathrm{M}}_n)^2$';
            titleText = 'Titin Proximal Force-Length (Feline)';
        end
        
        if( contains( files(indexFiles).name, 'fortran_forceLengthDistalTitinFelineCurve'))
            data = csvread([referenceDataFolder,'/',files(indexFiles).name],1,0); 
            subplotA = reshape( subPlotLayout(4,1,:),1,4 );
            subplotB = reshape( subPlotLayout(4,2,:),1,4 );
            subplotC = reshape( subPlotLayout(4,3,:),1,4 ); 
            found=1  ;  
            
            xlabelText = 'Norm. Half Length ($\frac{1}{2}\ell^{\mathrm{M}}_n$)';
            ylabelText = '$f^{D}$)';
            y1DerlabelText = '$d f^{D}/ d \frac{1}{2} \ell^{\mathrm{M}}_n$';
            y2DerlabelText = '$d^2 f^{D}/ d (\frac{1}{2} \ell^{\mathrm{M}}_n)^2$';
            titleText = 'Titin Distal Force-Length (Feline)';
        end        
        
        if( contains( files(indexFiles).name, 'fortran_fiberForceVelocityCurve'))
            data = csvread([referenceDataFolder,'/',files(indexFiles).name],1,0); 
            subplotA = reshape( subPlotLayout(5,1,:),1,4 );
            subplotB = reshape( subPlotLayout(5,2,:),1,4 );
            subplotC = reshape( subPlotLayout(5,3,:),1,4 ); 
            found=1  ;  
            
            xlabelText = 'Norm. Velocity ($v^{\mathrm{M}} / (\ell^{\mathrm{M}}_\circ v^{\mathrm{M}}_\circ)$)';
            ylabelText = '$f^{V}$)';
            y1DerlabelText = '$d f^{V}/ d v^{\mathrm{M}}$';
            y2DerlabelText = '$d^2 f^{V}/ d v^{\mathrm{M}})^2$';
            titleText = 'Force Velocity Curve';
        end  
        
        if(found==1)
           
            subplot('Position', subplotA );
            plot(   data(:,1),...
                    data(:,2),...
                    'LineWidth',3,...
                    'Color',referenceColor);
            hold on;
            
            dataMinX = min(data(:,1));
            if(flag_addSimulationCurveData==1)
               dataMinX = min(curveData.data(:,curveData.indexArg)); 
            end
            
            plot(   [dataMinX,dataMinX+0.15],...
                    [1,1],...
                    'LineWidth',3,...
                    'Color',referenceColor);
            hold on;
            text(dataMinX+0.15,1,'Matlab');
            hold on;
            box off;        
            xlabel(xlabelText);
            ylabel(ylabelText);
            title(titleText)
    
            subplot('Position', subplotB );
            plot(   data(:,1),...
                    data(:,3),...
                    'LineWidth',3,...
                    'Color',referenceColor);
            hold on;
            box off;        
            xlabel(xlabelText);
            ylabel(y1DerlabelText);
            title([titleText,': $1^{st}$ Der']);
    
            subplot('Position', subplotC);
            plot(   data(:,1),...
                    data(:,4),...
                    'LineWidth',3,...
                    'Color',referenceColor);
            hold on;
            box off;        
            xlabel(xlabelText);
            ylabel(y2DerlabelText);
            title([titleText,'$2^{nd}$ Der']);  
        end
        
    end


end

% Add the simulation data
if(flag_addSimulationCurveData)
%    n = (indexSimulation-1)/(totalSimulations-1);
%    simulationColor = (1-n).*simulationColorA + (n).*simulationColorB;

    subplotA = [];
    subplotB = [];
    subplotC = [];
    if(contains(curveData.name,'fal')==1)
      subplotA = reshape( subPlotLayout(1,1,:),1,4 );
      subplotB = reshape( subPlotLayout(1,2,:),1,4 );
      subplotC = reshape( subPlotLayout(1,3,:),1,4 );      
    end
    if(contains(curveData.name,'fecmH')==1)
      subplotA = reshape( subPlotLayout(2,1,:),1,4 );
      subplotB = reshape( subPlotLayout(2,2,:),1,4 );
      subplotC = reshape( subPlotLayout(2,3,:),1,4 );      
    end
    if(contains(curveData.name,'f1H')==1)
      subplotA = reshape( subPlotLayout(3,1,:),1,4 );
      subplotB = reshape( subPlotLayout(3,2,:),1,4 );
      subplotC = reshape( subPlotLayout(3,3,:),1,4 );      
    end
    if(contains(curveData.name,'f2H')==1)
      subplotA = reshape( subPlotLayout(4,1,:),1,4 );
      subplotB = reshape( subPlotLayout(4,2,:),1,4 );
      subplotC = reshape( subPlotLayout(4,3,:),1,4 );      
    end
    
    if(contains(curveData.name,'fv')==1)
      subplotA = reshape( subPlotLayout(5,1,:),1,4 );
      subplotB = reshape( subPlotLayout(5,2,:),1,4 );
      subplotC = reshape( subPlotLayout(5,3,:),1,4 );      
    end
    
    minCurveDataX = min(curveData.data(:,curveData.indexArg));
    
    subplot('Position', subplotA );
    plot(   curveData.data(:,curveData.indexArg),...
            curveData.data(:,curveData.indexValue),...
            lineType,'Color',simulationColor);
    hold on;  
        
    plot(   [minCurveDataX,minCurveDataX+0.15],...
            [1,1].*(1-0.05*indexSimulation),...
            lineType,'Color',simulationColor );
    hold on;
    text( minCurveDataX+0.15, 1-0.05*indexSimulation,'Fortran');
    hold on;

    subplot('Position', subplotB );
    plot(   curveData.data(:,curveData.indexArg),...
            curveData.data(:,curveData.index1stDer),...
            lineType,'Color',simulationColor)
    hold on;
    box off;        

    subplot('Position', subplotC );
    plot(   curveData.data(:,curveData.indexArg),...
            curveData.data(:,curveData.index2ndDer),...
            lineType,'Color',simulationColor)
    hold on;
    box off;  
 
end

if(flag_addSimulationOutputData==1)
    subplotA = reshape( subPlotLayout(6,1,:),1,4 );
    subplotB = reshape( subPlotLayout(6,2,:),1,4 );
    subplotC = reshape( subPlotLayout(6,3,:),1,4 );
    
    subplot('Position',subplotA);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexDTVmWDt),...
          lineType,'Color', simulationColor)
    hold on;
    box off;
    xlabel('Time (s)');
    ylabel('Power (J/s)');
    title('d/dt T+V-W');
       
    subplot('Position',subplotB);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexFceN),...
          lineType,'Color', simulationColor);
    hold on;
    box off;
    xlabel('Time (s)');
    ylabel('Norm. Force $$f/f^{M}_{\circ}$$');
    title('CE Force');
    
    subplot('Position',subplotC);    
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexFecmHN),...
          lineType,'Color',simulationColor);
    hold on;
    box off;
    xlabel('Time (s)');
    ylabel('Norm. Force $$f/f^{M}_{\circ}$$');
    title('ECM Force');    
          
    
    subplotA = reshape( subPlotLayout(7,1,:),1,4 );
    subplotB = reshape( subPlotLayout(7,2,:),1,4 );
    subplotC = reshape( subPlotLayout(7,3,:),1,4 );    
    

    subplot('Position',subplotA);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexF1HN),...
          lineType,'Color', simulationColor);
    hold on;
    box off;      
    xlabel('Time (s)');
    ylabel('Norm. Force $$f/f^{M}_{\circ}$$');
    title('Distal Titin (f1) Force');
    
    subplot('Position',subplotB);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexF2HN),...
          lineType,'Color', simulationColor);
    hold on;
    box off;      
    xlabel('Time (s)');
    ylabel('Norm. Force $$f/f^{M}_{\circ}$$');
    title('Distal Titin (f2) Force');
      
    subplot('Position',subplotC);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexFxHN),...
          lineType,'Color', simulationColor);
    hold on;      
    box off;
    xlabel('Time (s)');
    ylabel('Norm. Force $$f/f^{M}_{\circ}$$');
    title('XE Force');    
    
    
    subplotA = reshape( subPlotLayout(8,1,:),1,4 );
    subplotB = reshape( subPlotLayout(8,2,:),1,4 );
    subplotC = reshape( subPlotLayout(8,3,:),1,4 );    
    
    subplot('Position',subplotA);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexLp),...
          lineType,'Color', simulationColor)
    hold on;
    box off;
    xlabel('Time (s)');
    ylabel('Length');
    title('Path Length');    

    subplot('Position',subplotB);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexLceN),...
          lineType,'Color', simulationColor)
    hold on;
    box off;
    xlabel('Time (s)');
    ylabel('Norm. Length $$\ell^{M}/\ell^{M}_{\circ}$$');
    title('CE Length');     
    
    subplot('Position',subplotC);
    plot( musout.data(:,musout.indexTime),...
          musout.data(:,musout.indexLxHN),...
          lineType,'Color', simulationColor)
    hold on;
    box off;
    xlabel('Time (s)');
    ylabel('Norm. Length $$\ell^{X}/\ell^{M}_{\circ}$$');
    title('Cross-bridge Length $$\ell^{X}$$');    
    
end


