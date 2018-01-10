function propietatsmorfo = propietatsmorfologia(bw_final)

% CC = bwconncomp(bw_final); %troba el numero de objectes a la imatge
% % figure, imshow(L_RBC,[]),title('Eritrocits')

propietats0 = {'Area','Centroid', 'ConvexArea', 'ConvexImage', ...
    'Eccentricity', 'Solidity', 'MajorAxisLength','MinorAxisLength', ...
    'Perimeter', 'Extent','BoundingBox'};

%% PROPIETATS

CC = bwconncomp(bw_final);

L_RBC = labelmatrix(CC); %crea matriu dels objectes conectats que ha trobat
%figure; imshow(bw_final); title('Elements d.on extreiem les caracterï¿½stiques');

%en cas que selimini algun tros deritrocit, propietatsmorfo i CC es modifiquen 
%i redueixen el numero delements als que ens interessen. 


propsRBC = regionprops(CC,propietats0); %retorna informacio dels objectes detectats en CC
propsRBC = struct2table(propsRBC,'AsArray',true);

% Roundness (Circulos->1)
Circularity = 4*pi*propsRBC{:,'Area'}./propsRBC{:,'Perimeter'}.^2;

%Simetrics->0, llargs->1
Elongation = 1-propsRBC{:,'MinorAxisLength'}./propsRBC{:,'MajorAxisLength'};

%Calcul area i Perimetre per cada ConvexHull
Iconvex = propsRBC{:,'ConvexImage'};

%Inicialitzacio
AreaConvex = zeros(CC.NumObjects,1);
PerimeterConvex = AreaConvex;
circleVariance = zeros(CC.NumObjects,1);
ellipVariance = zeros(CC.NumObjects,1);

for j=1:CC.NumObjects
    
    propConvex = regionprops(Iconvex{j},'Perimeter');
    
    % AreaConvex(j) = propConvex.Area;
    PerimeterConvex(j) = propConvex.Perimeter;
  
    %Circle Variances and Elliptical Variances
    g = propsRBC{j,'Centroid'};
    bw_mask = L_RBC ==j; %Mascara particular
    
    
    [circleVariance(j), ellipVariance(j) ] = cirEllipVar(g,bw_mask);

    
end

roundnessCH = 4*pi*propsRBC{:,'Area'}./PerimeterConvex.^2;

convexity = PerimeterConvex./propsRBC{:,'Perimeter'};


%% Extracció de dades

param1=propsRBC(:,{'Centroid','BoundingBox','Area','Eccentricity','Solidity','Extent',...
    'Perimeter','MajorAxisLength','MinorAxisLength'});

param2 = table(Circularity,Elongation,roundnessCH, convexity, ... 
    circleVariance, ellipVariance);

propietatsmorfo = [param1 param2];

open propietatsmorfo


%%
function [circleVariance, ellipVariance ] = cirEllipVar(g,bw_final)
% Input: g: Centroide de cada uno de los objetos en la mascara bw_final
%       bw_final: mascara binaria
%
%  Output:
%       CircleVariance: Varianza circular 
%       ellipVariance: Varianza eliptica 
  
    b1 = bwboundaries(bw_final);
    b1 = b1{1}; %Bordes (row,col)
    b1 = fliplr(b1); %Bordes (x,y) 
    
    b1G = b1 - repmat(g,length(b1),1); % (x-gx, y-gy)
    d = sqrt(sum(b1G.^2,2)); %Distancias de cada punto del borde al centroide
    
    circleVariance = std(d)/mean(d);
    
     %All the pixel from the Complete region
%     b1R = propsCel{k,'PixelList'}; %(x,y)
%     b1R = b1R{1};
%     b1RG = b1R - repmat(g,length(b1R),1); % (x-gx, y-gy)
%     %Matriz de covarianza (momentos de inercia) de toda la region
%     Cxx = mean(b1RG(:,1).^2)+1/12;
%     Cyy = mean(b1RG(:,2).^2)+1/12;
%     Cxy = mean(prod(b1RG,2));
%     C = [Cxx Cxy; Cxy Cyy];        
    
%     %Matriz de covarianza solo de la frontera
    Cxx = mean(b1G(:,1).^2);
    Cyy = mean(b1G(:,2).^2);
    Cxy = mean(prod(b1G,2));
    C = [Cxx Cxy; Cxy Cyy];
    
    %Elliptical distances
    ed = sqrt( dot( b1/C, b1, 2 ) );
    ellipVariance = std(ed)/mean(ed);
end
end