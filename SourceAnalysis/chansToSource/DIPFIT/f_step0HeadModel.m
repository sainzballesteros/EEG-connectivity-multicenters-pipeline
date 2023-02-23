function f_step0HeadModel(oriEEG)

%% FieldTrip
EEG=pop_chanedit(oriEEG, 'lookup','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');
EEG = eeg_checkset( EEG );

%Calculates the co-registration using a standard MRI model
EEG = pop_dipfit_settings( EEG, 'hdmfile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_mri.mat','chanfile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0 0 0 0 0 -1.5708 1 1 1] ,'chansel',[1:EEG.nbchan] );
EEG = eeg_checkset( EEG );

%% Surface Source estimation
%Transforms data from EEGLab to FieldTrip
dataPre = eeglab2fieldtrip(EEG, 'preprocessing', 'dipfit');   % convert the EEG data structure to fieldtrip

%Basic pre-processing (should already be pre-processed tho)
cfg = [];
cfg.channel = {'all'};
cfg.reref = 'yes';
cfg.refchannel = {'all'};
dataPre = ft_preprocessing(cfg, dataPre);

dataAvg = dataPre;


%Prepare leadfield surface
[ftVer, ftPath] = ft_version;

%Original sourcemodel had 8196 points (too much memory)
sourcemodel = ft_read_headshape(fullfile(ftPath, 'template', 'sourcemodel', 'cortex_8196.surf.gii'));
%Decided to use 5124 points instead
%sourcemodel = ft_read_headshape(fullfile(ftPath, 'template', 'sourcemodel', 'cortex_5124.surf.gii'));

vol = load('-mat', EEG.dipfit.hdmfile);

cfg           = [];
cfg.grid      = sourcemodel;    % source points
cfg.headmodel = vol.vol;        % volume conduction model
leadfield = ft_prepare_leadfield(cfg, dataAvg);

%% Surface source analysis
%Uses covariance of trials prior to source estimation
%cfg                  = [];
%cfg.covariance       = 'yes';
%cfg.covariancewindow = [EEG.xmin 0]; % calculate the average of the covariance matrices
                                   % for each trial (but using the pre-event baseline  data only)
%dataAvg = ft_timelockanalysis(cfg, dataPre);

%% Source analysis using MNE
cfg               = [];
cfg.method        = 'mne';
cfg.grid          = leadfield;
cfg.headmodel     = vol.vol;
cfg.mne.prewhiten = 'yes';
cfg.mne.lambda    = 3;
cfg.mne.scalesourcecov = 'yes';
source            = ft_sourceanalysis(cfg, dataAvg);

%% Source analysis using eLoreta
cfg               = [];
cfg.method        = 'eloreta';
cfg.grid          = leadfield;
cfg.headmodel     = vol.vol;
source            = ft_sourceanalysis(cfg, dataAvg);

%% Source quantification
%source.avg has the data of interest
%source.avg.pow seems to have Frequency power NOT time data [nSourcePoints, nTimePoints]
%source.avg.mom is a cell of {1, nSourcePoints} with the momentum orientation of each surface point [3, nTimePoints]

nSourcePoints = length(source.avg.mom);
modSource = nan(nSourcePoints, oriEEG.pnts);
sourceMomEstim = 'length';     %'largest' or 'length'

for i = 1:nSourcePoints
    iMom = source.avg.mom{i};
    
    if isempty(iMom)
        fprintf('WARNING: Could not reconstruct to a source level at the time point number %d\n', i);
        continue
    end
    
    if strcmp(sourceMomEstim, 'largest')
    
        %According to a mailing list of 2011 (https://mailman.science.ru.nl/pipermail/fieldtrip/2011-August/030064.html)
        %A way to quantify is taking the direction that explains most of the source variance. 
        %That is equivalent to taking the largest eigenvector of the source timeseries 
        %(which is a phrasing that is often used in papers, also on combining fMRI bold timeseries over multiple voxels).

        [u, s, v] = svd(iMom, 'econ'); 
        modSource(i, :) = v(:,1);

        %But it seems to have a sign ambiguity

    elseif strcmp(sourceMomEstim, 'length')
        %Alternatively, one can take the strength over all three directions for each timepoint.
        modSource(i,:) = sqrt(sum(iMom.^2,1));
    end
end

%Convert them to single to save some memory
modSource = single(modSource);

%% Plot to visualize the results
%m=source.avg.pow(:,1);
m = modSource(:,1);
ft_plot_mesh(source, 'vertexcolor', m);
view([0 0]); h = light; set(h, 'position', [0 1 0.2]); lighting gouraud; material dull
colorbar, colormap jet %caxis([0 0.035])%([-1, 1].*10^-6)

%%
%% Leadfield Matrix calculation - volume
dataPre = eeglab2fieldtrip(EEG, 'preprocessing', 'dipfit');   % convert the EEG data structure to fieldtrip

cfg = [];
cfg.channel = {'all'};
cfg.reref = 'yes';
cfg.refchannel = {'all'};
dataPre = ft_preprocessing(cfg, dataPre);

vol = load('-mat', EEG.dipfit.hdmfile);

cfg            = [];
cfg.elec       = dataPre.elec;
cfg.headmodel  = vol.vol;
cfg.resolution = 10;   % use a 3-D grid with a 1 cm resolution
cfg.unit       = 'mm';
cfg.channel    = { 'all' };
[sourcemodel] = ft_prepare_leadfield(cfg);

%Compute an ERP in Fieldtrip. Note that the covariance matrix needs to be calculated here for use in source estimation.
cfg                  = [];
cfg.covariance       = 'yes';
cfg.covariancewindow = [EEG.xmin EEG.xmax]; % calculate the average of the covariance matrices
                                   % for each trial (but using the pre-event baseline  data only)
dataAvg = ft_timelockanalysis(cfg, dataPre);

% source reconstruction
cfg             = [];
cfg.method      = 'eloreta';
cfg.sourcemodel = sourcemodel;
cfg.headmodel   = vol.vol;
source          = ft_sourceanalysis(cfg, dataAvg);  % compute the source model

%% Transforms the electrodes to MNI coordinates
%Transforms the electrodes to MNI coordinates
EEG=pop_chanedit(oriEEG, 'lookup','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');
EEG = eeg_checkset( EEG );

%Calculates the co-registration using a standard MRI model
EEG = pop_dipfit_settings( EEG, 'hdmfile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_mri.mat','chanfile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0 0 0 0 0 -1.5708 1 1 1] ,'chansel',[1:EEG.nbchan] );
EEG = eeg_checkset( EEG );

%Automatically performs the coarse-grained grid
EEG = pop_multifit(EEG, 1:size(EEG.icawinv,2) ,'threshold',100,'dipplot','on','plotopt',{'normlen','on'});
EEG = eeg_checkset( EEG );
%Save figure
%


%% A mano de acá para abajo
%Transforms the electrodes to MNI coordinates
EEG=pop_chanedit(oriEEG, 'lookup','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');
EEG = eeg_checkset( EEG );

%Calculates the co-registration using a standard MRI model
EEG = pop_dipfit_settings( EEG, 'hdmfile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_mri.mat','chanfile','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0 0 0 0 0 -1.5708 1 1 1] ,'chansel',[1:EEG.nbchan] );
EEG = eeg_checkset( EEG );

%Initial fitting - Scanning on a coarse-grained grid
EEG = pop_dipfit_gridsearch(EEG, size(EEG.icawinv,2) ,[-85     -77.6087     -70.2174     -62.8261     -55.4348     -48.0435     -40.6522     -33.2609     -25.8696     -18.4783      -11.087     -3.69565      3.69565       11.087      18.4783      25.8696      33.2609      40.6522      48.0435      55.4348      62.8261      70.2174      77.6087           85] ,[-85     -77.6087     -70.2174     -62.8261     -55.4348     -48.0435     -40.6522     -33.2609     -25.8696     -18.4783      -11.087     -3.69565      3.69565       11.087      18.4783      25.8696      33.2609      40.6522      48.0435      55.4348      62.8261      70.2174      77.6087           85] ,[0      7.72727      15.4545      23.1818      30.9091      38.6364      46.3636      54.0909      61.8182      69.5455      77.2727           85] ,0.4);
EEG = eeg_checkset( EEG );

%Plots the dipole locations in 3D
% find localized dipoles
locDipoles = [];
for index2 = 1:length(EEG.dipfit.model)
    if ~isempty(EEG.dipfit.model(index2).posxyz) ~= 0
        locDipoles = [ locDipoles index2 ];
        EEG.dipfit.model(index2).component = index2;
    end
end
pop_dipplot( EEG, locDipoles ,'mri','F:\\Mati\\Paradigmas\\SocialRejection\\Eeglab\\eeglab2020_0\\plugins\\dipfit\\standard_BEM\\standard_mri.mat','normlen','on');
%NOTE: Meterle un save a la fig?

%

%% Tries to look for standard locations in MNI coordinates
%Defines the channel data
flag_replurchan = 0;
dataset_input = 1;
chans         = EEG(1).chanlocs;
nchansori     = EEG.nbchan;
if isfield(EEG, 'chaninfo')
    chaninfo = EEG(1).chaninfo;
else
    chaninfo = [];
end
if isfield(EEG, 'urchanlocs')
    urchans = EEG(1).urchanlocs;
end
% insert "no data channels" in channel structure
% ----------------------------------------------
nbchan = length(chans);
[tmp chaninfo chans] = eeg_checkchanlocs(chans, chaninfo);


GUI = false;

standardchans = { 'Fp1' 'Fpz' 'Fp2' 'Nz' 'AF9' 'AF7' 'AF3' 'AFz' 'AF4' 'AF8' 'AF10' 'F9' 'F7' 'F5' ...
    'F3' 'F1' 'Fz' 'F2' 'F4' 'F6' 'F8' 'F10' 'FT9' 'FT7' 'FC5' 'FC3' 'FC1' 'FCz' 'FC2' ...
    'FC4' 'FC6' 'FT8' 'FT10' 'T9' 'T7' 'C5' 'C3' 'C1' 'Cz' 'C2' 'C4' 'C6' 'T8' 'T10' ...
    'TP9' 'TP7' 'CP5' 'CP3' 'CP1' 'CPz' 'CP2' 'CP4' 'CP6' 'TP8' 'TP10' 'P9' 'P7' 'P5' ...
    'P3' 'P1' 'Pz' 'P2' 'P4' 'P6' 'P8' 'P10' 'PO9' 'PO7' 'PO3' 'POz' 'PO4' 'PO8' 'PO10' ...
    'O1' 'Oz' 'O2' 'O9' 'O10' 'CB1' 'CB2' 'Iz' };
for indexchan = 1:length(chans)
    if isempty(chans(indexchan).labels), chans(indexchan).labels = ''; end
end
[tmp1 ind1 ind2] = intersect_bc( lower(standardchans), {chans.labels});
if ~isempty(tmp1) || isfield(chans, 'theta')

    % finding template location files
    % -------------------------------
    setmodel = [ 'tmpdat = get(gcbf, ''userdata'');' ...
        'tmpval = get(gcbo, ''value'');' ...
        'set(findobj(gcbf, ''tag'', ''elec''), ''string'', tmpdat{tmpval});' ...
        'clear tmpval tmpdat;' ];
    try
        EEG = eeg_emptyset; % for dipfitdefs
        dipfitdefs;
        userdatatmp = { template_models(1).chanfile template_models(2).chanfile 'Standard-10-5-Cap385_witheog.elp' }; % last file in the path (see eeglab.m)
        clear EEG;
    catch, userdatatmp = { 'Standard-10-5-Cap385.sfp' 'Standard-10-5-Cap385.sfp' 'Standard-10-5-Cap385_witheog.elp' }; % files are in the path (see eeglab.m)
    end

    % other commands for help/load
    % ----------------------------
    comhelp = [ 'warndlg2(strvcat(''The template file depends on the model'',' ...
        '''you intend to use for dipole fitting. The default file is fine for'',' ...
        '''spherical model.'');' ];
    commandload = [ '[filename, filepath] = uigetfile(''*'', ''Select a text file'');' ...
        'if filename ~=0,' ...
        '   set(findobj(''parent'', gcbf, ''tag'', ''elec''), ''string'', [ filepath filename ]);' ...
        'end;' ...
        'clear filename filepath tagtest;' ];
    if ~isfield(chans, 'theta'),                    message =1;
    elseif all(cellfun('isempty', {chans.theta })), message =1;
    else                                            message =2;
    end
    if message == 1
        textcomment = strvcat('Only channel labels are present currently, but some of these labels have known', ...
            'positions. Do you want to look up coordinates for these channels using the electrode', ...
            'file below? If you have a channel location file for this dataset, press cancel, then', ...
            'use button "Read location" in the following gui. If you do not know, just press OK.');
    else
        textcomment = strvcat('Some channel labels may have known locations.', ...
            'Do you want to look up coordinates for these channels using the electrode', ...
            'file below? If you do not know, press OK.');
    end
    
    if GUI
        uilist = { { 'style' 'text' 'string' textcomment } ...
            { 'style' 'popupmenu'  'string' [ 'use BESA file for 4-shell dipfit spherical model' ...
            '|use MNI coordinate file for BEM dipfit model|Use spherical file with eye channels' ] ...
            'callback' setmodel } ...
            { } ...
            { 'style' 'edit'       'string' userdatatmp{1} 'tag' 'elec' } ...
            { 'style' 'pushbutton' 'string' '...' 'callback' commandload } ...
            { } };
    %                             { 'Style', 'checkbox', 'value', 0, 'string','Overwrite Original Channels' } };

        res = inputgui( { 1 [1 0.3] [1 0.3] 1 }, uilist, 'pophelp(''pop_chanedit'')', 'Look up channel locations?', userdatatmp, 'normal', [4 1 1 1] );
    else
        %JM: Definition to avoid the GUI pop-up. 2 means that it will use MNI space
        res = {2, userdatatmp{2}};
        args = {};      %args is equal to varargin, which is none in this case
        curfield = 1;   %curfield is used to iterate over args, but in this case it's only one
        
    end
    
    if ~isempty(res)
        chaninfo.filename = res{2};
        args{ curfield   } = 'lookup';
        args{ curfield+1 } = res{2};
        com = args;
    else
        return;
    end
end

%Executes the code called when 'lookup' is defined
if strcmpi(chaninfo.filename, 'standard-10-5-cap385.elp')
    dipfitdefs;
    chaninfo.filename = template_models(1).chanfile;
elseif strcmpi(chaninfo.filename, 'standard_1005.elc')
    dipfitdefs;
    chaninfo.filename = template_models(2).chanfile;
end
tmplocs = readlocs( chaninfo.filename, 'defaultelp', 'BESA' );                
for indexchan = 1:length(chans)
    if isempty(chans(indexchan).labels), chans(indexchan).labels = ''; end
end
[tmp ind1 ind2] = intersect_bc(lower({ tmplocs.labels }), lower({ chans.labels }));
if ~isempty(tmp)
    chans = struct('labels', { chans.labels }, 'datachan', { chans.datachan }, 'type', { chans.type });
    [ind2 ind3] = sort(ind2);
    ind1 = ind1(ind3);

    for index = 1:length(ind2)
        chans(ind2(index)).theta      = tmplocs(ind1(index)).theta;
        chans(ind2(index)).radius     = tmplocs(ind1(index)).radius;
        chans(ind2(index)).X          = tmplocs(ind1(index)).X;
        chans(ind2(index)).Y          = tmplocs(ind1(index)).Y;
        chans(ind2(index)).Z          = tmplocs(ind1(index)).Z;
        chans(ind2(index)).sph_theta  = tmplocs(ind1(index)).sph_theta;
        chans(ind2(index)).sph_phi    = tmplocs(ind1(index)).sph_phi;
        chans(ind2(index)).sph_radius = tmplocs(ind1(index)).sph_radius;
    end
    tmpdiff = setdiff_bc([1:length(chans)], ind2);
    if ~isempty(tmpdiff)
        fprintf('Channel lookup: no location for ');
        for index = 1:(length(tmpdiff)-1)
            fprintf('%s,', chans(tmpdiff(index)).labels);
        end
        fprintf('%s\nSend us standard location for your channels at eeglab@sccn.ucsd.edu\n', ...
            chans(tmpdiff(end)).labels);
    end
    if ~isfield(chans, 'type'), chans(1).type = []; end
end
if ~isempty(findstr(args{ curfield+1 }, 'standard_10')) && ...
        ~isempty(findstr(args{ curfield+1 }, '.elc'))
    chaninfo.nosedir = '+Y';
else
    chaninfo.nosedir = '+X';
end
if flag_replurchan, urchans = eeg_checkchanlocs(chans, chaninfo); end
for index = 1:length(chans)
    chans(index).urchan    = index;
    chans(index).ref       = '';
end

%% Checks that the channel selection was performed correctly
[chans chaninfo] = eeg_checkchanlocs(chans, chaninfo);
if dataset_input,
     if nchansori == length(chans)
         for index = 1:length(EEG)
             EEG(index).chanlocs = chans;
             EEG(index).chaninfo = chaninfo;
         end
         % Updating urchanlocs            
         if flag_replurchan && ~isempty(urchans), EEG.urchanlocs = urchans; end
         EEG = eeg_checkset(EEG); % for channel orientation
     else
         disp('Channel structure size not consistent with the data so changes will be ignored');
         disp('Use the function pop_select(EEG, ''nochannel'', [x]); if you wish the remove data channels');
     end
     try chansout = EEG; catch, end
else chansout = chans;
end