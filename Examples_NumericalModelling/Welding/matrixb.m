%Matrix B
B = zeros (Nx*Ny,1);      %Create array of column zeros

for i=1:Nx
    for j=1:Ny
        
        k=(j-1)*Nx+i;      %Counter to generate position in matrix
        
        %Type 1 cell
        
        if i==1 && j==1
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)))+((-1/(dy*dy))*((2*hinf*dy*Tinf)/(hinf*dy+2*kc)));
        
        %Type 2 cell
        
        elseif j==1 && i>1 && i<Nx
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dy*dy))*((2*hinf*dy*Tinf)/(hinf*dy+2*kc)));
        
        %Type 3 cell
        
        elseif j==1 && i==Nx
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)))+((-1/(dy*dy))*((2*hinf*dy*Tinf)/(hinf*dy+2*kc)));
        
        %Type 4 cell
        
        elseif i==1 && j>1 && j<Ny
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)));
        
        %Type 5 cell
        
        elseif i>1 && i<Nx && j>1 && j<Ny
            B(k)=(-T(k,1)/(alpha*dt));
        
        %Type 6 cell
        
        elseif i==Nx && j>1 && j<Ny
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)));
        
        %Type 7 cell
        
        elseif i==1 && j==Ny
            if q(1,i)>0                      %Torch heat
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)))+((1/(dy*dy))*((qduaslinhas*dy)/kc));
            else                           %Ambient heat
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)))+((-1/(dy*dy))*((2*hinf*dy*Tinf)/(hinf*dy+2*kc)));  
            end
        
        %Type 8 cell
        
        elseif j==Ny && i>1 && i<Nx
            if q(1,i)>0                    %Torch heat
            B(k)=(-T(k,1)/(alpha*dt))+((1/(dy*dy))*((qduaslinhas*dy)/kc));      
            else                           %Ambient heat
            B(k)=(-T(k,1)/(alpha*dt))+((-1/(dy*dy))*((2*hinf*dy*Tinf)/(hinf*dy+2*kc)));      
            end
        
        %Type 9 cell
        
        elseif i==Nx && j==Ny
            if q(1,i)>0                   %Torch heat
                B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)))+((1/(dy*dy))*((qduaslinhas*dy)/kc));
            else                          %Ambient heat
                B(k)=(-T(k,1)/(alpha*dt))+((-1/(dx*dx))*((2*hinf*dx*Tinf)/(hinf*dx+2*kc)))+((-1/(dy*dy))*((2*hinf*dy*Tinf)/(hinf*dy+2*kc)));
            end
        end
    end
end