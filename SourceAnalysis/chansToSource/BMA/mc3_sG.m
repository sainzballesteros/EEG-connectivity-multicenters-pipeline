function [Model_C,plotear]=mc3_sG(cp, mask0, cod0, Modelo, Ke, Le, N, logevidence_0, VS, TF);

% Function:
%   Internal "BMA_fMRIG.m" containing the Metropolis-Hastings code which is used for explorin the model
%space. This algorithm is described in [1] and is known as MC3 (Markov Chain Monte Carlo Model Comparison)
%(see too [2] and [3])
%
% Sintaxis:
%   [mask, E, plotear, cod0]=mc3_sG(cp, mask0, cod0, j0, Modelo, Ke, Le, N,logevidence_0);
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
%   E:          DCP mean computed from the MCMC samples
%   plotear:    Logevidence for each MCMC iteration
%   cod0:       Vector containing the codes of the anatomical structures for the final model choosen
%               by the Metropolis-Hastings algorithm
% References:
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
% Authora: Nelson J. Trujillo Barreto & Yanays Rodriguez Puentes
% Date: 25/06/2007

mod=length(Modelo);
plotear=[];
[Ne,Ng]=size(Ke);
prior0=mean([Modelo(cod0).prior]);
prior0=log(prior0);

mask0=mask0(:).';
% E=zeros(Ng,1);
% j=zeros(Ng,1);

Model_A(1).logevidence=logevidence_0;
Model_A(1).codes=cod0;
Model_A(1).logprior=prior0;

if strcmp(VS,'volume')
    [K,L,Ui,si,Vi,mask]=prepmask3(Ke,Le,mask0);
elseif strcmp(VS,'surface')
    [K,L,Ui,si,Vi,mask]=prepmask(Ke,Le,mask0);
end

if strcmp(TF,'time')
    [loge, j0, lambda]=evidencer(cp,Ui,si,Vi,K);
elseif strcmp(TF,'frequency')
    [loge, j0, lambda]=evidencec(cp,Ui,si,Vi,K);
end

if strcmp(VS,'volume')
    mask=[3*mask0-2; 3*mask0-1; 3*mask0];
    mask=mask(:);
%     Ngi=length(mask);
%     j(mask(1:3:Ngi))=Le(mask(1:3:Ngi),mask(1:3:Ngi))\j0(1:3:Ngi);
%     j(mask(2:3:Ngi))=Le(mask(2:3:Ngi),mask(2:3:Ngi))\j0(2:3:Ngi);
%     j(mask(3:3:Ngi))=Le(mask(3:3:Ngi),mask(3:3:Ngi))\j0(3:3:Ngi);
% elseif strcmp(VS,'surface')
%     j(mask0)=Le(mask0,mask0)\j0;
end


n_A=0;

empt=[];
H = waitbar(0,'Sampling...','Resize','on','Position',[233.25 237.75 273 50.25],'Resize','off');
for h=1:N,
    try
     waitbar(h/N,H);
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
    % end
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


    Ngi=length(mask);

    % Probability of success
    b=exp(logevidence_1-logevidence_0)*exp(prior1-prior0);

    if b>=1,
        mask0=maskt;
        prior0=prior1;
        cod0=cod;
        logevidence_0=logevidence_1;
%         j=zeros(Ng,1);
%         if strcmp(VS,'volume')
%             j(mask(1:3:Ngi))=L(1:3:Ngi,1:3:Ngi)\j0(1:3:Ngi);
%             j(mask(2:3:Ngi))=L(2:3:Ngi,2:3:Ngi)\j0(2:3:Ngi);
%             j(mask(3:3:Ngi))=L(3:3:Ngi,3:3:Ngi)\j0(3:3:Ngi);
%         elseif strcmp(VS,'surface')
%             j(mask0)=L\j0;
%         end
%         E=E+j;
        Model_A(length(Model_A)+1).logevidence=logevidence_1;
        Model_A(length(Model_A)).codes=cod;
        Model_A(length(Model_A)).logprior=prior1;
        plotear=[plotear;logevidence_1+prior1];
    else
        z=rand;
        if z<b,
            mask0=maskt;
            prior0=prior1;
            cod0=cod;
            logevidence_0=logevidence_1;
%             j=zeros(Ng,1);
%             if strcmp(VS,'volume')
%                 j(mask(1:3:Ngi))=L(1:3:Ngi,1:3:Ngi)\j0(1:3:Ngi);
%                 j(mask(2:3:Ngi))=L(2:3:Ngi,2:3:Ngi)\j0(2:3:Ngi);
%                 j(mask(3:3:Ngi))=L(3:3:Ngi,3:3:Ngi)\j0(3:3:Ngi);
%             elseif strcmp(VS,'surface')
%                 j(mask0)=L\j0;
%             end
%             E=E+j;
            Model_A(length(Model_A)+1).logevidence=logevidence_1;
            Model_A(length(Model_A)).codes=cod;
            Model_A(length(Model_A)).logprior=prior1;
            plotear=[plotear;logevidence_1+prior1];
        else
%             E=E+j;
            plotear=[plotear;logevidence_0+prior0];
        end;
    end;
end;

% E=E./N;
try
  close(H)
catch
end

Model_C = Model_A(1);
n_A=length(Model_A);
[ord,pos]=sort([Model_A.logevidence]+[Model_A.logprior],2,'descend');
for (it_A = 1:n_A)
    if it_A==1
        Model_C(1) = Model_A(pos(it_A));
    elseif (~isempty(setdiff(Model_A(pos(it_A)).codes, Model_C(length(Model_C)).codes))) | (~isempty(setdiff(Model_C(length(Model_C)).codes,Model_A(pos(it_A)).codes)))
        Model_C(length(Model_C)+1) = Model_A(pos(it_A));
    end
end
clear Model_A;