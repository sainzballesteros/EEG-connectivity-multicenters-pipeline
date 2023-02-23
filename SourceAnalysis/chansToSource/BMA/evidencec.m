function [LogP,nu,lambda,nuL, alpha, beta, lambdaL]=evidencec(cp,Ui,si,Vi,K);

% Funtion:
%  This routine uses the evidence framework for estimating a Bayesian
%  LORETA solution in the frequency domain. The outgoing solution is
%  standarized (because this improve the computing time for the MC3 which
%  call this subroutine several times).
%
% Sintaxis:
%   [LogP,nu,lambda,nuL, alpha, beta, lambdaL]=evidencer(cp,Ui,si,Vi,K);
%
% Input:
%   cp:         Data point vector [# electrodos X 1]
%   Ui, si, Vi: Singular value decomposition for the standarized Lead field (usv(K/L))
%   K:          Standarized Lead field
%
% Outputs:
%   LogP:    Logarithm of the evidence for the analized model (log(P(v|H)))
%   nu:      Standarized solution (j=L*j) for the analized model
%   lambda:  Regularization parameter squared, estimated via Bayes
%   nuL:     LORETA solution for the analized model, using a regularization parameter estimated
%            by generalized corssvalidation
%   alpha:   Precision of the spatial smoothness prior
%   beta:    Precission of the observation noise
%   lambdaL: Regularization (smoothness) parameter of the LORETA solution
%
% Author: Nelson J. Trujillo Barreto
% Date: 15/04/2008

Nseg=size(cp,2);
[Nd,Ns]=size(K);

%LORETA initial solution and initial lambda estimated by crosvalidation
Ns=Ns./3;
[nu, lambdaL] = invregc(Ui,si,Vi,cp);
nuL = nu;
lambda=lambdaL.^2;

%Re-estimation process
nuw = zeros(size(nu));
diff=1;
c=1;

alphat=[];
betat=[];
gammat=[];
lambdat=[];
LogP(1) = 0;

Enu = real(norm(nu,'fro')).^2;
Ed = real(norm(cp-K*nu,'fro')).^2;
beta = (Nd-1)./Ed;
alpha = lambda*beta;
while diff(length(diff))>=eps & c<=100,,

   c=c+1;
    % Second Bayesian inference level: Hyperparameters estimation
    % Likelihood and a apriori variances ((beta) and (alpha) respectively) calculations
    % For alpha
    
    diff1 = 10;
    cc=1;
    while diff1>=eps & cc<=100,
        gamma = (Nd - alpha*sum(ones(size(si))./(beta*si.^2 + alpha)));
        alphan = gamma/Enu;
        % For beta
        betan=(Nd-gamma)/Ed;

        diff1 = sqrt(([alphan;betan]-[alpha;beta])'*([alphan;betan]-[alpha;beta])./([alpha;beta]'*[alpha;beta]));
        %diff1 = norm([alphan;betan]-[alpha;beta],'fro')./norm([alpha;beta],'fro');
        alpha = alphan;
        beta = betan;
        cc = cc + 1;
    end;
    
    lambda = alpha/(beta);
    
    % First Bayesian inference level: Parameters estimation (solution)
    nu   = invregc(Ui,si,Vi,cp,[],sqrt(lambda));
    %diff = real(norm(nu-nuw,'fro')) %./real(norm(nu,'fro'));
    
    %lambda = alpha/(beta);
    nuw     = nu;

%     alphat=[alphat alpha];
%     betat=[betat beta];
%     gammat=[gammat gamma];
%     lambdat=[lambdat lambda];

     Enu = real(norm(nu,'fro')).^2;
     Ed = real(norm(cp-K*nu,'fro')).^2;
     M = real(beta*Ed + alpha*Enu);
     constL = (1-Nd)*log(pi) + Nd*log(beta) + Ns*log(alpha) - log(gamma*(Nd-gamma))./2;
     detA   = sum(log(beta*si.^2 + alpha)) + (Ns-Nd)*log(alpha);
     LogP(c) = constL - M - detA;
     diff = real(norm(LogP(c)-LogP(c-1),'fro')); %./real(norm(nu,'fro'));

end;

% M= real(beta*Ed + alpha*Enu);
% constL = (1-Nd)*log(pi) + Nd*log(beta) + Ns*log(alpha) - log(gamma*(Nd-gamma))./2;
% detA   = sum(log(beta*si.^2 + alpha)) + (Ns-Nd)*log(alpha);
% LogP = constL - M - detA;

LogP = LogP(end);
% 
% 
