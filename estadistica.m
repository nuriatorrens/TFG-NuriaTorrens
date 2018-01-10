%_____________________ESTAD�STICA_______________________

esferocito=[];
drepanocits=[];
normal=[]
datos.etiquetas = categorical(datos.etiquetas);
esferocito = datos(datos.etiquetas == 'Esferocito' ,:);
drepanocits = datos(datos.etiquetas == 'Drepanocits' ,:);
normal = datos(datos.etiquetas == 'Normal' ,:);

%% Seleccio de dades
variable = table(drepanocits.Eccentricity, esferocito.Eccentricity, normal.Eccentricity);
variable.Properties.VariableNames = {'Drepanocits','Esferocits', 'Normal'};
variable1=table2array(variable);


%% Boxplot
figure;
boxplot(variable1,'Labels',{'Drepanocits','Esferocits','Normals'}); title('Eccentricitat');
xlabel('Tipus de c�l�lula'); ylabel('Valors del descriptor');

%% PERCENTIL
YE = prctile(esferocito.Area,[25 50 75],1)
YD = prctile(drepanocits.Area,[25 50 75],1)
YN = prctile(normal.Area,[25 50 75],1)


%% Multicomparation

%Kruskal-wallis compara les medianes de cada grup per determinar si les
%mostres provenen de la mateixa poblaci� (o de poblacions diferents amb la
%mateixa distribuci�)
%MEDIANA: ordenar de menor a major i �s el punt del mig
%retorna p-value 

 
for jj =3:width(datos)
%[p,~,stats] = anova1(datos.Elongation,datos.etiquetas,'off'); %nomes per distribucions normals
[p,tbl,stats] = kruskalwallis(datos{:,jj},datos.etiquetas); %millor per distribucions no-normals
[results,means] = multcompare(stats,'CType','tukey-kramer'); %representa les
%means obtingudes a [stats]
pause

nombres = {'ind1', 'ind2', 'BajoConf', 'mediana_aprox', 'AltoConf', 'p'};

tipos = categories(datos.etiquetas);
class1 = tipos(results(:,1));
class2 = tipos(results(:,2));
results_table = [ table(class1), table(class2), ...
    array2table(results(:,3:end), 'VariableNames', {'BajoConf', 'mediana_aprox', 'AltoConf', 'p'} ) ]
end


%obrir [results] per veure comparacions
%grup1: drepanocits, grup 2:esferocits , grup 3: normal
%com posar nom als grups a la comparasion window?


%% Test homoscedastisity
%detecta que hi ha 3 tipus de categories

for jj = 18 %3:width(datos)
vartestn(datos{:,jj}, datos.etiquetas) %obtenim p=0,Barlett's statics 235.448
%pause
end

figure; histfit(datos.Std_Green)

%s'obt� boxplot, mitjana i std de la variable analitzada per a cada tipus
%d'eritr�ctis. Tamb� obtenim Barlett's statics, graus de llibertat i p-value.

%NULL HIPOTESIS: les columnes venen de distribucions normals amb la mateixa
%vari�ncia en totes
%p=0: com a m�nim una columna te una vari�ncia diferents
%p=1: totes tenen la mateixa variancia


%% Test normalitat
%NULL HIPOTESIS: dades dels vectors formen una distribuci� normal
%h=1: rebutja hipotesi NULL al valor de significan�a del 5% -->No distr.Normal
%h=0: no es pot dir que no formen distribuci� Normal

%representar histograma
figure; hist(esferocito.Area,30)%histograma de 30 barres

%test Chi-square goodness-of-fit test
%h = chi2gof(esferocito.Area) %mateix que eq de sota. Retorna menys dades
for jj=3:width(normal)
[h,p,stats] = chi2gof(normal{:,jj}) %(alpha al 5% default) %h=1, p=1.9749e-8, 
pause
end

figure; histfit(esferocito.MajorAxisLength);
title('Eix de major longitud');
%stats con chi2stat: 38.7352, df:2, edges, O, E.
