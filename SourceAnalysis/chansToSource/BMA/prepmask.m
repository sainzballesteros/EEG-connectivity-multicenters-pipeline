function [K,L,Ui,si,Vi,Mask]=prepmask(K,L,Mask);

% Esta es una subrutina del "BMA_fMRI.M" que aplica una máscara al Lead
% Field y al Laplaceano para restringir la activación a determinadas estructuras
% cuya información viene contenida en la máscara.
%
% Sintaxis:
%   [K,L,Ui,si,Vi,Mask]=prepmask(K,L,Mask);
%
% Entrada:
%   K:     Matriz de Lead Field.
%   L:     Matriz Laplaceano. 
%   Mask:  Matriz que contiene los índices en el Grid de las estructuras.
%          donde se genera actividad eléctrica y que se utiliza para crear una máscara.
%
% Salida:
%   K, L:          Lead Field estandarizado y Laplaceano luego de aplicarles la máscara.
%   [Ui,si,Vi]:    Desomposición en valores singulares de K3 según la subrutina "svdrapid.m".
%   Mask:          Máscara.               
%
% Autor: Nelson J. Trujillo Barreto & Yanays Rodríguez Puentes
% Fecha: 5/12/2005     

Mask=Mask(:).';

K = K(:,Mask);
L = L(Mask,Mask);
K= K/L;

[Ui,si,Vi]=svdrapid(K);

