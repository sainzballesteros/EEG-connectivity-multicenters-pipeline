function [mask, plotear, cod0, logevidence_0]=mc3_wG(cp, mask0, cod0, Modelo, Ke, Le, N, logevidence_0, VS, TF);

% Function:
%   Internal "BMA_fMRIG.m" containing the Metropolis-Hastings code which is used for explorin the model
%space. This algorithm is described in [1] and is known as MC3 (Markov Chain Monte Carlo Model Comparison)
%(see too [2] and [3])
%
% Sintaxis:
%   [mask, j, plotear, cod0]=mc3_wG(cp, mask0, cod0, j0, Modelo, Ke, Le, N,logevidence_0);
%
% Inputs:
%   cp:             Data point vector [# sensores x1]
%   mask0:          Grid indices belonging to the initial model
%   cod0:           Vector containing the codes of the anatomical structures for the initial model
%   j0:             Standarized solution (L*j) belonging to the initial model
%   Modelo:         "Struct" Matrix with two fields with the models information(it is generated inside "BMA_fMRI.m")
%   Ke:             Lead Field matrix
%   Le:             Laplacian matrix
%   N:              Markov Chain length
%   logevidence_0:  Logarithm of the evidence for the initial model
%
% Outputs:
%   mask:       Grid indices belonging to the final model
%   j:          DCP mean computed from the MCMC samples
%   plotear:    Logevidence for each MCMC iteration
%   cod0:       Vector containing the codes of the anatomical structures for the final model choosen
%               by the Metropolis-Hastings algorithm
%
% Referencies:
%   [1] Trujillo-Barreto N.J., Palmero-Soler E. and Bornot J.M. (2003) "MC3 for
%       Bayesian Model Averaging in EEG/MEG imaging", to be submitted to Human Brain Mapping.
%   [2] Kass, R. E. and Raftery, A. E. (1994) "Bayes Factors" Technical Report no. 254,
%       Department of Statistics, University of Washington.
%   [3] Hoeting, J. A., Madigan D., Raftery, A. E. and Volinsky C. T. (1999) "Bayesian Model
%       Averaging: A Tutorial", Statistical Science 14 (4), 382-417.
%   [4] Rodriguez-Puentes Y., Trujillo-Barreto N. J., Melie-García L., Martínez-Montes E.,
%       Koenig T., Valdés-Sosa P. A.. Tomografía Eléctrica Cerebral vía BMA, con probabilidades
%       a priori para los modelos, predefinidas a partir del fMRI [Abtract]. CNIC 2005 Book
%       of Abstracts. ISBN: 959-7145-09-X.
%
% Authors: Nelson J. Trujillo Barreto & Yanays Rodríguez Puentes
% Fecha: 26/06/2007

mod=length(Modelo);
plotear=[];
[Ne,Ng]=size(Ke);
prior0=mean([Modelo(cod0).prior]);
prior0=log(prior0);

H1 = waitbar(0,'Warming...','Resize','on','Position',[233.25 237.75 273 50.25],'Resize','off');
for h=1:N,
    try 
      waitbar(h/N,H1);
    catch
    end
    % Pick the simple new model
    y=unidrnd(mod);
    mask1=Modelo(y).puntos;
    mask1=mask1(:);

    if ~isempty(setdiff(mask0,mask1)),
        if (isempty(intersect(mask0,mask1))),
            maskt=union(mask0,mask1);
            cod=union(cod0,y);
        else
            maskt=setdiff(mask0,mask1);
            cod=setdiff(cod0,y);
        end;
    else
        maskt=mask0;
        cod=cod0;
    end;

    prior1=mean([Modelo(cod).prior]);
    prior1=log(prior1);

    if strcmp(VS,'volume')
        [K,L,Ui,si,Vi,mask]=prepmask3(Ke,Le,maskt);
    elseif strcmp(VS,'surface')
        [K,L,Ui,si,Vi,mask]=prepmask(Ke,Le,maskt);
    end

    if strcmp(TF,'time')
        [logevidence_1, j0, lambda]=evidencer(cp,Ui,si,Vi,K);
    elseif strcmp(TF,'frequency')
        [logevidence_1, j0, lambda]=evidencec(cp,Ui,si,Vi,K);
    end


    % Probability of success
    b=exp(logevidence_1-logevidence_0)*exp(prior1-prior0);

    if b>=1,
        mask0=maskt;
        prior0=prior1;
        cod0=cod;
        logevidence_0=logevidence_1;
        plotear=[plotear;logevidence_1+prior1];
    else
        z=rand;
        if z<b,
            mask0=maskt;
            prior0=prior1;
            cod0=cod;
            logevidence_0=logevidence_1;
            plotear=[plotear;logevidence_1+prior1];
        else
            plotear=[plotear;logevidence_0+prior0];
        end;
    end;
end;
mask=mask0;
try
  close(H1)
catch
end
