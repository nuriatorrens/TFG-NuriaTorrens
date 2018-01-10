function bw_final = RBCproces(F)
%% CREEM MASCARA PER ELIMINAR OBJECTES PETITS NO DESITJATS
Fo = F;

lab = rgb2lab(imgaussfilt(Fo,5)); b=lab(:,:,3); %l=lab(:,:,1);a=lab(:,:,2); 

% figure; imshow(l, []);title('"l"');
% figure; imshow(a,[]);title('"a"');
% figure; imshow(b,[]);title('"b"');
 
% figure; histogram(b(:),256); %per veure tots els valors de l'histograma.

Tb = -20;  %L'histograma arriba aprox a -20
sliderBW = b < Tb;
sliderBW = bwareaopen(sliderBW, 1050); % Borra areas mes petites que les plaquetes
%figure; imshow(sliderBW); title('Obectes seleccionats');

%Engrosamiento de les plaquetes (7 vegades) per eliminarles mes facilment
sliderBW = bwmorph(sliderBW, 'thicken', 7); %ha creat una mascara: sliderBW
% figure; imshow(sliderBW); title('Engrosament objectes seleccionats');

%sliderBW = ~sliderBW;

%figure, imshow(sliderBW)

%% FILTREM A PARTIR DE LA COMPONENT VERDA DE LA IMATGE
% Fred=imadjust(F(:,:,1)); figure; imshow(Fred); title('Fred');
% Fblue=imadjust(F(:,:,3)); figure; imshow(Fblue); title('Fblue');


Fgreen=imadjust(F(:,:,2)); %treballem sobre la component verda de la imatge. 
% figure;imshow(Fgreen);title('Component verda F imadjust');

Fgreen = imgaussfilt(Fgreen,5); %filtrem per suavitzar
%figure; imshowpair(F, Fgreen, 'montage'); title('Imatge original vs comp. verda filtrada');

%Mascara del foreground
bw = ~imbinarize(Fgreen); % Umbralitzacio per metode de Otsu, i llavors s'inverteix
%figure; imshow(bw); title('Fgreen binaritzada');
    
%Mascara de les hematies
bw = bw & ~ sliderBW; % Diferencia entre el foreground y les plaquetes
%figure, imshow(bw); title('F green binaritzada + mascara sliderBW');

% figure, imshowpair(Fgreen, bw, 'montage')

%% POSTPROCESSAMENT

%Eliminem els objectes petits seleccionats per la mascara
bw_holes = bwareaopen(bw, 14500); %elimina objectes < 12000 pixels
% figure; imshow(bw_holes);

%eliminem els objectes que toquen els bordes de la imatge
bw_holes = imclearborder(bw_holes); %elimina objectes que toquen les bores
% figure, imshow(bw_holes); title('Eliminar objectes dels bordes');

%operador d'obertura
EE=strel('disk',15,8); % Operador morfologic:  obertura
bw_holes=imopen(bw_holes,EE); %Eliminar ramificacions
% figure; imshow(bw_holes); title('Operador obertura aplicat');

%% APLIQUEM LA FUNCIO WATERSHED

%tapem els forats dels eritrï¿½cits per que sapliqui watershed correctament
bw_noHoles = imfill(bw_holes, 'holes');  
D = -bwdist(~bw_noHoles,'chessboard'); %posem ~ davant per tenir fons blanc i eritrocits negres
% figure, imshow(D,[])

%Marcador per la WT utilitzant la mascara de la regio minima (H-minima) amb h = 4
mask = imextendedmin(D,4);
%figure, imshowpair(bw_noHoles,mask,'blend')

D2 = imimposemin(D,mask); % Imposicio dels marcadors com min
Ld2 = watershed(D2); %WT que separa les cellules

bw1= bw_noHoles;
wlines = bwmorph(Ld2 == 0, 'dilate', 4);
bw1(wlines) = 0;

bw_water = bwareaopen(bw1, 12000); % Elimina objectes < 12000 pixels
%figure, imshow(bw_water); title('Imatge binaritzada');

% figure; imshowpair(bw_holes, bw_water, 'montage'), title('Eritrocits processats')
%figure, imshow(bw_water), impixelinfo


%% SELECCIO HEMATIES I ELIMINACIO DELS QUE NO SON DINTERES

%Extraccio de parametres 
CC1 = bwconncomp(bw_water);
L1 = labelmatrix(CC1);
%figure, imshow(L1, colorcube(CC1.NumObjects)); impixelinfo; title('Colorcube bw water'); %text(294,213,'1');
stats_bwwater = regionprops('table', CC1, 'Centroid', 'Area', 'Eccentricity','FilledArea','EulerNumber');

CC2 = bwconncomp(bw_holes);
L2 = labelmatrix(CC2);
% figure, imshow(L2, colorcube(CC2.NumObjects));impixelinfo; title('colorcube bw_holes')
stats_bwholes = regionprops('table', CC2,'Centroid', 'Area', 'Eccentricity','FilledArea','EulerNumber');
%si calculem stats amb bw_holes trobem eulernumber, si ho fem amb bw_water, al
%haver passat per whatershed, l'eulernumber no ï¿½s veridic, pero les
%altres caracteristiques ho son mï¿½s que per bw_holes.


%indexs de ROIs amb area gran i excentricitat elevada
topSup = 65000; %original es 73000
indSup = (stats_bwwater.Area > topSup) | (stats_bwwater.Eccentricity > 0.75);
%mes grans de 65000 o amb eccentricity>0.75 = generalment no eritrocits

%indexs de ROIs amb area molt gran
% topSup2 = 170000;
% indSup2 = (stats_bwwater.Area > topSup2);
% 

%selecciona les ROIs amb arees mï¿½s petites a 65000 o amb excentricitats inferiors a 0.75
bw2 = bwselect( bw_water, stats_bwwater.Centroid(~indSup,1), stats_bwwater.Centroid(~indSup,2) ); 

% %Selecciode ROIs amb area < topSup2=170000
% bw3 = bwselect( bw2, stats_bwwater.Centroid(~indSup2,1), stats_bwwater.Centroid(~indSup2,2) );

%%%%pq seliminen celules amb arees de 60000??? a bw3 si topsup2 es 170000?????'

%Eliminaciï¿½ d'objectes petits
bw_final = bwareaopen(bw2, 12000);
%figure; imshowpair(bw_water, bw_final, 'montage'); title('Filtrem eritròcits d.interes');


%% Filtratge per circularitat
CC = bwconncomp(bw_final); %troba el numero de objectes a la imatge
propsRBC = regionprops(CC,'Area','Perimeter','Centroid'); %retorna informacio dels objectes detectats en CC
propsRBC = struct2table(propsRBC,'AsArray',true);

%Circularity serï¿½ lultim factor per descartar eritrocits deformats
Circularity = 4*pi*propsRBC{:,'Area'}./propsRBC{:,'Perimeter'}.^2;

%apliquem ultim filtre a bw_final per eliminar troï¿½os deritrocits
topSup3 = 0.75;
indSup3 = (Circularity > topSup3);
bw_final = bwselect( bw_final, propsRBC.Centroid(indSup3,1),...
    propsRBC.Centroid(indSup3,2) ); 
%figure; imshow(bw_final);

%CC = bwconncomp(bw_final);

%% FORMA DE DETECCIO D'ESFEROCITS
%Utilitzem bw_holes i stats_bwholes
% AFilled=(stats_bwholes.FilledArea-stats_bwholes.Area);
% indSup3 = (AFilled < 1);
% 
%podria millorarse afegint com a condicio que eulernumber=1 en bw_holes. el
%problema es que en bw_holes a vegades hi ha mes elements i el numero
%detiqueta no coincideix, ja que no hem eliminat "trossos"

% bw_esferocits=bwselect(bw2,stats_bwholes.Centroid(indSup3,1), stats_bwholes.Centroid(indSup3,2));
%figure; imshowpair(F, bw_esferocits, 'montage'); title('Imatge original vs Imatge esferòcits');
% figure; imshow(bw_holes);title('Binaritzada sense tapar forats');

end