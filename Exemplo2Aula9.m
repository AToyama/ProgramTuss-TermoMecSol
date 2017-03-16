clear all
clc
%CRIANDO
%matriz de rigidez para cada elemento
%graus de liberdade de cada barra
%-------dados de entrada----------------

%Matriz de Cordenanda(infos de x e y em cm)
coords=[0 0; 0 21; 21 0; 21 21];%me dá o num de nós

%Matriz de incidência(nós de incidencia em cada pedaço da estrutura)
incidencia =[1 2; 1 3; 3 4;2 4;2 3;1 4];% me dá o num de elementos

%Matriz que coloca a área das estruturas(propiedades geométricas)
propriedades=[1;1;1;1;sqrt(2);sqrt(2)];%(Área)

%Matriz de Material para cada Elemento
material=[21E5;21E5;21E5;21E5;21E5;21E5];%21E5=21x10^5

Num_Elem=length(incidencia(:,1));%pegando todas as linhas e 1 coluna de incidencia isso define o numero de elementos(elementos=barras)

%matriz de incidencia global
incidencia2=zeros(Num_Elem,5);%definindo o tamanho da matriz, inicializando com tudo zero
K= zeros(4,4);%Inicializando a Matriz de Rigidez(4x4)
GDL=[1 2 3 4;1 2 5 6;5 6 7 8;3 4 7 8;3 4 5 6;1 2 7 8];%Matriz com os graus de liberdade
Kg=zeros(8,8);

%%
%Reescrevendo a matriz de incidencia  com o COMPRIMENTO, COS e SEN
for i=1:Num_Elem%for rodando de 1 até o numero de elementos da matriz de incidencia (todas as linhas da primeira coluna)
    %pegando a cordenada de cada nó
    %obtem a cordenada x do primeiro nó do elemento i
    x1=coords(incidencia(i,1),1);%x1=pega a linha i da primeira coluna da matriz de incidencia e pego a posição (1,1) da matriz coords
    %obtem a cordenada y do primeiro nó do elemento i
    y1=coords(incidencia(i,1),2);%y1=pega a linha i da primeira coluna da matriz de incidencia
    x2=coords(incidencia(i,2),1);%x2=pega a linha i da segunda coluna da matriz de incidencia
    y2=coords(incidencia(i,2),2);%y2=pega a linha i da segunda coluna da matriz de incidencia
    comprimento=sqrt(((x1-x2)^2) + ((y2-y1)^2));%definição do comprimento para cada elemento
    cos= (x2-x1) /comprimento ;%definição de cos
    sen= (y2-y1) /comprimento ;%definição de sen
    incidencia2(i,:)=[incidencia(i,1:2),comprimento, cos, sen];%Matriz nova de incidencia envolvendo a matriz inteira antiga de incidencia +comprimento, sen e cos
    K(:,:,i)=((material(i)*propriedades(i)/comprimento))*[(cos^2) (cos*sen) (-(cos^2)) (-(cos*sen)); (cos*sen) (sen^2) (-(sen*cos)) (-(sen^2)); (-(cos^2)) (-(sen*cos)) (cos^2) (cos*sen);(-(sen*cos)) (-(sen^2)) (cos*sen) (sen^2)];%((material(i)*propriedades(i)/comprimento))= E*A/l*[]
%(:,:,i)salvando todos os elementos da matriz K 4x4 na celula i
%Isso me devolve as 6 matrizes de rigidez, uma para cada barra.
    Kg(GDL(i,:),GDL(i,:))=Kg(GDL(i,:),GDL(i,:))+(K(:,:,i));%Matriz de rigidez global para a a estrutura(GDL de cada barra + K(matriz de rigidez) de cada barra)
% Indexando com o vetor de GDL uma matriz Kg -- Kg(1 1) = Kg(1 1)+K(i)--
%                                                  2 2       2 2
%                                                  3 3       3 3
%                                                  4 4       4 4
end

%Montagem do vetor de carga global ( -1000 pois a força é para baixo)
%(posição 8 pois incide no GDL 8)(incide uma força de -1000 no GDL 8)
f=[0 0 0 0 0 0 0 -1000]'; % ' faz a transposição do vetor
u= inv(Kg(5:8,5:8))*f(5:8,1); % u é meu solver u=(Kg^-1)*f (Aplicadas as condições de contorno.)
% u para os graus de liberdade livre
% Kg(5:8,5:8)Pega as linhas de 5 a 8 da coluna 5 a 8 de Kg e f(5:8,1) pega
% as linhas 5 a 8 da coluna 1 de f.
ug = zeros(8,1);%u2= inv(Kg(1:4,1:4))*f(1:4,1);
ug(5:8,1)=u;%ug contem agora os nos com valor 0 que são restritos e os nós livres que estavam em u 
%%
%Deformação e Tensão
for i =1:Num_Elem
    Deform(i)=(1/incidencia2(i,3))*[-(incidencia2(i,4)) -(incidencia2(i,5)) incidencia2(i,4) incidencia2(i,5)]*ug(GDL(i,:));
    Tensao(i)=(material(i,1)/incidencia2(i,3))*[-(incidencia2(i,4)) -(incidencia2(i,5)) incidencia2(i,4) incidencia2(i,5)]*ug(GDL(i,:));
end
    