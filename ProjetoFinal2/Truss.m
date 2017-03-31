%%  Projeto: IMPLEMENTAÇÃO E ANÁLISE DE TRELIÇAS PLANAS
%
%   @DESCRIPTION Analysis of 2D frames structures. @
%                Disciplina: TermoSol
%                Prof. Caio

%% Clean memory and close windows
clear all
close all
clc

%% Reading the input filename
br = ' ';
br0(1:66) = '=';
br1(1:66) = '-';

disp(br0);
fprintf(1, 'IMPLEMENTAÇÃO E ANÁLISE DE TRELIÇAS PLANAS\n');
disp(br0);
fprintf(1, 'ENGENHARIA DE COMPUTAÇÃO - Insper - 2017\n');
disp(br0);
fprintf(1, '\n%s\n', br0);
InpFileName = input('INPUT FILENAME (without extension): ', 's');

%%

FileName    = sprintf('%s.fem', InpFileName);
File        = fopen(FileName, 'r');
fprintf(1, '%s', br0);

% Sets the error message.
message = 'TRUSS2D';

%% Reading nodal coordinates
% Sets the keyword.
kwCoords = '*COORDINATES';

fprintf(1,'\nREADING NODAL COORDINATES...');
if (FindKeyWord(kwCoords, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwCoords);
else
    TotalNumNodes = fscanf(File, '%d', 1);
    Coords        = (fscanf(File, '%d%f%f',  [3 TotalNumNodes]))';
end

% deletes node numbers
Coords(:, 1) = [];

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
    Incid = (fscanf(File, '%d%f%f', [3 TotalNumElements]))';
end

% deletes element numbers
Incid(:, 1) = [];

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
    Maters    = (fscanf(File, '%f%f%f', [3 NumMaters]))';
end

%% Reading geometric properties
% Sets the keyword.
kwGPs = '*GEOMETRIC_PROPERTIES';

fprintf(1,'\nREADING GEOMETRIC PROPERTIES...');
if (FindKeyWord(kwGPs, File) == 0)
    warning(message, 'Keyword |%s| Not Found.', kwGPs);
else
    NumGPs = fscanf(File, '%d', 1);
    GPs    = (fscanf(File, '%f%f%f', [1 NumGPs]))';
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% IMPLEMENTAR SOLVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Prop: Matriz com as dimensões de cada elemento
    % comprimento   sin         cos
Prop = [ 0.4000    1.0000         0
         0.3000         0    1.0000
         0.5000   -0.8000   -0.6000];


% DOFs Numeração (Os nós livres são numerados primeiro)
NodalDOFNumbers = [ 1 4 1
                    2 5 6
                    3 2 3];
                           
% Numbers of free and restricted dofs
TotalNumFreeDOFs  = 3;
TotalNumRestrDOFs = 3;

% Vetor solução para os deslocamentos nodais
U = 1.0e-05 * [-0.0952
               0.1607
              -0.4018
               0
               0
               0];
            
% Vetor solução para as deformações
Strain =  1.0e-05 * [0.2381
                     0.5357
                    -0.2976];
                
% Vetor solução para as tensões em cada elemento
Stress = 1.0e+06 * [0.5000
                    1.1250
                   -0.6250];
                
% Forças de reação
FRg = [ 0
        0
        0
   75.0000
 -225.0000
  100.0000];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Post-processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Post-processing
disp(br0);
fprintf(1,'POST-PROCESSING...\n');
disp(br0);

%% Output file
OutFileName = sprintf('%s.out', InpFileName);
OutFile     = fopen(OutFileName, 'w');

fprintf(OutFile, '*DISPLACEMENTS\n');
for i = 1 : TotalNumNodes
    
displa = [U(NodalDOFNumbers(i,[2 3]))'];
fprintf(OutFile, '%5d %6.4e %6.4e \n', i, displa);

end

fprintf(OutFile, '\n*ELEMENT_STRAINS\n');
for i = 1 : TotalNumElements
    fprintf(OutFile, '%5d %e\n', i, Strain(i));
end

fprintf(OutFile, '\n*ELEMENT_STRESSES\n');
for i = 1 : TotalNumElements
    fprintf(OutFile, '%5d %e\n', i, Stress(i));
end

fprintf(OutFile, '\n*REACTION_FORCES\n');
for i = 1 : TotalNumRestrDOFs
    
    ElemEqs = NodalDOFNumbers(HDBCNodes(i, 1),HDBCNodes(i, 2)+1);
    
    if HDBCNodes(i, 2) == 1
        fprintf(OutFile, '%5d FX = %e\n', HDBCNodes(i, 1), FRg(ElemEqs));
    end
    
    if HDBCNodes(i, 2) == 2
        fprintf(OutFile, '%5d FY = %e\n', HDBCNodes(i, 1), FRg(ElemEqs));
    end
       
end

fclose(OutFile);

%% Mesh and boundary conditions
figure('Color',[0 0 0]);
subplot1 = subplot(2,1,1, ...
    'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
    'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
    'Xlim', [min(Coords(:, 1)) - .5 * Prop(1,1), max(Coords(:, 1)) + .5 * Prop(1,1)], ...
    'Ylim', [min(Coords(:, 2)) - .5 * Prop(1,1), max(Coords(:, 2)) + .5 * Prop(1,1)], ...
    'Color',[0 0 0]);

% Create labels (X e Y)
xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

% Create title
title('Diagram','FontSize',17, 'Color',[1 1 1]);
box on;

hold all;

% plots original mesh
for ElemNum = 1 : TotalNumElements
    fill(Coords(Incid(ElemNum, :), 1), Coords(Incid(ElemNum, :), 2), ...
        [.5 .5 .5], 'EdgeColor', [.7 .7 .7], 'LineWidth', 1);
end

% plots nodes of the undeformed mesh
plot(Coords(:,1), Coords(:,2), ...
    'o','MarkerEdgeColor','y','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);

%% Plots loads
FFe = .25 * (Loads(:, 3) .* abs(max(Prop(:, 1)))) ./ abs(max(Loads(:,3)));
for i = 1 : size(Loads, 1)
    if Loads(i, 2) == 1
        quiver(Coords(Loads(i),1)-FFe(i), Coords(Loads(i),2), FFe(i), 0,...
            'MaxHeadSize', 3,'LineWidth', 1, 'Color',[1 0 0], 'AutoScaleFactor',1);
    elseif Loads(i, 2) == 2
        quiver(Coords(Loads(i),1), Coords(Loads(i),2)-FFe(i), 0, FFe(i),...
            'MaxHeadSize', 3,'LineWidth', 1, 'Color',[1 0 0], 'AutoScaleFactor',1);
    end
end

%% Plots bcs
for i = 1 : size(HDBCNodes, 1)
    if HDBCNodes(i, 2) == 1
        quiver(Coords(HDBCNodes(i), 1)-.7e-1*abs(max(Prop(:, 1))), Coords(HDBCNodes(i), 2), 0, 0, 'Marker','>', 'MarkerSize', 11, ...
            'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);
    
    elseif HDBCNodes(i, 2) == 2
         quiver(Coords(HDBCNodes(i), 1), Coords(HDBCNodes(i), 2)-.7e-1*abs(max(Prop(:, 1))), 0, 0, 'Marker','^', 'MarkerSize', 11, ...
            'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);
    end
end
hold off;

%% Plots reaction forces
subplot2 = subplot(2,1,2, ...
    'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
    'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
    'Xlim', [min(Coords(:, 1)) - .5 * Prop(1,1), max(Coords(:, 1)) + .5 * Prop(1,1)], ...
    'Ylim', [min(Coords(:, 2)) - .5 * Prop(1,1), max(Coords(:, 2)) + .5 * Prop(1,1)], ...
    'Color',[0 0 0]);

% Create labels (X e Y)
xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

% Create title
title('Reaction loads','FontSize',17, 'Color',[1 1 1]);
box on;

hold all;

% plots original mesh
for ElemNum = 1 : TotalNumElements
    fill(Coords(Incid(ElemNum, :), 1), Coords(Incid(ElemNum, :), 2), ...
        [.5 .5 .5], 'EdgeColor', [.7 .7 .7], 'LineWidth', 1);
end

FFR = .15 * (FRg .* abs(max(Prop(:, 1)))) ./ abs(max(FRg));
for i = 1 : size(HDBCNodes, 1)
    if HDBCNodes(i, 2) == 1
        
        ElemEqs = NodalDOFNumbers(HDBCNodes(i, 1),HDBCNodes(i, 2)+1);
        
        quiver(Coords(HDBCNodes(i),1)-FFR(ElemEqs), Coords(HDBCNodes(i), 2), FFR(ElemEqs), 0,...
            'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);
    
    elseif HDBCNodes(i, 2) == 2
        ElemEqs = NodalDOFNumbers(HDBCNodes(i, 1),HDBCNodes(i, 2)+1);
        
        quiver(Coords(HDBCNodes(i), 1), Coords(HDBCNodes(i), 2)-FFR(ElemEqs), 0, FFR(ElemEqs),...
            'MaxHeadSize', 3,'LineWidth', 1, 'Color',[0 0 1], 'AutoScaleFactor',1);
    end
end

% plots nodes of the undeformed mesh
plot(Coords(:,1), Coords(:,2), ...
    'o','MarkerEdgeColor','y','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);

hold off

%% Plot element strains
figure('Colormap',...
    [0 0 0.6667;0 0 1;0 0.3333 1;0 0.6667 1;0 1 1;0 1 0.3333;0.3333 1 0;1 1 0;1 0.6667 0;1 0.3333 0],...
    'Color',[0 0 0]);

subplot3 = subplot(2,1,1, ...
    'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
    'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
    'Xlim', [min(Coords(:, 1)) - .5 * Prop(1,1), max(Coords(:, 1)) + .5 * Prop(1,1)], ...
    'Ylim', [min(Coords(:, 2)) - .5 * Prop(1,1), max(Coords(:, 2)) + .5 * Prop(1,1)], ...
    'Color',[0 0 0]);

% Create labels
xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

% Create title
title('Element strains','FontSize',17, 'Color',[1 1 1]);
box on;

hold all;

% plot original mesh
for ElemNum = 1 : TotalNumElements
    fill(Coords(Incid(ElemNum, :), 1), Coords(Incid(ElemNum, :), 2), ...
        [.5 .5 .5], 'EdgeColor', [.5 .5 .5], 'LineWidth', 1);
end

% Deformed coordinates
for i = 1 : TotalNumNodes
    
    auxC1 = U(NodalDOFNumbers(:,[2 3]));
    Coordsd     = Coords + auxC1;
    ScaleFactor = 1e4; %for plot
    Coordsdd    = Coords + ScaleFactor * U(NodalDOFNumbers(:,[2 3]));
    
end

% plot deformed mesh
for ElemNum = 1 : TotalNumElements    
    % calcula as deformações
    di =  Coords(Incid(ElemNum, :), :);
    df = Coordsd(Incid(ElemNum, :), :);
    def(ElemNum, :) = sum(abs(di - df), 2) / Prop(ElemNum,1);
    
    % plot deformed mesh and element strains
    fill(Coordsdd(Incid(ElemNum, :), 1), Coordsdd(Incid(ElemNum, :), 2), ...
        def(ElemNum, :), 'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 1);
end

hcb = colorbar('peer',subplot3, 'YTick', linspace(min(min(def)), max(max(def)), 10), ...
    'YMinorTick','on',...
    'YGrid','off','YColor',[.7 .7 .7], ...
    'XGrid','off','XColor',[.7 .7 .7], ...
    'MinorGridLineStyle','none',...
    'LineWidth', 1,...
    'GridLineStyle','-',...
    'FontWeight','normal', 'Color', [.7 .7 .7]);

set(hcb,'YTickMode','manual');

% plots os nós da geometria deformada
plot(Coordsdd(:,1), Coordsdd(:,2), ...
    'o','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);

hold off;

%% Plot element stresses
subplot4 = subplot(2,1,2, ...
    'PlotBoxAspectRatio',[1 .5 1], 'DataAspectRatio',[1 1 1], ...
    'XColor',[.5 .5 .5], 'YColor',[.5 .5 .5], ...
    'Xlim', [min(Coords(:, 1)) - .5 * Prop(1,1), max(Coords(:, 1)) + .5 * Prop(1,1)], ...
    'Ylim', [min(Coords(:, 2)) - .5 * Prop(1,1), max(Coords(:, 2)) + .5 * Prop(1,1)], ...
    'Color',[0 0 0]);

% Create labels (X e Y)
xlabel('X','FontSize',10, 'Color',[.8 .8 .8]); 
ylabel('Y','FontSize',10, 'Color',[.8 .8 .8]);

% Create title
title('Element stresses','FontSize',17, 'Color',[1 1 1]);
box on;

hold on;

% plot original mesh
for ElemNum = 1 : TotalNumElements
    fill(Coords(Incid(ElemNum, :), 1), Coords(Incid(ElemNum, :), 2), ...
        [.5 .5 .5], 'EdgeColor', [.3 .3 .3], 'LineWidth', 1);
end

% plots stresses on elements of the deformaded mesh
for ElemNum = 1 : TotalNumElements
    fill(Coordsdd(Incid(ElemNum, :), 1), ...
         Coordsdd(Incid(ElemNum, :), 2), ...
        [Stress(ElemNum) Stress(ElemNum)], ...
        'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 1);
end

hcb = colorbar('peer',subplot4, 'YTick', linspace(min(Stress), max(Stress), 10), ...
    'YMinorTick','on',...
    'YGrid','off','YColor',[.7 .7 .7], ...
    'XGrid','off','XColor',[.7 .7 .7], ...
    'MinorGridLineStyle','none',...
    'LineWidth', 1,...
    'GridLineStyle','-',...
    'FontWeight','normal', 'Color', [.7 .7 .7]);
set(hcb,'YTickMode','manual');

% plot nodes of the deformed mesh
plot(Coordsdd(:,1), Coordsdd(:,2), ...
    'o','MarkerEdgeColor','w','MarkerFaceColor','k','MarkerSize',3,'LineWidth',1);

hold off;

%%

