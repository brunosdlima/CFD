%Escoamento multifasico
%Bruno Silva de Lima
%The motion of small spherical particles in a cellular flow field

%Essa rotina simula o comportamento de particulas com diferentes numeros de
%Stokes no escoamento definido no artigo 'The motion of small spherical
%particles in a cellular flow field'. Para tal sao criados tres diferentes
%diretorios onde sao salvas imagens e gerado um video para cada numero de
%Stokes.

tic

%Cria diretorios onde serao salvas as imagens
mkdir Stokes1
mkdir Stokes0_1
mkdir Stokes0_001

%Limpa a memoria e a tela
clc
clear all
close all

%Cria os parametros necessarios para a simulacao
Stokes=1;                             	     %primeiro numero de Stokes desejado
Uinf=0.2;                                   %velocidade do escoamento[m/s]
L=2*pi;                                      %lado da celula[m]
g=9.81;                                      %gravidade[m/s^2]
mp=1e-10;                                    %massa da particula[kg]
a=1e-3;                                      %raio da particula[m]    
mi=1.003e-3;                                 %viscosidade dinamica da agua[Ps*s]
rhop=mp/(4*pi*(a^3)/3);                      %massa especifica da particula[kg/m^3]
rhof=1000;                                   %massa especifica da agua [kg/m^3]
Re=rhof*Uinf*a/mi;                           %numero de Reynolds
tca=rhop*(a^2)/(18*mi);                      %tempo caracteristico [s]
Stk2=tca*Uinf/a;                             %numeto de Stokes atual
t=60;                                        %tempo total de simulacao [s]
Nt=600000;                                  %numero de passos de tempo
dt=t/Nt;                                     %passo de tempo [s]
N=7;                                         %raiz quadrada do numero de particulas isto é N*N é o numero de particulas
k=1;                                         %contador
saveimg=0;                                   %define quando a imagem sera salva
gr=0;                                        %ordem de grandeza do numero de passos de tempo
gr2=Nt;                                      %contador

while gr2>=1
    gr=gr+1;                                 %ordem de grandeza do numero de passos de tempo, parametro utilizado no calculo da variavel printer
    gr2=gr2/10;
end
printer(gr)=zeros;                           %parametro utilizado para salvar as imagens em ordem alfabetica corretamente

 for b=1:3                                   %loop para testar tres diferentes numeros de Stokes
     
    Pp(N,N,2)=zeros;                         %matriz inicial para os pontos do domínio [m]
    Vp(N,N,2)=zeros;                         %matriz com a velocidade inicial dos pontos [m]
    Vr(3)=zeros;                             %velociade do fluido [m/s]

    %corrigir a massa em função do numero de Stokes
    while norm(Stk2-Stokes)>0.00000001
        rhop=mp/(4*pi*(a^3)/3);
        tca=rhop*(a^2)/(18*mi);
        Stk2=tca*Uinf/a;
        mp=mp*(1+(Stokes-Stk2)/(Stk2+Stokes));
    end

    %matriz com a posição inicial dos pontos do dominio [m]
    for i=1:N
        for j=1:N 
            Pp(i,j,1)=((i-0.5)*L/N)-L/2;    
            Pp(i,j,2)=((j-0.5)*2*L/N)-L/2;
        end    
    end

    %Salva a posição inicial das partículas em imagem
    figure(1);
    plot(Pp(:,:,1),Pp(:,:,2),'b*'); 
    axis([-L/2-pi L/2+pi -12*L L]);
    titulo=['Posição da partícula           tempo: ',num2str(k*dt,'%.1f'),' [s]'];
    title(titulo)
    xlabel('Eixo x')
    ylabel('Eixo y')
        
        %Salva imagem com a posicao inicial
        %cria vetor printer para organizar em ordem alfabetica
        m=gr;                                                                  %contador
        mt=1;                                                                  %contador
        for m2=gr-1:-1:0
            mt=mt*10;
        end
        mk=k;                                                                  %contador
        m2=1;                                                                  %contador
        while mt>=1
            printer(m2)=floor(mk/mt);                                          %vetor para organizar imagens em ordem alfabetica
            mk=mk-mt*floor(mk/mt);
            mt=mt/10;
            m2=m2+1;
        end
        if Stokes==1                                                           %checa em qual diretorio ira salvar
            cd Stokes1
            part=['particulaStokes',num2str(Stokes),'numero',num2str(printer),'.jpg']; 
            saveas(gca,part);
            cd ../
            workingDir = 'Stokes1';                                            %diretorio utilizado para salvar o video depois de gerar as imagens
        elseif Stokes==0.1
            cd Stokes0_1
            part=['particulaStokes',num2str(Stokes),'numero',num2str(printer),'.jpg']; 
            saveas(gca,part);
            cd ../
            workingDir = 'Stokes0_1';
        elseif Stokes==0.001
            cd Stokes0_001
            part=['particulaStokes',num2str(Stokes),'numero',num2str(printer),'.jpg']; 
            saveas(gca,part);
            cd ../
            workingDir = 'Stokes0_001';
        end
        close(figure(1));

        %Modifica a posição das partículas de acordo com a forca resultante
        for k=1:Nt
            saveimg=saveimg+dt;                                                %Contador para decidir quando as imagens sao salvas
            for i=1:N
                for j=1:N
                    Vf= [Uinf*sin(Pp(i,j,1)/L)*cos(Pp(i,j,2)/L), -Uinf*cos(Pp(i,j,1)/L)*sin(Pp(i,j,2)/L), 0];%Velocidade do fluido [m/s]
                    w=[0 0 (2*sin(Pp(i,j,1)/L)*sin(Pp(i,j,2)/L))/L];           %Rotacional
                    Vr=Vf-[Vp(i,j,1) Vp(i,j,2) 0];                                           %Velocidade relativa [m/s]
                    Re=rhof*norm(Vr)*a/mi;                                     %Numero de Reynolds
                    Cd=24/Re;                                                  %Coeficiente de arrasto
                    D=(0.5*rhof*mp*Cd/(rhop*a))*(Vr*norm(Vr));                 %Forca de arrasto [N]                   
                    Ls=1.61*(a^2)*((mi*rhof*(norm(w)))^(1/2))*(cross((Vr),w)); %Forca de sustentacao de Saffman  [N]
                    P=[0 -mp*g 0];                                             %Peso [N]
                    dVdt=(D+Ls+P)/mp;                                          %Equacao de movimento da particula

        %Metodo de Euler           
                    Vp(i,j,1)=Vp(i,j,1)+dVdt(1)*dt;                            %Velocidade em x[m]
                    Vp(i,j,2)=Vp(i,j,2)+dVdt(2)*dt;                            %Velocidade em y[m]
                    %calculo da posicao da particula
                    Pp(i,j,1)=Pp(i,j,1)+Vp(i,j,1)*dt;                          %Posicao em x [m]
                    Pp(i,j,2)=Pp(i,j,2)+Vp(i,j,2)*dt;                          %Posicao em y [m]
                    
                end
            end

        %Salva as novas posicoes das particulas em imagem em diretorios separados
            if saveimg>=0.1
                saveimg=0;
                figure(k);                        
                plot(Pp(:,:,1),Pp(:,:,2),'b*'); 
                axis([-L/2-pi L/2+pi -12*L L]);
                titulo=['Posição da partícula           tempo: ',num2str(k*dt,'%.1f'),' [s]'];
                title(titulo)
                xlabel('Eixo x')
                ylabel('Eixo y')
            %cria vetor printer para organizar em ordem alfabetica
                m=gr;                                                              %contador
                mt=1;                                                              %contador
                for m2=gr-1:-1:0
                    mt=mt*10;
                end
                mk=k;                                                              %contador
                m2=1;                                                              %contador
                while mt>=1
                    printer(m2)=floor(mk/mt);                                      %vetor para organizar imagens em ordem alfabetica
                    mk=mk-mt*floor(mk/mt);
                    mt=mt/10;
                    m2=m2+1;
                end
                if Stokes==1                                                       %checa em qual diretorio ira salvar
                    cd Stokes1
                    part=['particulaStokes',num2str(Stokes),'numero',num2str(printer),'.jpg']; 
                    saveas(gca,part);
                    cd ../
                elseif Stokes==0.1
                    cd Stokes0_1
                    part=['particulaStokes',num2str(Stokes),'numero',num2str(printer),'.jpg']; 
                    saveas(gca,part);
                    cd ../
                elseif Stokes==0.001
                    cd Stokes0_001
                    part=['particulaStokes',num2str(Stokes),'numero',num2str(printer),'.jpg']; 
                    saveas(gca,part);
                    cd ../
                end
                close(figure(k));
            end
        end
    
    %Gera video no formato AVI para cada numero de Stokes
    shuttleVideo = VideoReader('shuttle.avi');
    imageNames = dir(fullfile(workingDir,'*.jpg'));
    imageNames = {imageNames.name}';
    vid=['shuttle_Stokes',num2str(Stokes),'.avi'];
    outputVideo = VideoWriter(vid);
    outputVideo.FrameRate = 10;
    open(outputVideo)
    for ii = 1:length(imageNames)
       img = imread(fullfile(workingDir,imageNames{ii}));
       writeVideo(outputVideo,img)
    end
    close(outputVideo)
    
    %condicao criada para testar os diferentes numeros de Stokes
    if Stokes==1
        Stokes=0.1;
        Nt=60000000;                                 %numero de passos de tempo
        dt=t/Nt;                                     %passo de tempo [s]
        gr=0;                                        %ordem de grandeza do numero de passos de tempo
        gr2=Nt;                                      %contador
        while gr2>=1
            gr=gr+1;                                 %ordem de grandeza do numero de passos de tempo, parametro utilizado no calculo da variavel printer
            gr2=gr2/10;
        end
        printer(gr)=zeros;                           %parametro utilizado para salvar as imagens em ordem alfabetica corretamente
    else
        Stokes=0.001;
        Nt=6000000000;                               %numero de passos de tempo
        dt=t/Nt;                                     %passo de tempo [s]
        gr=0;                                        %ordem de grandeza do numero de passos de tempo
        gr2=Nt;                                      %contador
        while gr2>=1
            gr=gr+1;                                 %ordem de grandeza do numero de passos de tempo, parametro utilizado no calculo da variavel printer
            gr2=gr2/10;
        end
        printer(gr)=zeros;                           %parametro utilizado para salvar as imagens em ordem alfabetica corretamente
    end
 end

disp ('Tempo necessario para calculo')
toc
disp ('Fim da rotina')