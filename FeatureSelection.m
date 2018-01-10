clc,clear all


%% Base folders
base = '/media/micro/Images/BX43Images/'; %Base for micro

%% Loading data

load('data/datos_total')
datos = datos_total;


% datos.BoundingBox=[]; %Eliminando esta columna para compatibilidad
datos.Centroid=[];


%% Merge the wrong class names

datos.etiquetas = categorical(datos.etiquetas);

etiquetas = mergecats(datos.etiquetas, {'Normal', 'RBC_normals', 'RBCnormals'});
etiquetas = mergecats(etiquetas, {'Esferocito','Esferocits'});
etiquetas = mergecats(etiquetas, {'Reticulocito','Reticulocits'});
etiquetas = mergecats(etiquetas, {'Cossos_Pappenheimer','CossosPappenheimer'});
etiquetas = mergecats(etiquetas, {'Cossos_Howell_Jolly','Cossos_Howell_Jollly','CossosHowellJolly'});
etiquetas = mergecats(etiquetas, {'Dianocits','Dianocit'});
etiquetas = mergecats(etiquetas, {'Kinizocits','Knizocits'});
etiquetas = mergecats(etiquetas, {'Irregular_contracted_cells','IrregularContractedCells'});
etiquetas = mergecats(etiquetas, {'Desconocido','unknown'});

datos.etiquetas = etiquetas;


%% Resampling 

rng default %To make reproducible

%tabulacion en forma de tabla
tab = cell2table( tabulate(datos.etiquetas), 'VariableNames', ...
    {'etiquetas', 'Numero', 'Porcentaje'} );

%Seleccionando las menos desbalanceadas, solo es un truco para escoger las
%tres clases mas grandes
tab = tab( tab.Porcentaje > 5.7, :);

tab( strcmp(tab.etiquetas,'Cossos_Pappenheimer'), : )=[];
tab( strcmp(tab.etiquetas, 'Desconocido'), : )=[];


datos = balanceData(datos, tab);

datos.etiquetas = removecats(datos.etiquetas); %remueve las categorias eliminadas


%% Separando features the labels
labels = datos.etiquetas;
features = datos{:, 3:end};
features_name = datos.Properties.VariableNames(3:end);

%% Feature selection usando el metodo Relieff
% Este metodo no tiene en cuenta la redundancia entre descriptores
[ranked,weights_rel] = relieff(features,labels,10);

importFeatures = features_name(ranked);


%% Feature selection using neighborhood component analysis for classification
nca = fscnca(features,labels,'Standardize',true,'Verbose',1);

[weights, id_relevancia] = sort(nca.FeatureWeights, 'descend');

relevantFeatures = features_name(id_relevancia);

tol = 0.02;
selidx =  id_relevancia( weights> tol*max( 1,max(weights) ) );

%datos con los descriptores seleccionados y unicamente con la etiqueta
datos_nca = [datos(:,1), datos(:, selidx + 2 )];



%%

figure,
%jj=3;
for jj = 3:width(datos)
boxplot(datos{:,jj}, datos.etiquetas)
title( datos.Properties.VariableNames{jj}, 'Interpreter', 'none' ) 
pause
%print('datos.Properties.VariableNames{jj}','-dpng')
 end

%%

function out = balanceData(datos, tab)
% realiza el balanceo de los datos sin reemplazo con base al minimo numero
% de celulas de una categoria. 
rng default

out = table;
minNum = min(tab.Numero);

for k = 1:height(tab)
    
    datap = datos( datos.etiquetas == tab.etiquetas{k}, : );
    
    datap = datasample( datap, minNum, 'Replace', false );
    
    out = [out; datap];
    
end


end