function datos = Relacioetiquetes(taulaEtiqueta,propietatsmorfo,k,NombreArchivo,datos)

centroides = propietatsmorfo.Centroid; % Centroides de cada eritrocit
etiquetas = cell( size(centroides,1), 1); % Creem una cela del tamany corresponen 
%al nombre de centroides (eritrocits) que hi ha


for j = 2:width(taulaEtiqueta)
        
    label = taulaEtiqueta.Properties.VariableNames{j}; % Selecciona el nom del tipus d'eritrocit 
    
    boxLabel = taulaEtiqueta.(label){k}; % Selecciona el primer eritrocit del tipus 'label'
    
    indLabel = false(size(centroides,1), 1); % Creem una matriu buida del tamany corresponen
    %al nombre de centroides
    
    for ii = 1:size(boxLabel,1)
        
        origen = repmat(boxLabel(ii,1:2), size(centroides,1), 1); % Valors dels punts
        % que delimiten l'origen dels rectangles que etiqueta cada eritrocit de la sessio manual
        
        newCentroides = centroides - origen; % Restem posicio centroides amb origen 
        %per nomes quedarnos amb aquells que el valor de x i y son
        %positius, es a dir que estan continguts al quadrat
        
        cond1 = repmat(boxLabel(ii,3:4), size(centroides,1), 1) - newCentroides;
        % Restem els nous centroides de l'amplada i l'alçada del rectangle
        %que delimita l'eritrocit
        
        % Indica quin es el que es correspost en format logic
        indLabel = indLabel | all( newCentroides > 0 & cond1 > 0 , 2 );
    end
   
    etiquetas(indLabel) = {label}; % Tradueix el valor de indLabel corresponent a la seva etiqueta
 
end        
    
   etiquetas(cellfun(@isempty,etiquetas)) = {'Desconocido'}; % Si no es localitzat
   %significa que no havia estat etiquetat i s'etiqueta com a 'unknown'
   
   datosp = [table(etiquetas), NombreArchivo propietatsmorfo]; % Unim les diferents taules
   % afegint el tipus d'eritrocit i el nom de l'arxiu
   
   datos = [datos; datosp]; % Dades de tota la peticio
   

   %%  
   
   for kk = 1: size(centroides,1)
       
       text(centroides(kk,1), centroides(kk,2), etiquetas{kk});
       
   end