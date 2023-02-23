function [X, lambda, Glambda] = invregc(U,s,V,Y,autom_lambda,lambda);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X = invreg(U,s,V,Y,lambda);
% finds optimal regularization parameter lambda 
%
%      lambda =   arg min G(l)= || P(l) Y ||^2 ./ Trace(n P(l))^2 
%
% for using in Tikhonov regularization
%
%         min { || A x - Y ||^2 + lambda^2 ||L x ||^2 } (function tikh), 
%
% where        
%
%      P(l) = I-A inv(A' A+l^2 I) A'
%
% and
%
%      A = U diag(s) V' by compact SVD (csvd). 
%
% 
% Input arguments:
%
%   U          - left orthognal matrix from SVD of A
%   s          - column vector of singular values of A
%   V          - right orthognal matrix from SVD of A (if only the first r columns of V are passed
%              - then only the first r components of x are calculated)
%   Y          - data matrix
%   lambda     - regularization parameter when it is input (Then it is not calculated)
%
% Output arguments:
%
%   lambda  - optimal regularization parameter
%   X       - solution when Oper is input else it is the regularization operator. 
%   Glambda - G(lambda) Note when this parameter is present a plot of
%             the GCV curve is created
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%# scalar autom_lambda lambda n m p npoints smin_ratio No_Ok ratio rho2 tmp np Glambda minGi

[n,m]=size(Y);
p=length(s);
onesm=ones(1,m);
s2=s.^2;
UtY = U'*Y; 

if nargin < 6
 % Set defaults.
  npoints = 100;                  % Number of points on the curve.
  smin_ratio = 16*eps;           % Smallest regularization parameter.
 % Initialization. 

  No_Ok = 1;
  reg_param = zeros(npoints,1); G = reg_param;
  leftbound = -1;
  while No_Ok
    reg_param(npoints) = max([s(p),s(1)*smin_ratio,leftbound]);
    ratio = 1.2*(s(1)./reg_param(npoints)).^(1/(npoints-1));
    for i=npoints-1:-1:1, reg_param(i) = ratio*reg_param(i+1); end
    for i=1:npoints
      tmp = reg_param(i) * reg_param(i);
      f1 = tmp ./ (s2 + tmp);
      fb = (f1*onesm).*UtY;
      rho2 = fb(:)'*fb(:);
      tmp = sum(f1);
      tmp = tmp * tmp;
      G(i) = rho2 / tmp;
    end 

    [mGlambda, mminGi] = min(G);
    Glambda = mGlambda(1);
    minGi = mminGi(1);
    lmin = minloc(G);
    np = length(lmin);
    if np == 1, minGi = lmin;
    elseif lmin(length(lmin)) == npoints, minGi = lmin(np-1); end
    Glambda = G(minGi);
    lambda= reg_param(minGi);
    
    %if not autom_lambda
      %Mostrar ventana con Tres opciones:
      % - Aceptar
      % - Cambiar el limite inferior y recalcular
      % - Cambiar el lambda a mano
      % Si escogio Aceptar o Lambda a mano, poner No_Ok = 0;
    %end  
    No_Ok = 0;
  end 

%  mbrealscalar(npoints);
%  mbrealvector(reg_param); mbrealvector(G); mbrealvector(rho2);
%  mbreal(f1); mbrealvector(ratio);
else
  Glambda = -1;
end %end de u

% si se desea solucion inversa
X=V*(((s./(s2+lambda.^2))* onesm).*UtY);

%mbrealvector(Glambda);
%mbreal(U); mbreal(s); mbreal(V);
%mbrealscalar(autom_lambda);

return;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

function lmin = minloc(x);

%#realonly
%#inbounds
%# scalar i l

lmin = [];
if size(x,1) == 1, x = x'; end
if size(x,2) ~= 1, return; end

ll = size(x,1);  l = ll(1);
if x(1) < x(2), lmin = 1; end
for i = 2:l-1
    if (x(i-1) > x(i)) & (x(i) < x(i+1)), lmin = [lmin; i]; end
end
if x(l-1) > x(l), lmin = [lmin; l]; end
if isempty(lmin), [kk, lmin]=min(x); end

return;

