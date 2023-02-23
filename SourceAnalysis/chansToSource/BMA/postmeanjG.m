function [Jpost,Bk0,Pk] = postmeanjG(cp, y, models, Ke, Le, VS, TF);

% Funcion:
%
%   Esta subrutina calcula la esperanza a posteriori basada en 
%   el conjunto de modelos que quedaron dentro de la ventana de
%   Occam
%
% Sintaxis:
%
%   [jpost,Bk0,Pk] = postmeanj(cp, y, models, Ke, Le);
%
% Entrada:
%
%   cp:         Matriz de datos de tamanno [Numero de electrodos X Numero de Instantes 
%               de Tiempo]
%   y:          Variable de tipo struct, que contiene los modelos que quedaron dentro de la
%               ventana de Occam, asi como el valor de la logevidencia para cada uno
%   models:     Variable tipo struct, que contiene dos campos con informacion sobre
%               los modelos que se analizan. Esta variable debe corresponderse con "y"
%   Ke:         Matriz del Lead Field
%   Le:         Matriz del Laplaciano
%
% Salida:
%
%   Jpost:      Esperanza a posteriori de la densidad de corriente.
%   Bk0:        Factores de Bayes para los modelos que quedaron dentro de la
%               ventana de Occam, escogiendo el modelo de mas evidencia como
%               la hipotesis nula
%   Pk:         Probabilidades a posteriori de los modelos que quedaron dentro
%               de la ventana de Occam
%
% Autor: Nelson J. Trujillo Barreto
% Fecha: 2/06/2003

Ng=size(Ke,2);
Nmod=length(y);
% Calculo de las probabilidades a posteriori de los modelos
logPk=[];
logak=[];
for j=1:Nmod,
    logPk = [logPk;y(j).logevidence];
    logak = [logak;y(j).logprior];
end;
m=find(logPk==max(logPk));
m=m(1);
Bk0=exp(logPk-max(logPk));
ak0=exp(logak-logak(m));
Pk=ak0.*Bk0./sum(ak0.*Bk0);

% Calculo de la media de j a posteriori
Jpost=zeros(Ng,1);

H = waitbar(0,'Computing the final solution...','Resize','on','Position',[233.25 237.75 273 50.25],'Resize','off');
for i=1:Nmod,
    try
      waitbar(i/Nmod,H);
    catch
    end
    maskcode=y(i).codes;
    mask=[];
    for j=1:length(maskcode),
        maskt=models(maskcode(j)).puntos;
        mask=union(mask,maskt(:));
    end;
    
    if strcmp(VS,'volume')
        [K,L,Ui,si,Vi,mask]=prepmask3(Ke,Le,mask);
        Ngi=length(mask);
    elseif strcmp(VS,'surface')
        [K,L,Ui,si,Vi,mask]=prepmask(Ke,Le,mask);
    end
    
    jstd_t=zeros(Ng,1);
    
    if strcmp(TF,'time')
        [logE, jstd_k, lambda]=evidencer(cp,Ui,si,Vi,K);
    elseif strcmp(TF,'frequency')
        [logE, jstd_k, lambda]=evidencec(cp,Ui,si,Vi,K);
    end
    
    if strcmp(VS,'volume')
        jstd_t(mask(1:3:Ngi),1)=L(1:3:Ngi,1:3:Ngi)\jstd_k(1:3:Ngi);
        jstd_t(mask(2:3:Ngi),1)=L(2:3:Ngi,2:3:Ngi)\jstd_k(2:3:Ngi);
        jstd_t(mask(3:3:Ngi),1)=L(3:3:Ngi,3:3:Ngi)\jstd_k(3:3:Ngi);
    elseif strcmp(VS,'surface')
        jstd_t(mask)=L\jstd_k;
    end
    
    Jpost=Jpost+Pk(i)*jstd_t;
    
end;
try
close(H);
catch
end