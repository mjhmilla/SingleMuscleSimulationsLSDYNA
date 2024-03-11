function [figH,dataFvSample]= addHerzogLeonard1997TimeSeriesV2(...
    figH,subplotPosition,labelHL1997,...
    expColorA, expColorB, expMarkerColor,...
    lineColorRampA,lineColorRampB,...
    lineWidth,...
    plotSettings,...
    musclePropertiesExp,...
    contractionDirection,...
    indexDataSeries)

figure(figH);
subplot('Position',subplotPosition);

fisoExp   = musclePropertiesExp.fiso;
lceOptExp = musclePropertiesExp.lceOpt;
lceNOffsetExp = musclePropertiesExp.lceNOffset;
vmaxExp   = musclePropertiesExp.vmax;



fileHL1997Length = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'force_velocity',filesep,...
           'fig_HerzogLeonard1997Fig1A_length.csv'];

fileHL1997Force = ['..',filesep,'..',filesep,'..',filesep,'..',filesep,...
           'ReferenceExperiments',filesep,...
           'force_velocity',filesep,...
           'fig_HerzogLeonard1997Fig1A_forces.csv'];

dataHL1997Length = loadDigitizedData(fileHL1997Length,...
                'Time ($$s$$)','Length ($$mm$$)',...
                {'c01','c02','c03','c04','c05',...
                 'c06','c07','c08','c09','c10','c11'},...
                {'Herzog and Leonard 1997'}); 

dataHL1997Force = loadDigitizedData(fileHL1997Force,...
                'Time ($$s$$)','Force ($$N$$)',...
                {'c01','c02','c03','c04','c05',...
                 'c06','c07','c08','c09','c10','c11'},...
                {'Herzog and Leonard 1997'}); 

switch contractionDirection
    case -1
        idxStart=1;
        idxEnd = 5;
        vSign = -1;
        idxPlotSettings=2;
    case 1
        idxStart=6;
        idxEnd = 10;
        vSign=1;        
        idxPlotSettings=3;
        
    otherwise assert(0,'Error: contractionDirection must be -1 or 1');
end

dataFvSample = zeros(idxEnd-idxStart+1,2);

idxSample=1;
indexSampleTimeVector = zeros(size(dataFvSample,1),1);

idxIsometric=11;

for idx=idxStart:1:idxEnd
    if( vSign > 0)
        dataFvSample(idxSample,1) = ...
          max(diff(dataHL1997Length(idx).y) ...
           ./diff(dataHL1997Length(idx).x));
        dataFvSample(idxSample,1) = dataFvSample(idxSample,1)./1000;                
        dataFvSample(idxSample,1) = dataFvSample(idxSample,1) ./ (lceOptExp);
    
        idxRamp = find(dataHL1997Force(idx).x(:,1)>1.5);
        [dataFvSample(idxSample,2), idxSampleTime] = ...
            max(dataHL1997Force(idx).y(idxRamp,1)./fisoExp);
    
        idxSampleTime = idxSampleTime+idxRamp(1,1)-1;
        indexSampleTimeVector(idxSample,1)=idxSampleTime;
        idxSample     = idxSample+1;
    else
        dataFvSample(idxSample,1) = ...
          min(diff(dataHL1997Length(idx).y) ...
           ./diff(dataHL1997Length(idx).x));
        dataFvSample(idxSample,1) = dataFvSample(idxSample,1)./1000;
        dataFvSample(idxSample,1) = dataFvSample(idxSample,1) ./ (lceOptExp);
    
        idxRamp = find(dataHL1997Force(idx).x(:,1)>1.5);
        [dataFvSample(idxSample,2), idxSampleTime] = ...
            min(dataHL1997Force(idx).y(idxRamp,1)./fisoExp);
    
        idxSampleTime = idxSampleTime+idxRamp(1,1)-1;                
        indexSampleTimeVector(idxSample,1)=idxSampleTime;
        idxSample=idxSample+1;
    end
end


for idx=idxStart:1:idxEnd
    indexData = idx-idxStart;
    idxSample = (idx-idxStart)+1;
    idxSampleTime = indexSampleTimeVector(idxSample,1);
    if(indexData == indexDataSeries)
        n               = (idx-idxStart)/(idxEnd-idxStart);
        expColor        = expColorA.*n + expColorB.*(1-n);
        expRampColor    = lineColorRampA.*n + lineColorRampB.*(1-n);
        
        hVis = 'on';
        %if(idx==idxEnd)
        %    hVis = 'on';
        %end
    
        yyaxis left;
        %if(idx==idxStart)
%             plot(plotSettings(idxPlotSettings).xLim,[1,1],...
%                  '-',...
%                  'Color',[0,0,0],...
%                  'LineWidth',0.5,...
%                  'HandleVisibility','off');
%             hold on;
%             text(min(plotSettings(idxPlotSettings).xLim),1,'$$f^M_o$$',...
%                 'HorizontalAlignment','left',...
%                 'VerticalAlignment','bottom',...
%                 'FontSize',6);
%             hold on;
        %end
    
        flag_plotLine=0;
        if(flag_plotLine==1)
            plot( dataHL1997Force(idx).x(:,1),...
                  dataHL1997Force(idx).y(:,1)./fisoExp,...
                  '-',...
                  'Color',[1,1,1],...
                  'LineWidth',lineWidth+2,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility','off'); 
            hold on;
            plot( dataHL1997Force(idx).x(:,1),...
                  dataHL1997Force(idx).y(:,1)./fisoExp,...
                  '-',...
                  'Color',expColor,...
                  'LineWidth',lineWidth,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility',hVis);   
            hold on;
        else 
            xFill = [0;...
                     dataHL1997Force(idx).x(:,1);...
                     dataHL1997Force(idx).x(end,1);...
                     dataHL1997Force(idx).x(1,1)];

            yFill = [0;...
                     dataHL1997Force(idx).y(:,1)./fisoExp;...
                     0;...
                     0];
            fill(xFill,yFill,expColor,...
                'EdgeColor','none',...
                'DisplayName',labelHL1997,...
                'HandleVisibility',hVis);
            hold on;

            plot(dataHL1997Force(idxIsometric).x(:,1),...
                  dataHL1997Force(idxIsometric).y(:,1)./fisoExp,...
                  '-',...
                  'Color',[1,1,1],...
                  'LineWidth',lineWidth*2,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility','off');
            hold on;

            plot(dataHL1997Force(idxIsometric).x(:,1),...
                  dataHL1997Force(idxIsometric).y(:,1)./fisoExp,...
                  '--',...
                  'Color',expColor,...
                  'LineWidth',lineWidth,...
                  'DisplayName',labelHL1997,...
                  'HandleVisibility','off');
            hold on;

            xWidth  = diff(plotSettings(idxPlotSettings).xLim);
            yHeight = diff(plotSettings(idxPlotSettings).yLim);


            timeFeFdSample = dataHL1997Force(idx).x(idxSampleTime,1)+1;



           
            %x0 = plotSettings(idxPlotSettings).xLim(1,2)-xWidth*0.01;
            x0   = timeFeFdSample;
            x0Max = plotSettings(idxPlotSettings).xLim(1,2)-xWidth*0.01;
            if(x0 > x0Max)
                x0=x0Max;
            end
            y0   = interp1( dataHL1997Force(idx).x, ...
                            dataHL1997Force(idx).y/fisoExp,...
                            timeFeFdSample);

            yIso = dataHL1997Force(idxIsometric).y(end,1)/fisoExp;
            annotationLine = [];

            plot([x0,x0],[y0,(y0+vSign*yHeight*0.05)],'-k',...
                 'HandleVisibility','off');
            hold on;
            plot([x0,x0],[yIso,(yIso-vSign*yHeight*0.05)],'-k',...
                 'HandleVisibility','off');
            hold on;

            dfEnd = y0 -(dataHL1997Force(idxIsometric).y(end,1)./fisoExp);
            
            yTxt=0;
            if(vSign > 0)
                yTxt = (y0+yHeight*0.05);
            else
                yTxt = (yIso+yHeight*0.05);
            end
                text(x0,yTxt,sprintf('%1.3f',dfEnd),...
                     'HorizontalAlignment','right',...
                     'VerticalAlignment','bottom',...
                     'HandleVisibility','off',...
                     'FontSize',6);
                hold on;
%             else
%                 text(x0,(y0+vSign*yHeight*0.05),sprintf('%1.3f',dfEnd),...
%                      'HorizontalAlignment','right',...
%                      'VerticalAlignment','top',...
%                      'HandleVisibility','off',...
%                      'FontSize',6);
%                 hold on;
% 
%             end

        end
    

        plot( dataHL1997Force(idx).x(idxSampleTime,1),...
              dataHL1997Force(idx).y(idxSampleTime,1)./fisoExp,...
              'o',...
              'Color',expMarkerColor,...
              'MarkerFaceColor',expMarkerColor,...
              'LineWidth',lineWidth,...
              'DisplayName',labelHL1997,...
               'MarkerSize',2,...
              'HandleVisibility','off');   
        hold on;
    
    
        yyaxis right;
        plot( dataHL1997Length(idxIsometric).x(:,1),...
              dataHL1997Length(idxIsometric).y(:,1)./(1000*lceOptExp)+lceNOffsetExp,...
              '-',...
              'Color',[1,1,1],...
              'LineWidth',lineWidth+2,...
              'DisplayName',labelHL1997,...
              'HandleVisibility','off');   
        hold on;        
        plot( dataHL1997Length(idxIsometric).x(:,1),...
              dataHL1997Length(idxIsometric).y(:,1)./(1000*lceOptExp)+lceNOffsetExp,...
              '--',...
              'Color',expRampColor,...
              'LineWidth',lineWidth,...
              'DisplayName',labelHL1997,...
              'HandleVisibility','off');   
        hold on;

        plot( dataHL1997Length(idx).x(:,1),...
              dataHL1997Length(idx).y(:,1)./(1000*lceOptExp)+lceNOffsetExp,...
              '-',...
              'Color',[1,1,1],...
              'LineWidth',lineWidth+2,...
              'DisplayName',labelHL1997,...
              'HandleVisibility','off'); 
        hold on;
        plot( dataHL1997Length(idx).x(:,1),...
              dataHL1997Length(idx).y(:,1)./(1000*lceOptExp)+lceNOffsetExp,...
              '-',...
              'Color',expRampColor,...
              'LineWidth',lineWidth,...
              'DisplayName',labelHL1997,...
              'HandleVisibility','off');   
        hold on;

        

    end
    
end