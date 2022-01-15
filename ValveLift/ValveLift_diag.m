clear all
close all
clc
%% Import file
[filename,pathname]=uigetfile({'*.xlsx';'*.xls';'*.txt'},'Select data file');
prompt = {'Angle Range:','Lift Range:','Admission Sheet name',...
    'Exhaustion Sheet name'};
numlines = [1 8;1 8;1 25;1 25];
defans = {'A3:A48','D3:D48','admissao','exaustao'};
options.Resize = 'on';
options.WindowStyle = 'normal';
answer = inputdlg(prompt,filename,numlines,defans,options);
range_ang = answer{1};
range_lift = answer{2};
sheet_int = answer{3};
sheet_exh = answer{4};
cd(pathname)
clear answer prompt numlines defans options
%% Read file
ang_int = xlsread(filename,sheet_int,range_ang);
lift_int = xlsread(filename,sheet_int,range_lift);

ang_exh = xlsread(filename,sheet_exh,range_ang);
lift_exh = xlsread(filename,sheet_exh,range_lift);
%% Data Ajust: 8th degree
% Intake
p_int = polyfit(ang_int,lift_int,8);
ang8_int = [0:0.1:90]';
lift8_int = sort(polyval(p_int,ang8_int));

% Exhaust
p_exh = polyfit(ang_exh,lift_exh,8);
ang8_exh = [0:0.1:90]';
lift8_exh = sort(polyval(p_exh,ang8_exh));
%% Radius input and calculation
% input maximum distance values
answer = inputdlg({'Intake max distance:','Exhaust max distance:'},...
    'Radius',[1 7;1 7],{'38.196','36.490'});
rmax_int = str2num(answer{1})/2;
rmax_exh = str2num(answer{2})/2;

% initializing variables
R_int = zeros(length(0:0.1:360),1);
R_exh = zeros(length(0:0.1:360),1);

% Fall: 0 to 90 degrees
for i=1:1:length(0:0.1:90)
    R_int(i,1) = rmax_int-lift8_int(i,1);
    R_exh(i,1) = rmax_exh-lift8_exh(i,1);
end
% Dwell: 90.1 to 270 degrees
for j=i+1:1:i+length(90.1:0.1:270)
    R_int(j,1) = R_int(i,1);
    R_exh(j,1) = R_exh(i,1);
end
% Rise: 270.1 to 360 degrees
for k = j+1:1:j+length(270.1:0.1:360)
    R_int(k,1) = R_int(i,1);
    R_exh(k,1) = R_exh(i,1);
    i = i-1;
end
%% XYZ coordinates
ang = [0:0.1:360]';
Z = zeros(length(ang),1);
X_int = zeros(length(ang),1);
Y_int = zeros(length(ang),1);
X_exh = zeros(length(ang),1);
Y_exh = zeros(length(ang),1);
% Fall: 0 to 90 degrees
for i=1:1:length(0:0.1:90)
    X_int(i,1) = R_int(i,1)*sin(ang(i,1)*pi/180);
    Y_int(i,1) = R_int(i,1)*cos(ang(i,1)*pi/180);
    
    X_exh(i,1) = R_exh(i,1)*sin(ang(i,1)*pi/180);
    Y_exh(i,1) = R_exh(i,1)*cos(ang(i,1)*pi/180);
end
% Dwell: 90.1 to 270 degrees
for j=i+1:1:i+length(90.1:0.1:269.9)
    X_int(j,1) = R_int(j,1)*sin(ang(j,1)*pi/180);
    Y_int(j,1) = R_int(j,1)*cos(ang(j,1)*pi/180);
    
    X_exh(j,1) = R_exh(j,1)*sin(ang(j,1)*pi/180);
    Y_exh(j,1) = R_exh(j,1)*cos(ang(j,1)*pi/180);
end
% Rise: 270.1 to 360 degrees
for k = j+1:1:j+length(270:0.1:360)
    X_int(k,1) = -X_int(i,1);
    Y_int(k,1) = Y_int(i,1);
    
    X_exh(k,1) = -X_exh(i,1);
    Y_exh(k,1) = Y_exh(i,1);
    i = i-1;
end
% for i=1:1:length(ang)
%     X_int(i,1) = R_int(i,1)*sin(ang(i,1)*pi/180);
%     Y_int(i,1) = R_int(i,1)*cos(ang(i,1)*pi/180);
%     
%     X_exh(i,1) = R_exh(i,1)*sin(ang(i,1)*pi/180);
%     Y_exh(i,1) = R_exh(i,1)*cos(ang(i,1)*pi/180);
% end

INTAKE = [X_int,Y_int,Z];
EXHAUST = [X_exh,Y_exh,Z];
%% Original data XY coordinates
% Intake
for i=1:1:length(ang_int)
    Xin_orig(i,1) = (rmax_int - lift_int(i,1))*sin(ang_int(i,1)*pi/180);
    Yin_orig(i,1) = (rmax_int - lift_int(i,1))*cos(ang_int(i,1)*pi/180);
end
% Exhaust
for i=1:1:length(ang_exh)
    Xex_orig(i,1) = (rmax_exh - lift_exh(i,1))*sin(ang_exh(i,1)*pi/180);
    Yex_orig(i,1) = (rmax_exh - lift_exh(i,1))*cos(ang_exh(i,1)*pi/180);
end
%% Derivative of ajust
for i=1:1:length(X_int)
    if i < length(X_int)
        dY_int(i,1) = (Y_int(i+1,1)-Y_int(i,1))/(X_int(i+1)-X_int(i));
        dY_exh(i,1) = (Y_exh(i+1,1)-Y_exh(i,1))/(X_exh(i+1)-X_exh(i));
    end
end
%% Plots
a = figure('Position',[100 100 800 800])
% Intake
subplot(2,2,1)
plot(X_int,Y_int,'k')
title('Intake')
xlim([-20,20]);
ylim([-20,20]);
grid
subplot(2,2,2)
plot(X_int(1:length(0:0.1:90),1),Y_int(1:length(0:0.1:90),1),'k',...
    Xin_orig,Yin_orig,'ok')
% Exhaust
subplot(2,2,3)
plot(X_exh,Y_exh,'k')
title('Exhaust')
xlim([-20,20]);
ylim([-20,20]);
grid
subplot(2,2,4)
plot(X_int(1:length(0:0.1:90),1),Y_int(1:length(0:0.1:90),1),'k',...
    Xin_orig,Yin_orig,'ok')

b = figure('Position',[100 100 800 800])
plot(X_int(1:end-1),dY_int);

%% Create .txt data files for SOLIDWORKS
dlmwrite('Intake_table.txt',INTAKE,'delimiter','\t','precision','%.6f',...
    'newline','pc');
dlmwrite('Exhaust_table.txt',EXHAUST,'delimiter','\t','precision','%.6f',...
    'newline','pc');