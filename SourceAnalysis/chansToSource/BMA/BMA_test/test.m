%% variables que cambian por rutas
models = load('models_surface_aal(6000).MAT');
models = models.models;
mod = 1:size(models,2);

KeLeorig = load('EEG_Sur_5656_62_22_11.mat');
KeLe.Ke = KeLeorig.Ke;
KeLe.Le = KeLeorig.Le;

pt = load('Vtodo.mat');
fn=fieldnames(pt);
%cp =pt.cp20;
eval(['cp=pt.' fn{1} ';']);

%% parametros de configuración
burning = 4000;
samples = 3000;

Save.Path = pwd;
Save.Name = 'test.txt'
MET = 'MC'; % MET = 'OW';
OWL=3;%3(Very Strong), 20(strong), 150(positive), 200 (Weak)
VS = 'surface'; % 'volume'
TF = 'time';
format = 'txt';
Plot = 0;

%fijos (por ahora)
Options(1) = 0;
Options(2) = 0;
model0 = [];

[Jmod, plotearf] = BMA_fMRIG(models, mod, KeLe, cp, burning, samples, Options, model0, Save, MET, OWL, VS, TF,format, 0);% models = load('D:\Servicios Neuroinformatica\models_volumen_aal(Cortex+BG4x4x4).MAT');

