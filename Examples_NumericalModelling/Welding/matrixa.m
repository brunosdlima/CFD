%matrix A

for i=1:Nx                 %Create the pentagonal matrix
    for j=1:Ny
        
        k=(j-1)*Nx+i;      %Counter to generate position in matrix
        
        %Type 1 cell
        
        if i==1 && j==1
            A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)))+((1/(dy*dy))*((2*kc-hinf*dy)/(hinf*dy+2*kc)));
            A(k,k+1)=(1/(dx*dx));
            A(k,k+Nx)=(1/(dy*dy));
        
        %Type 2 cell
        
        elseif j==1 && i>1 && i<Nx
            A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dy*dy))*((2*kc-hinf*dy)/(hinf*dy+2*kc)));
            A(k,k+1)=(1/(dx*dx));
            A(k,k-1)=(1/(dx*dx));
            A(k,k+Nx)=(1/(dy*dy));
        
        %Type 3 cell
        
        elseif j==1 && i==Nx
            A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)))+((1/(dy*dy))*((2*kc-hinf*dy)/(hinf*dy+2*kc)));
            A(k,k-1)=(1/(dx*dx));
            A(k,k+Nx)=(1/(dy*dy));
        
        %Type 4 cell
        
        elseif i==1 && j>1 && j<Ny
            A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)));
            A(k,k+1)=(1/(dx*dx));
            A(k,k+Nx)=(1/(dy*dy));
            A(k,k-Nx)=(1/(dy*dy));
        
        %Type 5 cell
        
        elseif i>1 && i<Nx && j>1 && j<Ny
            A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt));
            A(k,k+1)=(1/(dx*dx));
            A(k,k-1)=(1/(dx*dx));
            A(k,k+Nx)=(1/(dy*dy));
            A(k,k-Nx)=(1/(dy*dy));
        
        %Type 6 cell
        
        elseif i==Nx && j>1 && j<Ny
            A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)));
            A(k,k-1)=(1/(dx*dx));
            A(k,k+Nx)=(1/(dy*dy));
            A(k,k-Nx)=(1/(dy*dy));
        
        %Type 7 cell
        
        elseif i==1 && j==Ny
            A(k,k+1)=(1/(dx*dx));
            A(k,k-Nx)=(1/(dy*dy)); 
            if  q(1,i)>0                %Torch heat
                A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)))+(1/(dy*dy));     
            else                        %ambient heat
                A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)))+((1/(dy*dy))*((2*kc-hinf*dy)/(hinf*dy+2*kc)));     
            end  
        
        %Type 8 cell
        
        elseif j==Ny && i>1 && i<Nx
            A(k,k+1)=(1/(dx*dx));
            A(k,k-1)=(1/(dx*dx));
            A(k,k-Nx)=(1/(dy*dy)); 
                if  q(1,i)>0            %Torch heat
                    A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+(1/(dy*dy));         
                else                     %Ambient heat
                    A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dy*dy))*((2*kc-hinf*dy)/(hinf*dy+2*kc)));    
                end
     
        %Type 9 cell
        
        elseif i==Nx && j==Ny
            A(k,k-1)=(1/(dx*dx));
            A(k,k-Nx)=(1/(dy*dy)); 
            if  q(1,i)>0                %Torch heat
                A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)))+(1/(dy*dy));        
            else                        %Ambient heat
                A(k,k)=(-2/(dx*dx))+(-2/(dy*dy))+(-1/(alpha*dt))+((1/(dx*dx))*((2*kc-hinf*dx)/(hinf*dx+2*kc)))+((1/(dy*dy))*((2*kc-hinf*dy)/(hinf*dy+2*kc)));   
            end
        end
          
    end
end