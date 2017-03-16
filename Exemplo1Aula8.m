clear all
clc
%-------dados de entrada----------------

%Matriz de Cordenanda(infos de x e y em cm)
coords=[0 0; 0 21; 21 0; 21 21];

%Matriz de incidência(nós de incidencia em cada pedaço da estrutura)
incidencia =[1 2; 1 3; 3 4;2 4;2 3;1 4];

%Matriz que coloca a área das estruturas(propiedades geométricas)
propriedades=[1;1;1;1;sqrt(2);sqrt(2)];%(Área)

%Matriz de Material para cada Elemento
material=[21E5;21E5;21E5;21E5;21E5;21E5];%21E5=21x10^5

Num_Elem=length(incidencia(:,1));%pegando todas as linhas e 1 coluna de incidencia isso define o numero de elementos(elementos=barras)

%matriz de incidencia global
incidencia2=zeros(Num_Elem,5);%definindo o tamanho da matriz, inicializando com tudo zero
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
    sen= (x2-x1) /comprimento ;%definição de sen
    incidencia2(i,:)=[incidencia(i,1:2),comprimento, cos, sen];%Matriz nova de incidencia envolvendo a matriz inteira antiga de incidencia +comprimento, sen e cos
end
