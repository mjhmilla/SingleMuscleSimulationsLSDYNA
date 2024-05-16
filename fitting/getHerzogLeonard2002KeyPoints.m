function keyPointsHL2002 = getHerzogLeonard2002KeyPoints(matlabScriptPath,...
                    refExperimentFolder,scaleFpe,flag_plotAnnotationData)

filePath = fullfile(matlabScriptPath,refExperimentFolder,...
                    'eccentric_HerzogLeonard2002',...
                    'digitizedKeyPointsHerzogLeonard2002.csv');

pointsHL2002 = readmatrix(filePath,'NumHeaderLines',1);
kPCol.vel   =1;
kPCol.lenA  =2;
kPCol.lenB  =3;
kPCol.t0    =4;
kPCol.f0    =5;
kPCol.t1    =6;
kPCol.f1    =7;
kPCol.t2    =8;
kPCol.f2    =9;
kPCol.t3    =10;
kPCol.f3    =11;
kPCol.t4    =12;
kPCol.f4    =13;
kPCol.t5    =14;
kPCol.f5    =15;


filePath7A = fullfile(matlabScriptPath,refExperimentFolder,...
                    'eccentric_HerzogLeonard2002',...
                    'dataHerzogLeonard2002Figure7A.dat');
dataFig7A = readmatrix(filePath7A,'NumHeaderLines',1);

filePath7B = fullfile(matlabScriptPath,refExperimentFolder,...
                    'eccentric_HerzogLeonard2002',...
                    'dataHerzogLeonard2002Figure7B.dat');
dataFig7B = readmatrix(filePath7B,'NumHeaderLines',1);

filePath7C = fullfile(matlabScriptPath,refExperimentFolder,...
                    'eccentric_HerzogLeonard2002',...
                    'dataHerzogLeonard2002Figure7C.dat');
dataFig7C = readmatrix(filePath7C,'NumHeaderLines',1);

%dataFig7A,dataFig7B,dataFig7C all have the same format
% Column
% 1 time
% 2 iso 0mm - length
% 3 iso 0mm - force
% 4 iso 9mm - length 
% 5 iso 9mm - force 
% 6 6-9mm ramp - length
% 7 6-9mm ramp - force
% 8 3-9mm ramp - length
% 9 3-9mm ramp - force
%10 0-9mm ramp - length
%11 0-9mm ramp - force
%12 0-9mm ramp - length
%13 0-9mm ramp - force



%Passive force length
keyPointsHL2002.fpe.l = [];
keyPointsHL2002.fpe.f = [];

%Active force length with passive component removed
keyPointsHL2002.fl.l = [];
keyPointsHL2002.fl.fpe = [];
keyPointsHL2002.fl.fmt= [];

if(flag_plotAnnotationData==1)
    figHL2002 = figure;
end

for i=1:1:3
    switch i
        case 1
            %3mm/s
            dataHL2002=dataFig7A;
            speedText='3mm/s';
        case 2
            %9mm/s                
            dataHL2002=dataFig7B; 
            speedText='9mm/s';                
        case 3
            %27mm/s
            dataHL2002=dataFig7C;                
            speedText='27mm/s';
            
    end
            
    for j=1:1:6
    
        colTime=1;
        switch j
            case 1
                colF = 6;
                colL = 7;
                lengthText='6-9mm';
                rowKp = 6+i;
            case 2
                colF = 8;
                colL = 9;                    
                lengthText='3-9mm';          
                rowKp = 3+i;
            case 3
                colF = 10;
                colL = 11; 
                if(i==1)
                    colF = 12;
                    colL = 13;                         
                end
                lengthText='0-9mm';  
                rowKp = i;
            case 4
                colF = [2];
                colL = [3];
                lengthText='iso 0mm';
                rowKp = 9+i;
            case 5
                colF = [4];
                colL = [5];                    
                lengthText='iso 9mm';  
                rowKp = 12+i;
            case 6
                colF = 12;
                colL = 13;                    
                if(i==1)
                    colF = 10;
                    colL = 11;
                end
                lengthText='0-9mm (passive)';
                rowKp = 15+i;
        end
        assert(length(colF)==1);

        if(isnan(rowKp)==0)
            l0 = interp1(dataHL2002(:,colTime),...
                         dataHL2002(:,colL(1,1)),...
                         pointsHL2002(rowKp,kPCol.t0));
            f0 = pointsHL2002(rowKp,kPCol.f0); 
            keyPointsHL2002.fpe.l = [keyPointsHL2002.fpe.l; l0];
            keyPointsHL2002.fpe.f = [keyPointsHL2002.fpe.f; f0];
            if(j <= 5)

                l1 = interp1(dataHL2002(:,colTime),...
                             dataHL2002(:,colL(1,1)),...
                             pointsHL2002(rowKp,kPCol.t1));
                f1 = pointsHL2002(rowKp,kPCol.f1);
                keyPointsHL2002.fl.fmt = [keyPointsHL2002.fl.fmt; f1];

                keyPointsHL2002.fl.l = [keyPointsHL2002.fl.l; l1];
                keyPointsHL2002.fl.fpe= [keyPointsHL2002.fl.fpe; f0]; 
            end
        end

        
        colorRedA  = [1,0,0];
        colorRedB  = [1,0.75,0.75];
        colorBlueA = [0,0,1];
        colorBlueB = [0.75,0.75,1];
        
        if(isnan(colF)==0)
            for k=1:1:length(colF)
                n=1;
                if(length(colF)>1)
                    n = (k-1)/(length(colF)-1);
                end                
                lineColorRed = colorRedA.*n + colorRedB.*(1-n);
                lineColorBlue = colorBlueA.*n + colorBlueB.*(1-n);

                if(flag_plotAnnotationData==1)
                    subplot(3,6,(i-1)*6+j);
                    figure(figHL2002);
                    yyaxis left;
                        plot(dataHL2002(:,colTime),...
                             dataHL2002(:,colF(k,1)), ...
                            '-','Color',[1,0.5,0.5]);
                        hold on;

                        if(isnan(rowKp)==0)
                            plot(pointsHL2002(rowKp,kPCol.t0),...
                                 pointsHL2002(rowKp,kPCol.f0),...
                                 'ok');
                            hold on;
                            plot(pointsHL2002(rowKp,kPCol.t1),...
                                 pointsHL2002(rowKp,kPCol.f1),...
                                 'ok');
                            hold on;
                            if(j <= 3)
                                plot(pointsHL2002(rowKp,kPCol.t3),...
                                     pointsHL2002(rowKp,kPCol.f3),...
                                     'ok');
                                     hold on;
                                plot(pointsHL2002(rowKp,kPCol.t4),...
                                     pointsHL2002(rowKp,kPCol.f4),...
                                     'ok');
                                     hold on;
                                plot(pointsHL2002(rowKp,kPCol.t5),...
                                     pointsHL2002(rowKp,kPCol.f5),...
                                     'ok');
                                hold on;
                            end
                            if(j == 6)
                                plot(pointsHL2002(rowKp,kPCol.t2),...
                                     pointsHL2002(rowKp,kPCol.f2),...
                                     'ok');
                                     hold on;

                            end
                        end
                        

                        xlabel('Time (s)');
                        ylabel('Force (N)');
                        box off;
                        title([speedText,' ',lengthText]);

                        yLimits = ylim;
                        ylim([0,yLimits(1,2)]);
                    yyaxis right;
                        plot(dataHL2002(:,colTime),...
                             dataHL2002(:,colL(k,1)), ...
                            '-','Color',[0.5,0.5,1]);
                        hold on;

                        if(isnan(rowKp)==0)
                            l0 = interp1(dataHL2002(:,colTime),...
                                    dataHL2002(:,colL(k,1)),...
                                    pointsHL2002(rowKp,kPCol.t0));
                            l1 = interp1(dataHL2002(:,colTime),...
                                    dataHL2002(:,colL(k,1)),...
                                    pointsHL2002(rowKp,kPCol.t1));

                            plot(pointsHL2002(rowKp,kPCol.t0),...
                                 l0,...
                                 'xk');
                            hold on;
                            plot(pointsHL2002(rowKp,kPCol.t1),...
                                 l1,...
                                 'xk');
                            hold on;
                        end
                        ylabel('Length (mm)');
                        ylim([0,27]);
                        yLimits = ylim;
                        ylim([0,yLimits(1,2)]);
                        
                    box off;   
                end
            end
        end
    end
end

%Scaling to bring the units to Newton, meter, second
keyPointsHL2002.nms.l = 0.001;
keyPointsHL2002.nms.f = 1;

[lengthOrdered, indexOrdered] = sort(keyPointsHL2002.fpe.l);

keyPointsHL2002.fpe.l = keyPointsHL2002.fpe.l(indexOrdered);
keyPointsHL2002.fpe.f = keyPointsHL2002.fpe.f(indexOrdered).*scaleFpe;
keyPointsHL2002.fpe.clusters=4;

%Active force length

%Active force length 
[lengthOrdered, indexOrdered] = sort(keyPointsHL2002.fl.l);

keyPointsHL2002.fl.l = keyPointsHL2002.fl.l(indexOrdered);
keyPointsHL2002.fl.fpe= keyPointsHL2002.fl.fpe(indexOrdered);
keyPointsHL2002.fl.fmt= keyPointsHL2002.fl.fmt(indexOrdered);
keyPointsHL2002.fl.clusters=4;

if(flag_plotAnnotationData==1)
    figDebug=figure;
    subplot(1,2,1);
        plot(keyPointsHL2002.fpe.l,keyPointsHL2002.fpe.f,'ok');
        hold on;
        xlabel('Length (mm)');
        ylabel('Force (N)');
        box off;
        title('Passive force-length relation')
    subplot(1,2,2);
        plot(keyPointsHL2002.fl.l,keyPointsHL2002.fl.fpe,'xk');
        hold on;
        plot(keyPointsHL2002.fl.l,keyPointsHL2002.fl.fmt,'or');
        hold on;
        xlabel('Length (mm)');
        ylabel('Force (N)');
        box off;
        title('Active force-length relation');
    here=1;
end

here=1;

