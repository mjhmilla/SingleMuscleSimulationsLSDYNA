function [subPlotPanel,pageWidth,pageHeight]  = ...
    plotConfigGeneric(numberOfHorizontalPlotColumns, ...
                      numberOfVerticalPlotRows,...
                      plotWidth,...
                      plotHeight,...
                      plotHorizMarginCm,...
                      plotVertMarginCm,...
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



idx=1;
for(ai=1:1:numberOfVerticalPlotRows)

  for(aj=1:1:numberOfHorizontalPlotColumns)
      subPlotPanelIndex(ai,aj) = idx;
      subPlotPanel(ai,aj,1) = topLeft(1) + plotHorizMargin...
                            + (aj-1)*(plotWidth + plotHorizMargin);
      %-plotVertMargin*scaleVerticalMargin ...                             
      subPlotPanel(ai,aj,2) = topLeft(2) -plotHeight -plotVertMargin...                            
                            + (ai-1)*(-plotHeight -plotVertMargin);
      subPlotPanel(ai,aj,3) = (plotWidth);
      subPlotPanel(ai,aj,4) = (plotHeight);
      idx=idx+1;
  end
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


