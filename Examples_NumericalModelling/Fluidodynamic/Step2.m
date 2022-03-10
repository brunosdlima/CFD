%Pressure correction - p_est calculation

function [p_est]=Step2(p_est,u_est,v_est,p,dx,u,v,dy,dt,rho,visc,Nx,Ny)

A=sparse(zeros(Nx*Ny,Nx*Ny));
B=sparse(zeros(Nx*Ny,1));
p_est=p;

for i=2:(Ny-2)
    for j=2:(Nx-2)
        
        k=(i-1)*Nx+j; %((Ny-1)*Nx + Ny)
        
        A(k,k)=(((-2/(dx^2))+(-2/(dy^2))));
        A(k,k+1)=1/(dx^2);
        A(k,k-1)=1/(dx^2);
        A(k,k+Nx)=1/(dy^2);
        A(k,k-Nx)=1/(dy^2);
        B(k,1)=((rho/dt)*((u_est(k+1,1)-u_est(k,1))/dx + (v_est(k+Nx,1)-v_est(k,1))/dy));
        
        %BC bottom side
        if i==2 && j>=2 && j<=(Nx-1)   
           A(k,k)=A(k,k)-1/(dy^2);
           A(k,k-Nx)=0;
        end
        
        %CC de entrada de fluido
        if  j==2 && i>=2 && i<=(Ny-1)   
           A(k,k)=A(k,k)+1/(dx^2);
           A(k,k-1)=0;
        end
        
        %CC de saída de fluido
        if  j==(Nx-2) && i>=2 && i<=(Ny-1) 
            A(k,k+1)=0;
        end 
        
        %CC lateral superior
        if i==(Ny-2) && j>=2 && j<=(Nx-1) 
            A(k,k+Nx)=0; 
        end

    end
end

p_est=A\B;
for i=2:(Ny-3)
    for j=2:(Nx-3)
        
        k=(i-1)*Nx+j;
        
        p_est(k,1)=p_est(k,1)-p_est(Nx+2,1);
    end
end
end