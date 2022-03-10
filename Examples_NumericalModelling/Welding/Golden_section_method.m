for qduaslinhas=-1e7:-0.3e7:-3e7    
    clc
    Texp=load ('Temperatura.txt');

    %for qduaslinhas=-1e7:-0.3e7:-4e7

    %Entrada dos dados do problema
    tic
    %Dados da chapa de aco 304
    e=0.007;                          %Espessura da chapa [m]
    L=0.2;                             %Largura da chapa [m]
    kc=15;                             %Condutividade térmica [W/m K]
    rho=7900;                          %Densidade do aco [kg/m3]
    cp=500;                            %Calor especifico [J/kg K]
    alpha=kc/(rho*cp);                 %Difusividade térmica[m2/s]
    save_int=0;

    %Parametros experimentais
    %v=0.001;                           %Velocidade da tocha [m/s]
    V=20;                              %Tensão elétrica [V]
    I=160;                             %Corrente elétrica [A]
    P=V*I;                             %Potência elétrica do arco [W]
    d=0.01;                           %Diâmetro do bocal [m]
    ni=0.6;                            %Eficiencia da transferencia de calor
    %qduaslinhas=-P*ni/(pi*d*d/4);      %Aporte térmico [W/m2]
    dq = 0;                            %Coordenada de inicio do fluxo [m]
    Tinf=30;                          %Temperatura ambiente [C]
    hinf=25;                           %Coeficiente de convecção [W/m²K]

    %Dados da MalhaM*10^7
    Nx=150;                              %Numero de nos na direcao x
    Ny=150;                              %Numero de nos na direcao y
    dx=L/Nx;                            %Dimensão da malha na direção x [m]
    dy=e/Ny;                            %Dimensão da malha na direção y [m]
    dt=1;                            %Passo de tempo [s]
    t0=20;                              %Tempo total do processo de soldagem [s]
    v = L/t0;                           %Velocidade da tocha [m/s]
    tf=t0+30;
    npt=round(tf/dt);                    %Numero de passos de tempo

    %Inicializa as matrizes para solucao
    A = sparse (zeros (Nx*Ny,Nx*Ny));           %Cria matriz de zeros
    B = sparse (zeros (Nx*Ny,1));               %Cria matriz de zeros coluna

    try
        load('TT.mat');%carrega o arquivo contendo a temperatura já calculada
        load('ti.mat');%carrega o tempo ti que a simulação parou
        T(:,1)=TT(:,ti+1);
    catch
        T = ones (Nx*Ny,1)*Tinf;       % se as variáveis tempo e temperatura não foram salvas, elas agora são criadas  
        ti=1;
        Tc = ones (npt,6)*Tinf; 
    end

    %Processamento


    for ta=0:dt:tf                  %Numero do passo de tempo

        q = zeros (1,Nx);
        ti=ti+1;                      %Passo de tempo atual

        if ta<=t0

        do=round(((dq+v*ta-d/2))/dx);   %Posicao minima da tocha [m]
        df=round(((dq+v*ta+d/2))/dx);   %Posicao máxima da tocha [m]
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
        %Criacao das matrizes
        matrixa                        %Cria a matriz pentagonal A
        matrixb                        %Cria a matriz coluna B

       T(:,1) = A\B;                   %matriz de solucao das temperaturas

     %Pos processamento

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
    contourf(X, Y*10, Z.')
    colormap(jet)
    grid on 
    axis equal
    xlabel('Comprimento [m]')
    ylabel('Espessura [dm]')
    title('Distribuição de temperaturas na chapa')
    caxis([300 55000])
    colorbar
    save_int=save_int+1;
    if save_int==30
        temp=['plate',num2str(ti-1),'.png']; 
        saveas(gca,temp);
        save_int=0;
    end
    Tc(ti,4)=T(Nx*Ny-Nx+1,1);
    Tc(ti,5)=T(round(Nx*Ny-Nx/2),1);
    Tc(ti,6)=T(Nx*Ny,1);

    Tc(ti,1)=T(1,1);
    Tc(ti,2)=T(round(Nx/2),1);
    Tc(ti,3)=T(Nx,1);

    figure (4)
    plot(T1,'o')
    hold on
    plot(T2,'o');plot(T3,'o');
    hold off

    figure(2)
    plot(ta,T(round(Nx*Ny-Nx/2),1),'-ob',ta,T(Nx*Ny-Nx+1,1),'-*r',ta,T(Nx*Ny,1),'-og');
    hold on

    figure(3)
    plot(ta,T(round(Nx/2),1),'-ob',ta,T(1,1),'-*r',ta,T(Nx,1),'-og');
    hold on

    end

    res= abs(Texp-Tc).^2;
    F=sum(sum(res));

    plot(abs(qduaslinhas),F,'-o')
    hold on
    pause (0.5)

    %end

    toc

    %Pos processamento
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
    xlabel('Comprimento [m]')
    ylabel('Espessura [m]')
    title('Distribuição de temperaturas na chapa')

end
