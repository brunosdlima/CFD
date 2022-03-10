%Vorticidade
function [w]=Passo5(u,v,dy,dx,Nx,Ny)

w=sparse(zeros(Nx*Ny,1));
for i=2:(Ny-2)
    for j=2:(Nx-2)
        
        k=(i-1)*Nx+j;
        
        dvdx= ((v(k+Nx+1,1)+v(k+1,1)-v(k+Nx-1,1)-v(k-1,1))/4)/dx;
        dudy= ((u(k+Nx,1)+u(k+Nx+1,1)-u(k-Nx-1,1)-u(k-Nx+1,1))/4)/dy;
        w(k,1)=dvdx-dudy;

    end
end
end