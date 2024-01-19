function [subPlotPanel,pageWidth,pageHeight]  = ...
    plotConfigPublication(numberOfHorizontalPlotColumns, ...
                      numberOfVerticalPlotRows,...
                      plotWidth,...
                      plotHeight,...
                      plotHorizMarginCm,...
                      plotVertMarginCm,...
                      simulationTypeStr,...
                      baseFontSize)

pageWidth   = numberOfHorizontalPlotColumns*(plotWidth+plotHorizMarginCm)...
                +2*plotHorizMarginCm;
pageHeight  = numberOfVerticalPlotRows*(plotHeight+plotVertMarginCm)...
                +2*plotVertMarginCm;

plotWidth  = plotWidth/pageWidth;
plotHeight = plotHeight/pageHeight;

plotHorizMargin = plotHorizMarginCm/pageWidth;
plotVertMargin  = plotVertMarginCm/pageHeight;

topLeft = [0/pageWidth pageHeight/pageHeight];

subPlotPanel=zeros(numberOfVerticalPlotRows,numberOfHorizontalPlotColumns,4);
subPlotPanelIndex = zeros(numberOfVerticalPlotRows,numberOfHorizontalPlotColumns);


switch (simulationTypeStr)
    case 'eccentric_HerzogLeonard2002'
        assert(numberOfVerticalPlotRows==3);
        idx=1;
        scalePlotHeight = 0.;
        for(ai=1:1:numberOfVerticalPlotRows)

          switch ai
              case 1
                  scalePlotHeight = 1;
              case 2
                  scalePlotHeight = 1/4;
              case 3
                  scalePlotHeight = 1;
              otherwise
                  assert(0,'Error: eccentric publication plots not configured for more than 3 rows');
          end

          subPlotHeight = scalePlotHeight*plotHeight;

          for(aj=1:1:numberOfHorizontalPlotColumns)
              subPlotPanelIndex(ai,aj) = idx;
              scaleHorizMargin=1;

              if(ai==1)
                  subPlotPanel(ai,aj,1) = topLeft(1) + plotHorizMargin...
                                        + (aj-1)*(plotWidth + plotHorizMargin);
                  %-plotVertMargin*scaleVerticalMargin ...                             
                  subPlotPanel(ai,aj,2) = topLeft(2) -subPlotHeight -plotVertMargin...                            
                                        + (ai-1)*(-subPlotHeight -plotVertMargin);
                  subPlotPanel(ai,aj,3) = (plotWidth);
                  subPlotPanel(ai,aj,4) = (subPlotHeight);
              else
                  subPlotPanel(ai,aj,1) = subPlotPanel(ai-1,aj,1);
                     
                  subPlotPanel(ai,aj,2) = subPlotPanel(ai-1,aj,2) ...                            
                                      + (-subPlotHeight-plotVertMargin );
                  subPlotPanel(ai,aj,3) = subPlotPanel(ai-1,aj,3);
                  subPlotPanel(ai,aj,4) = (subPlotHeight);

              end
              idx=idx+1;
          end
        end       

    case 'active_passive_force_length'
        idx=1;
        scalePlotHeight=1;
        subPlotHeight = scalePlotHeight*plotHeight;
        for(ai=1:1:numberOfVerticalPlotRows)
            for(aj=1:1:numberOfHorizontalPlotColumns)
                subPlotPanelIndex(ai,aj) = idx;
                scaleHorizMargin=1;
                
              if(ai==1)
                  subPlotPanel(ai,aj,1) = topLeft(1) + plotHorizMargin...
                                        + (aj-1)*(plotWidth + plotHorizMargin);
                  %-plotVertMargin*scaleVerticalMargin ...                             
                  subPlotPanel(ai,aj,2) = topLeft(2) -subPlotHeight -plotVertMargin...                            
                                        + (ai-1)*(-subPlotHeight -plotVertMargin);
                  subPlotPanel(ai,aj,3) = (plotWidth);
                  subPlotPanel(ai,aj,4) = (subPlotHeight);
              else
                  subPlotPanel(ai,aj,1) = subPlotPanel(ai-1,aj,1);
                     
                  subPlotPanel(ai,aj,2) = subPlotPanel(ai-1,aj,2) ...                            
                                      + (-subPlotHeight-plotVertMargin );
                  subPlotPanel(ai,aj,3) = subPlotPanel(ai-1,aj,3);
                  subPlotPanel(ai,aj,4) = (subPlotHeight);

              end
                  idx=idx+1;
            end
        end

    case 'force_velocity'   
        idx=1;
        scalePlotHeight=1;
        subPlotHeight = scalePlotHeight*plotHeight;
        for(ai=1:1:numberOfVerticalPlotRows)
            for(aj=1:1:numberOfHorizontalPlotColumns)
                subPlotPanelIndex(ai,aj) = idx;
                scaleHorizMargin=1;
                
              if(ai==1)
                  subPlotPanel(ai,aj,1) = topLeft(1) + plotHorizMargin...
                                        + (aj-1)*(plotWidth + plotHorizMargin);
                  %-plotVertMargin*scaleVerticalMargin ...                             
                  subPlotPanel(ai,aj,2) = topLeft(2) -subPlotHeight -plotVertMargin...                            
                                        + (ai-1)*(-subPlotHeight -plotVertMargin);
                  subPlotPanel(ai,aj,3) = (plotWidth);
                  subPlotPanel(ai,aj,4) = (subPlotHeight);
              else
                  subPlotPanel(ai,aj,1) = subPlotPanel(ai-1,aj,1);
                     
                  subPlotPanel(ai,aj,2) = subPlotPanel(ai-1,aj,2) ...                            
                                      + (-subPlotHeight-plotVertMargin );
                  subPlotPanel(ai,aj,3) = subPlotPanel(ai-1,aj,3);
                  subPlotPanel(ai,aj,4) = (subPlotHeight);

              end
                  idx=idx+1;
            end
        end
    otherwise
        assert(0,['Error: publication plot configuration not',...
                  ' yet added for: ',simulationTypeStr]);
end




plotFontName = 'latex';

set(groot, 'defaultAxesFontSize',baseFontSize);
set(groot, 'defaultTextFontSize',baseFontSize);
set(groot, 'defaultAxesLabelFontSizeMultiplier',1.1);
set(groot, 'defaultAxesTitleFontSizeMultiplier',1.1);
set(groot, 'defaultAxesTickLabelInterpreter','latex');
%set(groot, 'defaultAxesFontName',plotFontName);
%set(groot, 'defaultTextFontName',plotFontName);
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultAxesTitleFontWeight','normal');  
set(groot, 'defaultFigurePaperUnits','centimeters');
set(groot, 'defaultFigurePaperSize',[pageWidth pageHeight]);
set(groot,'defaultFigurePaperType','A4');


