function [K,L,Ui,si,Vi,Mask]=prepmask(K,L,Mask);

% Esta es una subrutina del "BMA_fMRI.M" que aplica una m�scara al Lead
% Field y al Laplaceano para restringir la activaci�n a determinadas estructuras
% cuya informaci�n viene contenida en la m�scara.
%
% Sintaxis:
%   [K,L,Ui,si,Vi,Mask]=prepmask(K,L,Mask);
%
% Entrada:
%   K:     Matriz de Lead Field.
%   L:     Matriz Laplaceano. 
%   Mask:  Matriz que contiene los �ndices en el Grid de las estructuras.
%          donde se genera actividad el�ctrica y que se utiliza para crear una m�scara.
%
% Salida:
%   K, L:          Lead Field estandarizado y Laplaceano luego de aplicarles la m�scara.
%   [Ui,si,Vi]:    Desomposici�n en valores singulares de K3 seg�n la subrutina "svdrapid.m".
%   Mask:          M�scara.               
%
% Autor: Nelson J. Trujillo Barreto & Yanays Rodr�guez Puentes
% Fecha: 5/12/2005     

Mask=Mask(:).';

K = K(:,Mask);
L = L(Mask,Mask);
K= K/L;

[Ui,si,Vi]=svdrapid(K);

