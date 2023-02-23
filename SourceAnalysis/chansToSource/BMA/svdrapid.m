% Esta funcion realiza una descomposicion rapida de una
% matriz, en valores singulares.
%
% Sintaxis:
%           [U,d,V]=svdrapid(A);
%           [m,n]=size(A), m << n
% Nota: Si alguno de los autovalores d son cero, lo que hay en las columnas de V es cascara.
%       d sale ordenado de mayor a menor.
function [U,d,V]=svdrapid(A);

[U,D] = eig(A*A');
d=diag(D);
ind=find(d <= eps*max(d));
d(ind)=zeros(size(ind));
d=sqrt(abs(d));
[d,i]=sort(d);
d=flipud(d(:));
i=flipud(i(:));
U=U(:,i);
ind=find(d > eps*max(d));
invd=zeros(size(d));
invd(ind)=1./d(ind);
V=A'*U; % V es VD
V=V*diag(invd);
