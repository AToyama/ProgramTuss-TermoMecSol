%%  Projeto: IMPLEMENTA��O E AN�LISE DE TRELI�AS PLANAS
%
%   @DESCRIPTION Analysis of 2D frames structures. @
%                Disciplina: TRANSFER�NCIAS DE CALOR E MEC�NICA DOS S�LIDOS - 5ENGCOM 2017/1
%                Aluno: Felipe Frid Buniac, Lucas Scarlato Astur, Andr� De
%                Marco Toyama e Jo�o Pedro Pieroni De Castro
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
fprintf(1, 'SOFTWARE DE AN�LISE DE TRELI�AS PLANAS\n');
disp(br0);
fprintf(1, 'DESIGNED BY FELIPE FRID BUNIAC, LUCAS SCARLATO ASTUR, ANDRE DE MARCO TOYAMA AND JOAO PEDRO PIERONI CASTRO\n');
disp(br0);
fprintf(1, 'ENGENHARIA DE COMPUTA��O - Insper - 2017\n');
disp(br0);
disp(br1);
InpFileName = input('INPUT FILENAME (without extension): ', 's');%recebe o nome do arquivo sem extens�o

%%

FileName    = sprintf('%s.fem', InpFileName);%Adiciona o .fem no nome do arquivo passado em InpFileName
File        = fopen(FileName, 'r');%Abre o arquivo
fprintf(1, '%s', br0);

% Sets the error message.
message = 'TRUSS2D';

%% Reading nodal coordinates
% Sets the keyword.
kwCoords = '*COORDINATES';%No documento de leitura as coordenadas est�o co  esse titulo

fprintf(1,'\nREADING NODAL COORDINATES...');%print para o usu�rio

if (FindKeyWord(kwCoords, File) == 0)%Utiliza a fun��o FindKeyWords para encontrara a plavra *COORDINATES salava em kwCoords no arquivo com nome salvo em File
    warning(message, 'Keyword |%s| Not Found.', kwCoords);% Caso n�o encontre
else
    TotalNumNodes = fscanf(File, '%d', 1);%devolve os nodes 
    coords        = (fscanf(File, '%d%f%f',  [3 TotalNumNodes]))';
end

% deletes node numbers
coords(:, 1) = [];%Elimina a primeira posi��o \

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
K = zeros(4,4);%Inicializando a Matriz de Rigidez(4x4)
Kg = zeros(length(coords(:,1))*2,length(coords(:,1))*2);%Inicializando a Matriz de Rigidez Global(8x8)
GDL = zeros(Num_Elem,4);%Inicializando a Matriz de GDL(6x4)


for i=1:Num_Elem%a cada elemento de barra i...
    
    x1 = coords(Incidencia(i,1),1);%pega a coordenada x do no 1 da barra i
    y1 = coords(Incidencia(i,1),2);%pega a coordenada y do no 1 da barra i
    x2 = coords(Incidencia(i,2),1);%pega a coordenada x do no 2 da barra i
    y2 = coords(Incidencia(i,2),2);%pega a coordenada y do no 2 da barra i
    
    Comprimento = sqrt(((x1-x2)^2) + ((y2-y1)^2));%defini��o do comprimento para cada elemento
    
    GDL(i,1) = Incidencia(i,1)*2-1; %cria��o da matriz GDL:
    GDL(i,2) = Incidencia(i,1)*2;
    GDL(i,3) = Incidencia(i,2)*2-1;
    GDL(i,4) = Incidencia(i,2)*2;
    
    
    cos = (x2-x1) /Comprimento ;%defini��o de cos da barra i
    sen = (y2-y1) /Comprimento ;%defini��o de sen da barra i
    
    %Matriz envolvendo a matriz inteira antiga de Incidencia +Comprimento, sen e cos
    Incidencia2(i,:) = [Incidencia(i,1:2),Comprimento, cos, sen];
    
    %cria a amtriz K da barra I
    K(:,:,i) = ((material(i,1)*Propriedades(i)/Comprimento))*[(cos^2) (cos*sen) (-(cos^2)) (-(cos*sen)); 
                                                            (cos*sen) (sen^2) (-(sen*cos)) (-(sen^2)); 
                                                            (-(cos^2)) (-(sen*cos)) (cos^2) (cos*sen);
                                                            (-(sen*cos)) (-(sen^2)) (cos*sen) (sen^2)];%((material(i)*Propriedades(i)/Comprimento))= E*A/l*[]
    
    %Superpoe matriz k da barra i na Kg
    Kg(GDL(i,:),GDL(i,:))=Kg(GDL(i,:),GDL(i,:))+(K(:,:,i));
                                        
end

Total_Nodes = zeros(1,Num_GDL); %cria uma lista com todos os graus de liberdade da treli�a
for i = 1:Num_GDL;
    Total_Nodes(1,i) = i;
end

Pg = zeros(Num_GDL,1);
for i = 1:length(Loads(:,1)); %monta vetor de for�as globais Pg
    if Loads(i,2) == 1;
        Pg(Loads(i,1)*2-1,1) = Loads(i,3);   
    else
        Pg(Loads(i,1)*2,1) = Loads(i,3);
    end
end

Kg_CF = Kg; % Kg com condicao de contorno p/ calculo das for�as
Kg_CR = Kg; % Kg com condicao de contorno p/ calculo das rea��es


Stuck_Nodes = zeros(1,Num_GDL); %matriz que representa graus de liberdade travados
index = length(HDBCNodes(:,1));
while index >= 1; 
    if HDBCNodes(index,2) == 1
        Kg_CF(HDBCNodes(index,1)*2-1,:) = []; %apaga cada linha impar que representa um gdl travado
        Kg_CF(:,HDBCNodes(index,1)*2-1) = []; %apaga cada coluna impar que representa um gdl travado
        Stuck_Nodes(1,HDBCNodes(index,1)*2-1) = HDBCNodes(index,1)*2-1;%preenche com gdl travados
        Kg_CR(:,HDBCNodes(index,1)*2-1) = []; %apaga cada coluna impar que representa um gdl travado
        Pg(HDBCNodes(index,1)*2-1,:) = [];
        index = index - 1;
        
    else
        Kg_CF(HDBCNodes(index,1)*2,:) = []; %apaga cada linha par que representa um gdl travado
        Kg_CF(:,HDBCNodes(index,1)*2) = []; %apaga cada coluna par que representa um gdl travado
        Stuck_Nodes(1,HDBCNodes(index,1)*2) = HDBCNodes(index,1)*2;%preenche com gdl travados
        Kg_CR(:,HDBCNodes(index,1)*2) = []; %apaga cada coluna par que representa um gdl travado
        Pg(HDBCNodes(index,1)*2,:) = [];
        index = index - 1;
    end    
end

Free_Nodes = setdiff(Total_Nodes, Stuck_Nodes); %Matriz que representa graus de liberdade livres

for i = 1:length(Free_Nodes); 
    Kg_CR(Free_Nodes(length(Free_Nodes)-i+1),:) = []; %apaga cada linha que representa um gdl LIVRE  (cond. de contorno) 
end




%Gauss Sidel para calculo dos deslocamentos nodais
[ U, Erro ] = GaussSidel(100, 10E-7, Kg_CF, Pg);





U = inv(Kg_CF)*Pg;

Ug = zeros(Num_GDL,1);%cria matriz COMPLETA de deslocamentos nodais (incluji tambem aqueles com valor 0.

Reaction = Kg_CR*U; %lista com as for�as de rea��es

for i = 1:length(Free_Nodes)
    Ug(Free_Nodes(1,i),1) = U(i,1);
end 

%Deforma��o e Tens�o
for i =1:Num_Elem
    Deform(i)=(1/Incidencia2(i,3))*[-(Incidencia2(i,4)) -(Incidencia2(i,5)) Incidencia2(i,4) Incidencia2(i,5)]*Ug(GDL(i,:));
    Tensao(i)=(material(i,1)/Incidencia2(i,3))*[-(Incidencia2(i,4)) -(Incidencia2(i,5)) Incidencia2(i,4) Incidencia2(i,5)]*Ug(GDL(i,:));
end

%% Post-processing
disp(br0);
fprintf(1,'POST-PROCESSING...\n');
disp(br0);

%% Output file
OutFileName = sprintf('%s.out', InpFileName);
OutFile     = fopen(OutFileName, 'w');

fprintf(OutFile, '*DISPLACEMENTS\n');
for i = 1 : Num_GDL/2;
   
fprintf(OutFile, '%5d %6.4e ', i, Ug(2*i-1,1));
fprintf(OutFile, '%6.4e \n ', Ug(2*i,1));

end

fprintf(OutFile, '\n*ELEMENT_STRAINS\n');
for i = 1 : TotalNumElements
    fprintf(OutFile, '%5d %e\n', i, Deform(i));
end

fprintf(OutFile, '\n*ELEMENT_STRESSES\n');
for i = 1 : TotalNumElements
    fprintf(OutFile, '%5d %e\n', i, Tensao(i));
end

fprintf(OutFile, '\n*REACTION_FORCES\n');
for i = 1 : size(HDBCNodes,1);
    
    
    if HDBCNodes(i, 2) == 1
        fprintf(OutFile, '%5d FX = %e\n', HDBCNodes(i, 1), Reaction(i));
    end
    
    if HDBCNodes(i, 2) == 2
        fprintf(OutFile, '%5d FY = %e\n', HDBCNodes(i, 1), Reaction(i));
    end
       
end

fclose(OutFile);