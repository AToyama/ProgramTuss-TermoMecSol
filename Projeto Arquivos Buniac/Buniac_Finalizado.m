%%  Projeto: IMPLEMENTAÇÃO E ANÁLISE DE TRELIÇAS PLANAS
%
%   @DESCRIPTION Analysis of 2D frames structures. @
%                Disciplina: TRANSFERÊNCIAS DE CALOR E MECÂNICA DOS SÓLIDOS - 5ENGCOM 2017/1
%                Aluno: Felipe Frid Buniac, Lucas Scarlato Astur, André De
%                Marco Toyama e João Pedro Pieroni De Castro
%     
%                Professor: Caio Fernandes Rodrigo dos Santos

%% Clean memory and close windows
clear all
close all
clc
%% Reading the input filename(Reads all the information from the structure in the File)
%br = ' ';%cloca entre aspas
br0(1:66) = '=';%coloca 66 simbolos =
br1(1:66) = '-';% coloca 66 simbolos _ 

disp(br0);
fprintf(1, 'SOFTWARE DE ANÁLISE DE TRELIÇAS PLANAS\n');
disp(br0);
fprintf(1, 'DESIGNED BY FELIPE FRID BUNIAC, LUCAS SCARLATO ASTUR, ANDRE DE MARCO TOYAMA AND JOAO PEDRO PIERONI CASTRO\n');
disp(br0);
fprintf(1, 'ENGENHARIA DE COMPUTAÇÃO - Insper - 2017\n');
disp(br0);
disp(br1);
InpFileName = input('INPUT FILENAME (without extension): ', 's');%recebe o nome do arquivo sem extensão

%%

FileName    = sprintf('%s.fem', InpFileName);%Adiciona o .fem no nome do arquivo passado em InpFileName
File        = fopen(FileName, 'r');%Abre o arquivo
fprintf(1, '%s', br0);

% Sets the error message.
message = 'TRUSS2D';

%% Reading nodal coordinates
% Sets the keyword.
kwCoords = '*COORDINATES';%No documento de leitura as coordenadas estão co  esse titulo

fprintf(1,'\nREADING NODAL COORDINATES...');%print para o usuário

if (FindKeyWord(kwCoords, File) == 0)%Utiliza a função FindKeyWords para encontrara a plavra *COORDINATES salava em kwCoords no arquivo com nome salvo em File
    warning(message, 'Keyword |%s| Not Found.', kwCoords);% Caso não encontre
else
    TotalNumNodes = fscanf(File, '%d', 1);%devolve os nodes 
    coords        = (fscanf(File, '%d%f%f',  [3 TotalNumNodes]))';
end

% deletes node numbers
coords(:, 1) = [];%Elimina a primeira posição \

%% Reading element groups
% Sets the keyword.
kwElemGrps = '*ELEMENT_GROUPS';

fprintf(1,'\nREADING ELEMENT GROUPS...');
if (FindKeyWord(kwElemGrps, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwElemGrps);
else
    NumGroups = fscanf(File, '%d', 1);
    Groups = zeros(NumGroups,3);
    for i = 1:NumGroups
        Groups(i,1:2)    = (fscanf(File, '%d%d', [2 NumGroups]))';
        Shape = fscanf(File, '%s', 1);
        
        if (strcmpi(Shape, 'BAR'))
            Groups(i,3) = 1;
        end
        
    end
end

% deletes group numbers
Groups(:, 1) = [];

%total number of elements
TotalNumElements = sum(Groups(:,1));

%% Reading incidences
% Sets the keyword.
kwIncid = '*INCIDENCES';

fprintf(1,'\nREADING ELEMENT INCIDENCES...');
if (FindKeyWord(kwIncid, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwIncid);
else
    Incidencia = (fscanf(File, '%d%f%f', [3 TotalNumElements]))';
end

% deletes element numbers
Incidencia(:, 1) = [];

% Tipo de elemento
ElemType = zeros(TotalNumElements,1);
aux = 1;
for i = 1:NumGroups
    
    for j = 1:Groups(i,1)
        ElemType(aux,1) = Groups(i,2);
        aux = aux+1;
    end

end

%% Reading materials
% Sets the keyword.
kwMaters = '*MATERIALS';

fprintf(1,'\nREADING MATERIALS...');
if (FindKeyWord(kwMaters, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwMaters);
else
    NumMaters = fscanf(File, '%d', 1);
    material    = (fscanf(File, '%f%f%f', [3 NumMaters]))';
end


%% Reading geometric properties
% Sets the keyword.
kwGPs = '*GEOMETRIC_PROPERTIES';

fprintf(1,'\nREADING GEOMETRIC PROPERTIES...');
if (FindKeyWord(kwGPs, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwGPs);
else
    NumGPs = fscanf(File, '%d', 1);
    Propriedades    = (fscanf(File, '%f%f%f', [1 NumGPs]))';
end

%% Reading boundary conditions
% Sets the keyword.
kwBCs = '*BCNODES';

fprintf(1,'\nREADING BOUNDARY CONDITIONS...');
if (FindKeyWord(kwBCs, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwBCs);
else
    NumBCNodes = fscanf(File, '%d', 1);
    HDBCNodes  = (fscanf(File, '%d%d', [2 NumBCNodes]))';
end

%% Reading loads
% Sets the keyword.
kwLoads = '*LOADS';

fprintf(1,'\nREADING LOADS... \n');
if (FindKeyWord(kwLoads, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwLoads);
else
    NumLoadedNodes = fscanf(File, '%d', 1);
    Loads          = (fscanf(File, '%d%d%f', [3 NumLoadedNodes]))';
end

% Close input file
fclose(File);

%%


Num_Elem = length(Incidencia(:,1));%pegando todas as linhas e 1 coluna de Incidencia isso define o numero de elementos(elementos=barras)
Num_GDL = length(coords(:,1))*2;


Incidencia2 = zeros(Num_Elem,5);%definindo o tamanho da matriz de Incidencia global, inicializando com tudo zero
K = zeros(4,4);%Inicializando a Matriz de Rigidez(4x4) (length(coords(:,1)),length(coords(:,1)))
Kg = zeros(length(coords(:,1))*2,length(coords(:,1))*2);%Inicializando a Matriz de Rigidez Global(8x8)
GDL = zeros(Num_Elem,4);%Inicializando a Matriz de GDL(6x4)


for i=1:Num_Elem%for rodando de 1 até o numero de elementos da matriz de Incidencia (todas as linhas da primeira coluna)
    %pegando a cordenada de cada nó
    
    x1 = coords(Incidencia(i,1),1);%x1=pega a linha i da primeira coluna da matriz de Incidencia e pego a posição (1,1) da matriz coords E obtem a cordenada x do primeiro nó do elemento i
    y1 = coords(Incidencia(i,1),2);%y1=pega a linha i da primeira coluna da matriz de Incidencia E obtem a cordenada y do primeiro nó do elemento i
    x2 = coords(Incidencia(i,2),1);%x2=pega a linha i da segunda coluna da matriz de Incidencia
    y2 = coords(Incidencia(i,2),2);%y2=pega a linha i da segunda coluna da matriz de Incidencia
    
    Comprimento = sqrt(((x1-x2)^2) + ((y2-y1)^2));%definição do Comprimento para cada elemento
    
    GDL(i,1) = Incidencia(i,1)*2-1;
    GDL(i,2) = Incidencia(i,1)*2;
    GDL(i,3) = Incidencia(i,2)*2-1;
    GDL(i,4) = Incidencia(i,2)*2;
    
    
    cos = (x2-x1) /Comprimento ;%definição de cos
    sen = (y2-y1) /Comprimento ;%definição de sen
    
    Incidencia2(i,:) = [Incidencia(i,1:2),Comprimento, cos, sen];%Matriz nova de Incidencia envolvendo a matriz inteira antiga de Incidencia +Comprimento, sen e cos
    
    
    K(:,:,i) = ((material(i,1)*Propriedades(i)/Comprimento))*[(cos^2) (cos*sen) (-(cos^2)) (-(cos*sen)); 
                                                            (cos*sen) (sen^2) (-(sen*cos)) (-(sen^2)); 
                                                            (-(cos^2)) (-(sen*cos)) (cos^2) (cos*sen);
                                                            (-(sen*cos)) (-(sen^2)) (cos*sen) (sen^2)];%((material(i)*Propriedades(i)/Comprimento))= E*A/l*[]

    Kg(GDL(i,:),GDL(i,:))=Kg(GDL(i,:),GDL(i,:))+(K(:,:,i));
                                        
end

Pg = zeros(Num_GDL,1);
for i = 1:length(Loads(:,1)); %monta vetor de forças globais Pg
    if Loads(i,2) == 1
        Pg(Loads(i,1)*2-1,1) = Loads(i,3);   
    else
        Pg(Loads(i,1)*2,1) = Loads(i,3);
    end
end


index = length(HDBCNodes(:,1));
while index >= 1; %aplica condições de contorno e deleta linhas e colunas travadas da Kg e do vetor de forças Pg
    if HDBCNodes(index,2) == 1
        Kg(HDBCNodes(index,1)*2-1,:) = [];
        Kg(:,HDBCNodes(index,1)*2-1) = [];
        Pg(HDBCNodes(index,1)*2-1,:) = [];
        index = index - 1;
    else
        Kg(HDBCNodes(index,1)*2,:) = [];
        Kg(:,HDBCNodes(index,1)*2) = [];
        Pg(HDBCNodes(index,1)*2,:) = [];
        index = index - 1;
    end    
end





%Montagem do vetor de carga global ( -1000 pois a força é para baixo)
%(posição 8 pois incide no GDL 8)
%% Gauss Sidel
[ U, Erro ] = GaussSidel_end_Buniac(100, 10E-7, Kg, Pg);
%U = inv(Kg)*Pg; % u é meu solver u=(Kg^-1)*f (Aplicadas as condições de contorno.)
% u para os graus de liberdade livre(u=deslocamento)
% Kg(5:8,5:8)Pega as linhas de 5 a 8 da coluna 5 a 8 de Kg e f(5:8,1) pega
% as linhas 5 a 8 da coluna 1 de f
ug = zeros(Num_GDL,1);%u2= inv(Kg(1:4,1:4))*f(1:4,1);
ug(Loads:Num_GDL,1)=U;%ug contem agora os nos com valor 0 que são restritos e os nós livres que estavam em u 


%% Aplicando as Equações
%Deformação e Tensão
for i =1:Num_Elem
    Deform(i)=(1/Incidencia2(i,3))*[-(Incidencia2(i,4)) -(Incidencia2(i,5)) Incidencia2(i,4) Incidencia2(i,5)]*ug(GDL(i,:));
    Tensao(i)=(material(i,1)/Incidencia2(i,3))*[-(Incidencia2(i,4)) -(Incidencia2(i,5)) Incidencia2(i,4) Incidencia2(i,5)]*ug(GDL(i,:));
end