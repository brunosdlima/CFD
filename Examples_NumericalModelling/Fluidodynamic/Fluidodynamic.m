
clc; clear all; close all;       %Clears the command window, the variables and closes the figures

%Input data
rho=1;                              %Fluid density
Re=100;                             %Reynolds number
L=40;                               %Domain width
h=15;                               %Domain height
D=h/10;
u0=1;
visc=u0*D/Re;                       %Fluid viscosity                 
erro= 0.1;                          %Mass conservation criterion

%Mesh data and time step
Nx=80;                              %Number of nodes in the x direction
Ny=40;                              %Number of nodes in the y direction
dx=L/Nx;                            %Mesh dimension in the x direction [m]
dy=h/Ny;                            %Mesh dimension in the y direction [m]
dt=0.0001;                          %Time step [s]
t=20;                               %Total process time[s]
npt=round(t/dt);                    %Number of time steps

%Initial data
u=sparse(ones(Nx*Ny,1));            %Initial speeds in the x direction
v=sparse(zeros(Nx*Ny,1));           %Initial speeds in the y direction
p=sparse(zeros(Nx*Ny,1));           %Initial pressures
A=sparse(zeros(Nx*Ny,Nx*Ny));       %Matrix for pressure solution        
B=sparse(zeros(Nx*Ny,1));           %Vector for pressure solution

%Geometric barrier
Nby1=round(((h/2)-(D/2))/dy);
Nby2=round(((h/2)+(D/2))/dy);
Nbx1=round((0.3*L)/dx);
Nbx2=round((0.3*L+D)/dx);

z=0;
for i=Nby1:Nby2
    for j=Nbx1:Nbx2
        z=z+1;
        ka(z,1)=(i-1)*Nx+j;   
    end     
end  

%Locked cells for mass conservation
zz=0;
for i=Nby1-1:Nby2+1
    for j=Nbx1-1:Nbx2+1
        zz=zz+1;
        kb(zz,1)=(i-1)*Nx+j;
    end     
end 



u(ka,1)=0;
v(ka,1)=0;

u_est=u;
v_est=v;
p_est=p;


for ti=1:npt
tic
%Step 1
[u_est, v_est]=Step1(ka,u_est,v_est,p,dx,u,v,dy,dt,rho,visc,Nx,Ny);
%Step 2
[p_est]=Step2(p_est,u_est,v_est,p,dx,u,v,dy,dt,rho,visc,Nx,Ny);
%Step 3
[u, v, p]=Step3(ka,p,u,v,Nx,Ny,dy,dx,p_est,u_est,v_est,dt,rho);
%Step 4
[conserva]=Step4(kb,u,v,dy,dx,erro, Nx, Ny);
%Step 5
[w]=Step5(u,v,dy,dx,Nx,Ny);

x = linspace (0,L,Nx-2);
y = linspace (0,h,Ny-2);
[X,Y] = meshgrid(x,y);

k=1;
for i=2:(Ny-1)
    jj=1;
    for j=2:(Nx-1)     
        kk=(i-1)*Nx+j;   
        Z1 (k,jj)= u(kk,1);
        jj=jj+1;
    end
    k=k+1;
end


j=1;
k=0;
for i=1:(Nx)*(Ny)
    k=k+1;
        Z2 (k,j)= v(i,1);
        if k==Nx
           k=0;
           j=j+1;  
        end
end
j=1;
k=0;
for i=1:(Nx)*(Ny)
    k=k+1;
        Z3 (k,j)= p(i,1);
        if k==Nx
           k=0;
           j=j+1;  
        end
end

k=1;
for i=2:(Ny-1)
    jj=1;
    for j=2:(Nx-1)
        kk=(i-1)*Nx+j;   
        Z4 (k,jj)= w(kk,1);
        jj=jj+1;
    end
    k=k+1;
end
j=1;
k=0;
for i=1:(Nx)*(Ny)
    k=k+1;
        Z5 (k,j)= u(i,1);
        if k==Nx
           k=0;
           j=j+1;  
        end
end

figure(1)
contourf(X, Y, Z1)
colorbar
colormap(jet)
grid on 
axis equal
xlabel('x [m]')
ylabel('y [m]')
title('Velocity field u')

figure(4)
contourf(X, Y, Z4)
colormap(jet)
colorbar
grid on 
axis equal
xlabel('x [m]')
ylabel('y [m]')
title('Vorticity w')

x = linspace (0,L,Nx);
y = linspace (0,h,Ny);
[X,Y] = meshgrid(x,y);

figure(2)
contourf(X, Y, Z2.')
colormap(jet)
colorbar
grid on 
axis equal
xlabel('x [m]')
ylabel('y [m]')
title('Velocity field v')

figure(3)
contourf(X, Y, Z3.')
colormap(jet)
colorbar
grid on 
axis equal
xlabel('x [m]')
ylabel('y [m]')
title('Pressure field P')

%Stream lines

figure(5)
Z5c=Z5';Z2c=Z2';
%Create the vectors referring to the speeds
quiver(X, Y, Z5c, Z2c,'b-','LineWidth',0.2,'AutoScaleFactor',1);
grid
hold on 
%Defines the points where the 'streamlines' will start
startx = zeros(1,12);
starty = linspace(0,h,12);
%Plot the 'streamlines' on the open graph
hs1 = streamline(X,Y,Z5c,Z2c,startx,starty);
%Get access to the chart to change visual properties
hline = findobj(gcf, 'type', 'line');
set(hs1,'Linewidth',2,'color','r'); %Changes the thickness/color of the 'streamlines'
%Name the axes and title
xlabel('x')
ylabel('y')
title('Velocity vectors and streamlines','fontweight','bold')
toc

pause (0.01)
end


