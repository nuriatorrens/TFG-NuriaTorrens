%%%%%%%%%%%% MAIN SCRIPT %%%%%%%%%%%%%%%%%%

clc,clear, close all

%% Lectura de la imatge

% baseN = 'C:\Users\Torrents\Documents\Universitat\TFG\imatges_prova\';
% base1N = '\013162639564-122116_adquirida';

base = '/media/micro/Images/BX43Images/Dropbox/FROTIS/RBC';
% dirImage = 'C:\Users\Torrents\Documents\Universitat\TFG\Esferocitosi'; %dir on hi ha les carpetes de cada frotis
dirImage = fullfile(base, 'Esferocitosis'); %Ruta Workstation


carpetas1 = dir( fullfile(dirImage));
carpetas1 = {carpetas1.name};
carpetas1 = carpetas1(3:end);

datos = table(); % Creem una taula buida que s'anira omplint

for t = [3 9]%1:length(carpetas1)
    
    folder = carpetas1{t};
    
    % Loading (Cargar) la peticio: posar 013 davant al guardar la sessio
    %guardarla a la carpeta hello-tfg
    
%     load( [ 'C:\Users\Torrents\Documents\GitHub\hello-tfg\Sessions_etiquetatje\imageLabelingSession_', folder ,'.mat' ] );
    load( fullfile(dirImage, folder, 'JPG', 'imageLabelingSession.mat' ) )
    
    archivos = dir( fullfile( dirImage, folder, '*.tif') );
    archivos = {archivos.name};
    
    %taulaEtiqueta = imageLabelingSession.getLabelTable; % Matlab Clara
    taulaEtiqueta = imageLabelingSession.ROIAnnotations.export2table([]); % MatlabR2017b
    imageFilename = getarchivo(imageLabelingSession.ImageFilenames);
    taulaEtiqueta = [ table(imageFilename), taulaEtiqueta];
    
    
    
    % k = 1;
    for  k = 1:3 %length(archivos)
        
        file = archivos{k};      
      
        F = imread( fullfile(dirImage,folder, file) );
        
        % Conversi� de 12 a 16 bits en cas necessari
        if max(F(:)) <= 4096
            F = F*uint16( (2^16-1)/(2^12-1)  );
        end
        % figure, imshow(F)
        
        %% Processat i segmentaci�
        
        bw_final = RBCproces(F); %Algoritme segmentaci�
        
        %% Propietats morfologia
        
        propietatsmorfo =  propietatsmorfologia(bw_final);
        NombreArchivo = cell2table(repmat(taulaEtiqueta.imageFilename(k), ...
            height(propietatsmorfo),1), 'VariableNames', {'imageFile'});
        
        %% Altres propietats
        
        propietatsmorfo = colorproperties2(bw_final, F, propietatsmorfo);
        
        %% Relaci� etiquetetes
        
        datos = Relacioetiquetes(taulaEtiqueta,propietatsmorfo,k,NombreArchivo,datos);
        
        %% Alternativa para relacionar etiquetas usando datos_final
         strcmp(datos_final.imageFile, file)
        
        % pause
        
    end
end
open datos


function out = getarchivo(x)
% sep = '\'; %Windows
sep = '/'; %Linux

%x = imageLabelingSession.ImageFilenames;
h=length(x);
out=cell(h,1);

for k = 1:h 
    a= strsplit(x{1}, sep);
    out(k) = a(end);  
end
end