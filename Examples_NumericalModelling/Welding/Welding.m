clc
clear all
close all

%Problem data entry
tic
%304 steel sheet data
e=0.007;                           %Plate thickness [m]
L=0.2;                             %Plate width [m]
kc=15;                             %Thermal conductivity [W/m K]
rho=7900;                          %Steel density [kg/m3]
cp=500;                            %Specific heat[J/kg K]
alpha=kc/(rho*cp);                 %Thermal diffusivity[m2/s]
save_int=0;

%Experimental parameters
V=20;                              %Tensão elétrica [V]
I=160;                             %Electric current [A]
P=V*I;                             %Arc electrical power [W]
d=0.01;                            %Nozzle diameter [m]
ni=0.6;                            %Heat transfer efficiency
qduaslinhas=-P*ni/(pi*d*d/4);      %Heat input[W/m2]
dq = 0;                            %Flow start coordinate [m]
Tinf=30;                           %Room temperature [C]
hinf=25;                           %Convection coefficient [W/m²K]

%Data of mesh MalhaM*10^7
Nx=150;                             %Number of nodes in the x direction
Ny=150;                             %Number of nodes in the y direction
dx=L/Nx;                            %Mesh dimension in the x direction [m]
dy=e/Ny;                            %Mesh dimension in the y direction [m]
dt=1;                               %Time step [s]
t0=20;                              %Total welding process time [s]
v = L/t0;                           %Torch speed [m/s]
tf=t0+30;
npt=round(tf/dt);                   %Number of time steps

%Initialize matrices for solution
A = sparse (zeros (Nx*Ny,Nx*Ny));           %Create array of zeros
B = sparse (zeros (Nx*Ny,1));               %Create array of column zeros

try
    load('TT.mat');%Loads the file containing the temperature already calculated
    load('ti.mat');%Load the time the simulation stopped
    T(:,1)=TT(:,ti+1);
catch
    T = ones (Nx*Ny,1)*Tinf;       % if time and temperature variables were not saved, they are now created
    ti=1;
    Tc = ones (npt,6)*Tinf; 
end


%Processamento


for ta=0:dt:tf                  %Time step number

    q = zeros (1,Nx);
    ti=ti+1;                       %Passo de tempo atual
    if ta<=t0

    do=round(((dq+v*ta-d/2))/dx);   %Minimum torch position [m]
    df=round(((dq+v*ta+d/2))/dx);   %Maximum torch position [m]
    if do<=0
        do=1;
    end
    if do>Nx
        do=Nx;
    end
    if df>Nx
        df=Nx;
    end
    if df<=0
        df=1;
    end

    for j=1:Nx 
        if j>=do && j<=df 
            q(1,j)=1;
        else
            q(1,j)=0;
        end
    end
    end
    %Creation of matrices
    matrixa                        %Create the pentagonal matrix A
    matrixb                        %Create column B array

   T(:,1) = A\B;                   %Temperature solution matrix

x = linspace (0,L,Nx);
y = linspace (0,e,Ny);
[X,Y] = meshgrid(x,y);
Z(Nx,Ny)=zeros;
j=1;
k=0;
for i=1:Nx*Ny
    k=k+1;
        Z (k,j)= T(i,1);
        if k==Nx
           k=0;
           j=j+1;  
        end
end

T4(ta+1,4)=T(Nx*Ny-Nx+1,1);
Tc(ti,4) = awgn(T(Nx*Ny-Nx+1,1),70,'measured');%Adds Gaussian white noise
T5(ta+1,5)=T(round(Nx*Ny-Nx/2),1);
Tc(ti,5) = awgn(T(round(Nx*Ny-Nx/2),1),70,'measured');%Adds Gaussian white noise
T6(ta+1,6)=T(Nx*Ny,1);
Tc(ti,6) = awgn(T(Nx*Ny,1),70,'measured');%adds Gaussian white noise

T1(ta+1,1)=T(1,1);
Tc(ti,1) = awgn(T(1,1),70,'measured');%adds Gaussian white noise 
T2(ta+1,2)=T(round(Nx/2),1);
Tc(ti,2) = awgn(T(round(Nx/2),1),70,'measured');%adds Gaussian white noise
T3(ta+1,3)=T(Nx,1);
Tc(ti,3) = awgn(T(Nx,1),70,'measured');%adds Gaussian white noise

figure(2)
plot(ta,T(round(Nx*Ny-Nx/2),1),'-ob',ta,T(Nx*Ny-Nx+1,1),'-*r',ta,T(Nx*Ny,1),'-og');
xlabel('Times [s]')
ylabel('Thickness [Celsius]')
title('Mesh convergence for cooling')
hold on

figure(3)
plot(ta,T(round(Nx/2),1),'-ob',ta,T(1,1),'-*r',ta,T(Nx,1),'-og');
xlabel('Time [s]')
ylabel('Temperature [Celsius]')
title('Mesh convergence for heating')
hold on

end

toc
save ('Temperatura.txt','Tc','-ascii');

%Post processing
x = linspace (0,L,Nx);
y = linspace (0,e,Ny);
[X,Y] = meshgrid(x,y);
Z(Nx,Ny)=zeros;
j=1;
k=0;
for i=1:Nx*Ny
    k=k+1;
        Z (k,j)= T(i,1);
        if k==Nx
           k=0;
           j=j+1;  
        end
end
figure(1)
contourf(X, Y, Z.')
colormap(jet)
grid on 
axis equal
xlabel('Length [m]')
ylabel('Thickness [m]')
title('Distribution of temperatures on the plate')
