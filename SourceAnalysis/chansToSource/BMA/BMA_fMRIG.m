function [Jf,y] = BMA_fMRIG(models,mod, KeLe, cp, burning, samples, Options, model0, Save, MET, Ol, VS, TF, format, plotLogposterior)


% Function
%
% This program solves the Inverse Problem of the EEG in the time as well as in the frequency domain
% using the  Bayesian formulation described in [1] (although in this paper only the complex case (frequency
% domain) is described the real case is commented and is completely analogous. In [2] the equivalent to
% the real interpolation case is described). This formulation is based on Bayesian Model Averaging (BMA) ([2],
% [3], [4]) and although in [1] the same prior information is used for every models (anatomical structures or any
% combination of anatomival structures)this program allows to predefine different prior probabilities for each
% model as the probability associated with the significance of the fMRI t-test map for each region. This program
% allows to get inverse solution for the whole volume or for the surface space. The solutions can be achieved using
% the Occam's Window algorithm or the Monte Carlo Markov Chain Model Composition

% Syntax:
%  [Jf, plotearf] = BMA_fMRIG(models,mod, KeLe, cp, warming, samples, Options, model0, Save, MET, Olr, VS, TS);

%
% Inputs:
% models:               "Struct" MATLAB type file (1x#anatomical strutures)called models. It has three fields
%                         1- names:   Contains the names of each structure
%                         2- indices: Contains the indices of the grid points belonging to each anatomical
%                         3- prior:   Contains the probability ascribed to to each single structure and it is an
%                                     average of the t-statistic for each voxel of the structure in an fMRI image.
% mod:                 Group of codes of the single models. It's a vector of non repeated numbers containing the
%                      codes of the single structures to take into account for the Bayessian expectation. The codes
%                      of  the structures depends of the anatomic atlas selected and are contained in an ascii or
%                      txt file accompanying the atlas file.
%KeLe:                 Mat file containing two matrixes:        %JM: Depende de si son 64 o 128
%                            Ke:    Lead Field matrix.
%                            Le:    Laplacian matrix.
%cp:                   Voltage or magnetic field values matrix. Mat File  (# sensors x # times for the time domain or
%                      # sources x # frequencies for the frequency domain.
%warming:              Warming length of the Markov Chain
%samples:              Desired number of samples from the Monte Carlo Markov Chain sampler.
%Options(1):           If is zero, the average refernce is used for the lead field and the data. For any other value
%                      the default reference is used.
%Options(2):           For any nonzero value a graph that visualize the Markov Chain convergence
%                      state is plotted after warming. It gaves you the option to continue warming or start to sampling.
%model0:               Vector of codes of the single models making up the initial model wanted for the MCMC. If this field
%                      is empty the initial model is computed using a  "greedy" algorithm. This guarantees that the Markov
%                      Chain begans with the maximun of the distribution.
%Save                  "Struct" Matlab type file containing two fields:
%                      Path:  Path to save the solutions
%                      Name:  Name to save the solutions
%MET:                  Specifies the method of preference for exploring the models space:
%                        If MET=='OW', the Occam's Window algorithm is used.
%                        If MET=='MC', The MC3 is used.
%Ol:                  Occam's window lower bounds.
%VS:                   Specifies the olution space:
%                        VS=='volume' if is the whole volume
%                        VS=='surface', if is the surface
%TF:                   Specifies the solution domain:
%                        TF=='time', if is the time
%                        TF=='frequency', if is the frequency
%format:               Specifies the solution file extension.
%                      'txt' -> Text. For vectorial solutions (Only for volume)
%                      'eng' -> Text. For modular solutions
%                      'ort' ->Binary. For vectorial solutions (Only for volume)
%                      'mdl'-> Binary For modular solutions
%plotLogposterior       For any nonzero value a graph with the Markov Chain (if MET='MC') or the Occam's Windows algorithm
%                      (if MET='OW')behaviour is plotted
%
%
% Outputs:
%   Jf:         Solution
%   plotearf:   Vector of the logarithm of the posterior values for each iteration of the selected algorithm
%
% References:
%   [1] Trujillo-Barreto N.J., Aubert-Vazquez E. and Valdes-Sosa P.A. (2003) "Bayesian
%       Model Averaging in EEG/MEG imaging", submitted to Neuroimage.
%   [2] MacKay D.J.C. (1992) "Bayesian interpolation", Neural Computation 4 (3), 415-447.
%   [3] Kass, R. E. and Raftery, A. E. (1994) "Bayes Factors" Technical Report no. 254,
%       Department of Statistics, University of Washington.
%   [4] Hoeting, J. A., Madigan D., Raftery, A. E. and Volinsky C. T. (1999) "Bayesian Model
%       Averaging: A Tutorial", Statistical Science 14 (4), 382-417.
%   [5] Rodríguez-Puentes Y., Trujillo-Barreto N. J., Melie-García L., Martínez-Montes E.,
%       Koenig T., Valdés-Sosa P. A.. Tomografía Eléctrica Cerebral vía BMA, con probabilidades
%       a priori para los modelos, predefinidas a partir del fMRI [Abtract]. CNIC 2005 Book
%       of Abstracts. ISBN: 959-7145-09-X.

% Authors: Yanays Rodriguez Puentes & Nelson J. Trujillo Barreto
% Date: 26/06/2007

% clc;
temp=KeLe;

tempnames = fieldnames(temp);
for j=1:length(tempnames),
    dummy = getfield(temp,char(tempnames(j)));
    if issparse(dummy),
        Le=dummy;
    else
        Ke=dummy;
    end;
end;

[Ne,Ng]=size(Ke);
cpsize=size(cp);

if Options(1)==0,
    H=eye(Ne)-ones(Ne)./Ne;
    Ke=H*Ke;
    cp=H*cp;
end;


% There are n_mod simple models under consideration.
n_mod = length(mod);

ind=[];
% Models insertion.
for it = (n_mod:-1:1)
    % "Struct" containing each n_mod modelos.
    Modelo(it).puntos = models(mod(it)).indices;
    Modelo(it).prior = models(mod(it)).prior;
end;

p=[Modelo.prior];
zp=find(p==0);
p(zp)=eps;

for it=n_mod:-1:1
    Modelo(it).prior = p(it);
end;

Jf=[];
for k=1:size(cp,2),
    if strcmp(MET,'MC')
        if isempty(model0),
            disp('Computing the "greedy" initial model ...');
            % Start from an initial "greedy" estimation
            [y, Modelo_muestra, n_muestra] = greedyG(cp(:,k), Ke, Le, Modelo, VS, TF);
            % Initial model for the Monte Carlo
            mask0=[];
            mask0names=find(y(1).elementos);
            for j=1:length(mask0names),
                mask0_t=Modelo(mask0names(j)).puntos;
                mask0=union(mask0,mask0_t);
            end;
            mask0=mask0(:);
            disp('"Greedy" initial model computed...');

        else

            mask0=[];
            for i=1:length(model0),
                maskt=models(model0(i)).indices;
                mask0=union(mask0,maskt);
            end;
            mask0=mask0(:);
            mask0names=model0;
        end;

        if strcmp(VS,'volume')
            [K,L,Ui,si,Vi,mask] = prepmask3(Ke, Le, mask0);
        elseif strcmp(VS,'surface')
            [K,L,Ui,si,Vi,mask] = prepmask(Ke, Le, mask0);
        end

        if strcmp(TF,'time')
            [logevidence_0, jstd_1, lambda]=evidencer(cp(:,k),Ui,si,Vi,K);
        elseif strcmp(TF,'frequency')
            [logevidence_0, jstd_1, lambda]=evidencec(cp(:,k),Ui,si,Vi,K);
        end

        j=zeros(Ng,1);
        j(mask)=jstd_1;

        % Burning
        disp('Warming...')
        [mask, plotear, cod0, logevidence_0]=mc3_wG(cp(:,k), mask0, mask0names, Modelo, Ke, Le, burning, logevidence_0, VS, TF);
        plotearf=plotear;

        if Options(2)~=0,
            h=figure; plot(plotearf)
            title('Markov Chain evolution');
            xlabel('Iteration'); ylabel('Log Posterior');
            cond = menu('Choose the choice','Continue warming and ask','Continue warming and sample','Sampling');
            try
              close(h)
            catch
            end
            while cond==1,
                burning=input('Enter the number of iterations you want: ');
                disp('Warming...')
                [mask, plotear, cod0,logevidence_0]=mc3_wG(cp(:,k), mask, cod0, Modelo, Ke, Le, burning, logevidence_0, VS, TF);
                plotearf=[plotearf;plotear];
                h=figure;  plot(plotearf);
                title('Markov Chain evolution');
                xlabel('Iteration'); ylabel('Log Posterior');
                cond = menu('Choose the choice','Continue warming and ask','Continue warming and sample','Sampling');
                close(h)
            end;
            if cond==2,
                burning=input('Enter the number of iterations you want: ');
                disp('Warming...')
                [mask, plotear, cod0, logevidence_0]=mc3_wG(cp(:,k), mask, cod0, Modelo, Ke, Le, burning, logevidence_0, VS, TF);
                plotearf=[plotearf;plotear];

            end;

        end;

        if plotLogposterior~=0,
            h=figure;plot(plotearf);
            title('Warming Markov Chain evolution');
            xlabel('Iteration');
            ylabel('Log Posterior');
        end
        warmingplotaerf = plotearf; %Mayelin
        % Sampling
        disp('Sampling....')
        %         v=1
        [y,plotearf]=mc3_sG(cp(:,k), mask, cod0,Modelo, Ke, Le, samples, logevidence_0, VS, TF);
        if plotLogposterior~=0,
            h=figure;plot(plotearf);
            title('Sampling Markov Chain evolution');
            xlabel('Iteration');
            ylabel('Log Posterior');
        end
        %Mayelin Begin
        tosave = [warmingplotaerf' plotearf']';
        h=figure;plot(tosave);
        title('Markov Chain Evolution (Warming + Sampling)');
        xlabel('Iteration');
        ylabel('Log Posterior');
        ISFileName=[Save.Path Save.Name];
        ind = strfind(ISFileName,'.');
        ISFileName(ind:end) = [];
        ISFileName = [ISFileName '-MarkovChainEvolution'];
        print (h, '-dbmp', ISFileName);
        %print (gcf, '-dbmp', 'myfile.bmp')
        %saveas(h,ISFileName,'bmp');
        close(h);
        %Mayelin End
        disp(['Computing solution... ' num2str(k)]);
        % Computing the final solution for the sampled models
        [Jmod,Bk0,plotearf] = postmeanjG(cp(:,k), y, Modelo, Ke, Le, VS, TF);
        for it = 1:length(y),
            y(it).posterior=plotearf(it);
        end;

        if plotLogposterior~=0,
            figure;plot(plotearf,'-o');
            title('Posterior probabilities for the accepted models')
            xlabel('Model'); ylabel('Posterior Probability');
        end
%         h=figure;plot(plotearf,'-o');
%         title('Posterior probabilities for the accepted models')
%         xlabel('Model'); ylabel('Posterior Probability');
%         ISFileName=[Save.Path Save.Name];
%         ind = strfind(ISFileName,'.');
%         ISFileName(ind:end) = [];
%         saveas(h,ISFileName,'bmp');
%         if plotLogposterior==0, close(h);end

    elseif strcmp(MET,'OW');
        Ol = -log(Ol);
        Or=0;
        % Occam's Windows
        y = owG(cp(:,k), Modelo, Ke, Le, Or, Ol, VS, TF);
        disp(['Computing solution... ' num2str(k)]);
        % Computing the final solution for the models inside the Occam window
        [Jmod,Bk0,plotearf] = postmeanjG(cp(:,k), y, Modelo, Ke, Le, VS, TF);
        for it = 1:length(y),
            y(it).posterior=plotearf(it);
        end;

        if plotLogposterior~=0,
            figure;plot(plotearf,'-o');
            title('Posterior probabilities for the models inside the Occam''s Window')
            xlabel('Model'); ylabel('Posterior Probability');
        end
    end

    disp(['Saving the output data... ' num2str(k)]);

    if ~isreal(Jmod)
        Jmod=abs(Jmod);
    end

    if strcmp(format,'eng') & strcmp(VS,'volume')
        Jmod=reshape(Jmod,3,Ng/3);
        Jmod=sqrt(sum(Jmod.^2));
        Jmod=Jmod(:);
    end
    ISFileName=[Save.Path Save.Name];
    if strcmp(format,'txt') | strcmp(format,'eng')
        if k==1
            save(ISFileName, 'Jmod', '-ascii');
        else
            save(ISFileName, 'Jmod', '-ascii','-append');
        end
    end

    if strcmp(format,'mdl') & strcmp(VS,'volume')
        Jmod=reshape(Jmod,3,Ng/3);
        Jmod=sqrt(sum(Jmod.^2));
        Jmod=Jmod(:);
    end
    if strcmp(format,'ort') | strcmp(format,'mdl'),
        if k==1
            fid=fopen(ISFileName ,'w')
            fwrite(fid,Jmod,'float32');
            fclose(fid);
        else
            fid = fopen(ISFileName,'a');
            fwrite(fid,Jmod,'float32');
            fclose(fid);
        end;
    end
    eval(['BMA' num2str(k) '=y;']);
    ISFileName=[Save.Path Save.Name];
    ind = strfind(ISFileName,'.');
    ISFileName(ind:end) = [];
    if strcmp(MET,'MC')
        FileNameOutput=[ISFileName '-MC3.mat'];
    elseif strcmp(MET,'OW')
        FileNameOutput=[ISFileName '-OW.mat'];
    end
    if k==1
        save(FileNameOutput, 'BMA1');
    else
        saveVary=['BMA' num2str(k)];
        save(FileNameOutput, saveVary,'-append');
    end
    %%%%%%%%
%     if strcmp(MET,'MC')
%         if ~isreal(E)
%             E=abs(E);
%         end
%         if strcmp(format,'eng') & strcmp(VS,'volume')
%             E=reshape(E,3,Ng/3);
%             E=sqrt(sum(E.^2));
%             E=E(:);
%         end
%         ISFileNameE=[Save.Path 'av' Save.Name];
%         if strcmp(format,'txt') | strcmp(format,'eng')
%             if k==1
%                 save(ISFileNameE, 'E', '-ascii');
%             else
%                 save(ISFileNameE, 'E', '-ascii','-append');
%             end
%         end
% 
%         if strcmp(format,'mdl') & strcmp(VS,'volume')
%             E=reshape(E,3,Ng/3);
%             E=sqrt(sum(E.^2));
%             E=E(:);
%         end
%         if strcmp(format,'ort') | strcmp(format,'mdl'),
%             if k==1
%                 fid=fopen(ISFileNameE ,'w')
%                 fwrite(fid,E,'float32');
%                 fclose(fid);
%             else
%                 fid = fopen(ISFileNameE,'a');
%                 fwrite(fid,E,'float32');
%                 fclose(fid);
%             end;
%         end
%     end
    %%%%%%%%%%%%
end

Jf=Jmod;

display('Done!')

