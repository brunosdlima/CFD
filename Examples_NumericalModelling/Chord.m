%This routine calculates the lambda coefficient that makes the string oscillate with less than 0.001 
%(measured at the points corresponding to x=0.2 and x=0.75) around zero for a time of ten seconds.
%The solved equation is for a double-pinned string

clear all; close all; clc; %Limpa as variaveis e a tela

%Dados de entrada
L=1;                       %Rope length
T=1;                       %Tension in the rope
rho=0.5;                   %Rope density
tmax=10;                   %Damping time
dt=0.01;                   %Time step
Nx=100;                    %Number of cells
dx=L/Nx;                   %Cell dimension
Nt=(tmax/dt)+1;            %Number of time steps
alpha=T/rho;               %Tension over density
i=1;                       %Time counter
j=2;                       %Cell counter
t=1;                       %Time counter
temp=linspace (t,tmax,Nt); %Total simulation time
ermax=0.001;               %Biggest difference to consider the rope stopped
er=10;                     %Initial guess for error
lambda=0.1;                %Initial guess for the damping coefficient

%Boundary conditions
% y(1,1)=0;
% y(1,Nx+1)=0;

%Initial conditions
x1=[0 0.2];
x2=[0.2 0.75];
x3=[0.75 1];
y1=[0 0.15];
y2=[0.15 0.2];
y3=[0.2 0];
a1=polyfit(x1,y1,1);
a2=polyfit(x2,y2,1);
a3=polyfit(x3,y3,1);

while abs(er)>ermax
    %Initial condition of the rope
    for j=1:(Nx+1)
        if (j-1)*dx<0.2
            y(1,j)=(j-1)*dx*a1(1)+a1(2);
            j1=j;
        elseif (j-1)*dx<0.75
            y(1,j)=(j-1)*dx*a2(1)+a2(2);
            j2=j;
        else
            y(1,j)=(j-1)*dx*a3(1)+a3(2);
        end
    end
    y(2,:)=y(1,:);
    j=1;

    %Equation coefficients
    c1=((2*alpha/(dt*dt))-2/(dx*dx));
    c2=((lambda/dt)-(alpha/(dt*dt)));
    c3=(1/(dx*dx));
    d1=((alpha/(dt*dt))+(lambda/dt));

    %Time advance calculation
    for t=3:Nt
        for j=2:(Nx-1)                                             
            y(3,j)=(c1*y(2,j)+c2*y(1,j)+c3*(y(2,j+1)+y(2,j-1)))/d1;
        end
        y1(t)=y(3,j1);
        y2(t)=y(3,j2);
        y(1,:)=y(2,:);
        y(2,:)=y(3,:);   
    end
    
    %Maximum error test
    if abs(y2(Nt))>abs(y1(Nt))
        er=y2(Nt);
    else
        er=y1(Nt);
    end
    if abs(er)>ermax
        lambda=lambda*1.618;
    else
        mensagem=['The value of lambda ',num2str(lambda),' meets the condition'];
        disp(mensagem);
    end
end

figure(1)
plot(temp,y1)
grid on 
xlabel('Time [s]')
ylabel('Position [m]')
title('First point position')

figure(2)
plot(temp,y2)
grid on 
xlabel('Time [s]')
ylabel('Position [m]')
title('Second point position')