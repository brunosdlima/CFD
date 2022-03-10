%-------- TRABALHO DA DISCIPLINA "Metodos Computacionais" - UFU

%-------- Fluidodinâmica  
%-------- Alunos: Beatriz Granado, Bruno Lima, Deborah Domingos, Fábio Radicchi, José Aguiar
%-------- Professor: Solidonio Carvalho

%Equações para u_est
function [u_est, v_est]  = Passo1_1(ka,u_est,v_est,p,dx,u,v,dy,dt,rho,visc,Nx,Ny)

u_est=u;
v_est=v;
        

for i=2:(Ny-1)
    for j=3:(Nx-1)
    
        k=(i-1)*Nx+j;
 
        if i==2 && j>=3 && j<=(Nx-1)   %CC lateral inferior
            u(k-Nx,1)=u(k,1);
        end
        if i==(Ny-1) && j>=3 && j<=(Nx-1)   %CC lateral superior
            u(k+Nx,1)=u(k,1);
            v(k+Nx,1)=v(k,1);
            v(k+Nx-1,1)=v(k-1,1);
        end
        if j==(Nx-1) && i>=2 && i<=(Ny-1)   %CC de saída
            u(k+1,1)=u(k,1);
        end
        

if  k~=ka
   
         
        
dpdx=(p(k,1)-p(k-1,1))/dx;

duudx=((u(k+1,1)^2)-(u(k-1,1)^2))/(2*dx);

vn=(v(k+Nx,1)+v(k+Nx-1,1))/2;
vs=(v(k,1)+v(k-1,1))/2;
dvudy=((u(k+Nx,1)*vn)-(u(k-Nx,1)*vs))/(2*dy);%alterei

d2udx2=(u(k+1,1)-2*u(k,1)+u(k-1,1))/(dx^2);

d2udy2=(u(k+Nx,1)-2*u(k,1)+u(k-Nx,1))/(dy^2);


u_est(k,1)=u(k,1) + dt * (((-1/rho)*(dpdx))-(duudx+dvudy)...
    +(visc*(d2udx2+d2udy2)));

 
else 
   u_est(k,1)=0;   
end

    end
end



for i=2:(Ny-1)
    for j=2:(Nx-1)
    
        k=(i-1)*Nx+j;
        
        if i==2 && j>=2 && j<=(Nx-1)   %CC lateral inferior
            v(k-Nx,1)=v(k+Nx,1);
            u(k-1,1)=u(k,1);
            u(k-Nx,1)=u(k+1,1);
        end
        if  j==2 && i>=2 && i<=(Ny-1)   %CC de entrada de fluido
            v(k-1,1)=-v(k,1);
        end
        if  j==(Nx-1) && i>=2 && i<=(Ny-1)   %CC de saída de fluido     
            v(k+1,1)=v(k-1,1);
        end       
        if i==(Ny-1) && j>=2 && j<=(Nx-1)   %CC lateral superior
            v(k+Nx,1)=v(k,1);
        end

if   k~=ka


%Equações para v_est

dpdy=(p(k,1)-p(k-Nx,1))/dy;

ue=(u(k+1,1)+u(k-Nx+1,1))/2;
uw=(u(k,1)+u(k-1,1))/2;
duvdx=((v(k+1,1)*ue)-(v(k-1,1)*uw))/(2*dx);%alterei

dvvdy=((v(k+Nx,1)^2)-(v(k-Nx,1)^2))/(2*dy);

d2vdx2=(v(k+1,1)-2*v(k,1)+v(k-1,1))/(dx^2);

d2vdy2=(v(k+Nx,1)-2*v(k,1)+v(k-Nx,1))/(dy^2);

v_est(k,1)=v(k,1) + dt * (((-1/rho)*(dpdy))-(duvdx+dvvdy)...
    +(visc*(d2vdx2+d2vdy2)));

     
else
  v_est(k,1)=0;      
end

    end
end

end






