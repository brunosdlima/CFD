%Calculation of u, v e p

function [u, v, p]=Step3(ka,p,u,v,Nx,Ny,dy,dx,p_est,u_est,v_est,dt,rho)

for i=2:(Ny-1)
    for j=3:(Nx-1)
        
        k=(i-1)*Nx+j;
        
if   k~=ka
        dp_estdx=(p_est(k,1)-p_est(k-1,1))/dx;
        u(k,1) = u_est(k,1) - (dt/rho)*(dp_estdx);
else           
       u(k,1)=0;
       v(k,1)=0;
end
 
  end

end
    


for i=2:(Ny-1)
    for j=2:(Nx-1)
        
        k=(i-1)*Nx+j;
        
if   k~=ka 
        dp_estdy=(p_est(k,1)-p_est(k-Nx,1))/dy;
        if i==2 && j>=2 && j<=(Nx-1)
            dp_estdy=(2*p_est(k,1))/dy;
        end
        v(k,1) = v_est(k,1) - (dt/rho)*(dp_estdy);
        p(k,1) = p(k,1) + p_est(k,1);
else    
       u(k,1)=0;
       v(k,1)=0;
end

    end
    
end

end

