%-------- TRABALHO DA DISCIPLINA "Metodos Computacionais" - UFU

%-------- Fluidodin�mica  
%-------- Alunos: Beatriz Granado, Bruno Lima, Deborah Domingos, F�bio Radicchi, Jos� Aguiar
%-------- Professor: Solidonio Carvalho

%Verifica a conserva��o de massa


function [conserva]=Passo4(kb,u,v,dy,dx,erro,Nx,Ny)

for i=2:(Ny-1)
    for j=2:(Nx-1)
       
        
        
        k=(i-1)*Nx+j;
        
        if k~=kb

if abs(((u(k+1,1)-u(k,1))/dx) + (v(k+Nx,1)-v(k,1))/dy)< erro
    conserva=0;
else
   conserva=1;
   helpdlg('Crit�rio de conserva��o de massa n�o foi atendido');
   
end
        else
        end
    end
    
end
end




    


