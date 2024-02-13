function errH = calcHillError(params,argScale,data,fiso)


params = params.*argScale;
fvAtHalfVmax = params(1,1)*fiso;
vMaxC        = params(1,2);

w = 0.5*vMaxC;
a = -fvAtHalfVmax*w*fiso ...
    / (vMaxC*fvAtHalfVmax - fiso*vMaxC + fiso*w);
b =  a*vMaxC/fiso;

errH = zeros(size(data,1),1);
for i=1:1:size(data,1)
    w = data(i,1);
    fv = (fiso*b-a.*w)./(b+w);
    errH(i,1)=data(i,2)-fv;
end
here=1;
flag_debug=0;
if(flag_debug==1)
    figDebug=figure;
    w= [0:0.01:1].*vMaxC;
    fv = (fiso*b-a.*w)./(b+w);

    plot(data(:,1),data(:,2),'xb');
    hold on;
    plot(w,fv,'-r');
    hold on;
    xlabel('Velocity');
    ylabel('Force');
end