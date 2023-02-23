function [K3,L3,Ui,si,Vi,Mask3]=prepmask3(K,L,Mask);

% Esta es una subrutina del "BMA_fMRI.M" que aplica una máscara al Lead
% Field y al Laplaceano para restringir la activación a determinadas estructuras
% cuya información viene contenida en la máscara.
%
% Sintaxis:
%   [K,L3,Ui,si,Vi,Mask3]=prepmask(K,L3,Mask);
%
% Entrada:
%   K:     Matriz de Lead Field.
%   L:     Matriz Laplaceano. 
%   Mask:  Matriz que contiene los índices en el Grid de las estructuras.
%          donde se genera actividad eléctrica y que se utiliza para crear una máscara.
%
% Salida:
%   K3, L3:          Lead Field estandarizado y Laplaceano luego de aplicarles la máscara.
%   [Ui,si,Vi]:      Desomposición en valores singulares de K3 según la subrutina "svdrapid.m".
%   Mask3:           Máscara.               
%
% Autor: Nelson J. Trujillo Barreto & Yanays Rodríguez Puentes
% Fecha: 5/12/2005     

Mask=Mask(:).';
Mask3 = [3*Mask-2; 3*Mask-1;3*Mask];
Mask3 = Mask3(:);

N3g=length(Mask3);
K = K(:,Mask3);
L3 = L(Mask3,Mask3);
[Nd,N3g]=size(K);
K3(:,1:3:N3g) = K(:,1:3:N3g)/L3(1:3:N3g,1:3:N3g);
K3(:,2:3:N3g) = K(:,2:3:N3g)/L3(2:3:N3g,2:3:N3g);
K3(:,3:3:N3g) = K(:,3:3:N3g)/L3(3:3:N3g,3:3:N3g);

[Ui,si,Vi]=svdrapid(K3);

