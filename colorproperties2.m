function propietatsmorfo = colorproperties2(bw_final, F, propietatsmorfo)
CC = bwconncomp(bw_final);
Fgreen = F(:,:,2);
Fred = F(:,:,1);
Fblue = F(:,:,3);

%inicialització
mean0 = []; meanR = []; meanB = [];
std0 = []; stdR = []; stdB = [];
var0 = [];
skewness0 = [];
kurtosis0 = [];
entropy0 = []; entropyR = []; entropyB = [];


for j=1:CC.NumObjects
%mean green
meanval0=(CC.PixelIdxList{1,j}); 
Fgval=Fgreen(meanval0);
mean0(j)=mean(Fgval);

%mean red
meanval0=(CC.PixelIdxList{1,j}); 
FgvalR=Fred(meanval0);
meanR(j)=mean(FgvalR);

%mean blue
meanval0=(CC.PixelIdxList{1,j}); 
FgvalB=Fblue(meanval0);
meanB(j)=mean(FgvalB);

%std
rangpixels=(CC.PixelIdxList{1,j}); %estructura1
Fgsval=Fgreen(rangpixels);
std0(j)=std2(Fgsval); %es recullen els valors al workspace a "std0"

%stdRed
rangpixels=(CC.PixelIdxList{1,j}); %estructura1
FgsvalR=Fred(rangpixels);
stdR(j)=std2(FgsvalR); %es recullen els valors al workspace a "stdR"

%stdBlue 
rangpixels=(CC.PixelIdxList{1,j}); %estructura1
FgsvalB=Fblue(rangpixels);
stdB(j)=std2(FgsvalB); %es recullen els valors al workspace a "stdB"

%variance
var0(j) = var(CC.PixelIdxList{1,j});

%skewness
skewness0(j) = skewness(CC.PixelIdxList{1,j}); %es recullen els valors a "skewness0" 

%kurtosis
kurtosis0(j) = kurtosis (CC.PixelIdxList{1,j}); %es recullen els valors a "kurtosis0"

%entropy green
rangpixels=(CC.PixelIdxList{1,j}); 
Fgval=Fgreen(rangpixels);
entropy0(j)=entropy(Fgval);

%entropy Red
rangpixels=(CC.PixelIdxList{1,j}); 
FgvalR=Fred(rangpixels);
entropyR(j)=entropy(FgvalR);

%entropy Blue
rangpixels=(CC.PixelIdxList{1,j}); 
FgvalB=Fblue(rangpixels);
entropyB(j)=entropy(FgvalB);
end


%% ENERGY (to get the energy in an image you have to sum up all the gray levels.)

%1)
% totalEnergy = sum(Fgreen(:)); %dona 1.7442e+11
% 
% %2)
% zeroPixelLocations = (Fgreen == 0); % Find all zeros.
% Fgreen(zeroPixelLocations ) = 1; % Set to 1 instead of 0.
% h = imhist(Fgreen, 256);
% h = h / numel(Fgreen); % a must be grayscale if you use numel.
% E = sum(h(:)) %dona 1

% F = fft2(Fgreen);
% magImage = abs(F).^2;
% energy = sum(magImage(:)) % dona 4.3225e+22


%% TABLE
param3 = table(mean0',meanR',meanB',std0',stdR',stdB',var0',skewness0',kurtosis0',entropy0',entropyR',entropyB'); %falta totalenergy
param3.Properties.VariableNames = {'Mean_Green','Mean_Red','Mean_Blue','Std_Green','Std_Red','Std_Blue','Variance','Skewness','Kurtosis','Entropy_G','Entropy_R','Entropy_B'}; %afegir 'totalenergy'

propietatsmorfo = [propietatsmorfo param3];
%open propietatsmorfo

data=propietatsmorfo(:,3:end);
data_matrix=table2array(data);

% %% KMEANS CLUSTERING
% idx = kmeans(data_matrix,2); %clustering de data_matrix en 3 grups diferents
% idx_table=array2table(idx);
% data3=[idx_table,data]; %table amb idx i les propietats

%%

% Como colocar etiqueta en la imagen
%figure; imshow(F);
% for j =1:height(data3)
%     
%     text(propietatsmorfo.Centroid(j,1),propietatsmorfo.Centroid(j,2), num2str(data3.idx(j)), 'FontSize' , 18,  'Color',  'r')
% end

%% Relacionar etiquetatge amb bounding box?
% figure; imshow(F)
% hold on
% plot(propietatsmorfo.BoundingBox(:,1),propietatsmorfo.BoundingBox(:,2), 'b*')
% hold off
% 
% for j = 1 : height(propietatsmorfo)
%   BB = propietatsmorfo(j).BoundingBox;
%   rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],...
%   'EdgeColor','r','LineWidth',2 )
% end

end