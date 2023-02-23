function y = owG(cp, Modelo, Ke, Le, Orn, Oln, VS, TF);

% Funcion:
%
%   Esta funcion tiene implementado el algoritmo Ventanas de Occam
%   descrito en ([1]), para el caso real (tiempo). Esta es una
%   subrutina que se llama desde el programa "BMA_OWr.M". El algoritmo
%   parte de un conjunto de modelos iniciales que se calcula usando 
%   un algoritmo "greedy" (gloton)
%
% Sintaxis:
%
%   y = owr(mod, cp, models, Ke, Le, Or, Ol);
%
% Entrada:
%
%   cp:         Matriz de datos de tamanno [Numero de electrodos X Numero de Instantes 
%               de Tiempo]
%   Modelo:     Matriz tipo struct, que contiene dos campos con informacion sobre
%               los modelos que se analizan (se genera dentro del "BMA_OWr.M")
%   Ke:         Matriz del Lead Field
%   Le:         Matriz del Laplaciano
%   Ol:         Limite inferior de la ventana de Occam (en unidades de logEvidencia)
%   Or:         Limite superior de la ventana de Occam (en unidades de logEvidencia)
%
% Salida:
%
%   y:          Variable de tipo struct que contiene informacion sobre los modelos
%               que quedaron dentro de la ventana de Occam, asi como el valor de
%               la logevidencia de cada uno
%
% Referencias:
%
%   [1] Madigan, D. and Raftery, A. (1994). Model selection and accounting for model
%       uncertainty in graphical models using Occam's window. Journal of the American 
%       Statistical Association, 89, 1535-1546.
%
% Autores: Jose Miguel Bornot
%          Nelson J. Trujillo Barreto
% Fecha: 23/06/2003

global Modelos_A Modelos_C n_muestraA n_muestraC mejor_logevidence Ol Or
Ol = Oln;
Or = Orn;

% Existen n_mod modelos.
n_mod = length(Modelo);

% Partir de una estimacion inicial.
[y, Modelo_muestra, n_muestra] = greedyG(cp, Ke, Le, Modelo, VS, TF, 10);

for i=1:n_muestra
    cod=find(Modelo_muestra(i).elementos);
    Modelo_muestra(i).codes=cod;
end
Modelo_muestra=rmfield(Modelo_muestra,'elementos');

% Aplicacion del Algoritmo UP-DOWN de ventanas de Occam.
mejor_logevidence = Modelo_muestra(1).logevidence;
%fMRI
prior0=Modelo_muestra(1).logprior;
%
for (it = 1:n_muestra)
    Modelos_C(it).codes= Modelo_muestra(it).codes;
    Modelos_C(it).logevidence = Modelo_muestra(it).logevidence;
%fMRI
    Modelos_C(it).logprior = Modelo_muestra(it).logprior;
end;
n_muestraC = n_muestra;

Modelos_A = Modelos_C(1);
n_muestraA = 0 ;

% Aplicacion de la fase DOWN del Algoritmo.
% Analizar cada uno de los modelos de Modelos_C.
it_mod = 1;
while (it_mod <= n_muestraC)   
    disp(' ');
    disp(' '); 
    disp(['DOWN: Run ' num2str(it_mod) ' of ' num2str(n_muestraC)]); 
    %mejor_logevidence
    
    % M es el modelo que se analiza.
    Modelo_M = Modelos_C(it_mod);
   %fMRI
    prior1=Modelo_M.logprior;
    %
    if (Modelo_M.logevidence+prior1-mejor_logevidence-prior0 < Ol)
        % No tiene sentido evaluar los submodelos de M puesto que este no
        % se encuentra en la ventana de occam.
        % Tampoco tiene sentido insertarlo en A.
        
        % Se iterara sobre el proximo modelo.
        it_mod = it_mod+1;
        continue;
    end
    
    codes_M = Modelo_M.codes;
    % Obtencion de los puntos de la mascara pertenecientes al Modelo M.
    puntos_M = [];
    for (it_elem = 1:length(codes_M))
        puntos_M = union(puntos_M, [Modelo(codes_M(it_elem)).puntos]);
    end
    
    % Se asume que el model M no se descarta.
    flag5 = 0;
    
    % Paso 3. Analizar cada uno de los subconjuntos inmediatos Mo de M.
    for (it_elem = 1:length(codes_M))
        codes_Mo = setdiff(codes_M, codes_M(it_elem));
        
        if (isempty(codes_Mo))
            % Mo es vacio, lo qeu significa que M es de cardinalidad
            % minima. No tiene submodelos y por tanto, ningun submodelo
            % lo supera. Se insertara directamente en A.
            break;
        end
        
        % Obtencion de los puntos de la mascara pertenecientes al Modelo Mo.
        puntos_Mo = setdiff(puntos_M, Modelo(codes_M(it_elem)).puntos);
        % Calculo del logevidence del modelo Mo.
        if strcmp(VS,'volume')
            [K,L,Ui,si,Vi,mask] = prepmask3(Ke, Le, puntos_Mo);
        elseif strcmp(VS,'surface')
            [K,L,Ui,si,Vi,mask] = prepmask(Ke, Le, puntos_Mo);
        end

        if strcmp(TF,'time')
            logevidence_Mo = evidencer(cp,Ui,si,Vi,K);
        elseif strcmp(TF,'frequency')
            logevidence_Mo = evidencec(cp,Ui,si,Vi,K);
        end

        prior1 = mean([Modelo(codes_Mo).prior]);
        prior1=log(prior1);%fMRI
        
        if (logevidence_Mo+prior1 > mejor_logevidence+prior0) %fMRI
            mejor_logevidence = logevidence_Mo;
            prior0=prior1;
        end
        
        % Se asume que el elementos Mi no se va a insertar.
        insertar = 0;
        
        % Paso 4. Calculo del nivel de calidad de Mo con respecto a M.
        B = logevidence_Mo+prior1-Modelo_M.logevidence-Modelo_M.logprior; %fMRI
        
        % paso 5. Mo es mejor que M, siendo mas simple?
        if (B > Or)
            % Se descarta el modelo M. O sea no se incluye en
            % Modelos_A.
            flag5 = 1;
            
            insertar = 1;
        end
        
        % paso 6. Mo es aceptable con respecto a M?
        if (B >= Ol & B <= Or)
            insertar = 1;
        end
        
        if (logevidence_Mo+prior1-mejor_logevidence-prior0 > Ol) %fMRI
            % Si Mo no esta contemplado en Modelos_C, incluirlo.
            if ((insertar == 1) & (pertenece(codes_Mo, Modelos_C) == 0))
                % hay un elemento mas
                n_muestraC = n_muestraC+1;
                Modelos_C(n_muestraC).codes = codes_Mo;
                Modelos_C(n_muestraC).logevidence = logevidence_Mo;
           %fMRI
                Modelos_C(n_muestraC).logprior = prior1;
            end
        end
    end
    
    % Si no se cumplio la regla establecida en el paso 5 del algoritmo.
    % O sea, si ningun submodelo Mo de M es superior a M. Entonces,
    % insertar a M.
    if (flag5 == 0)
        n_muestraA = n_muestraA+1;
        Modelos_A(n_muestraA) = Modelo_M;
    end
    
    % Se iterara sobre el proximo modelo.
    it_mod = it_mod+1;
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[Modelos_C, n_muestraC] = limpiar_A2C;

% Aplicacion de la fase UP del Algoritmo.
% n_muestraC = n_muestraA;
% n_muestraA = 0;
% Modelos_C = Modelos_A;

disp(' ');
disp(' ');
disp(['There are ' num2str(n_muestraC) ' models']);  
disp('LogPosterior Models');

for ind = 1:n_muestraC,
    disp([Modelos_C(ind).logevidence+Modelos_C(ind).logprior Modelos_C(ind).codes]);
end


% Analizar cada uno de los modelos de Modelos_C.
it_mod = 1;
while (it_mod <= n_muestraC)
    disp(' ');
    disp(' '); 
    disp(['UP: Run ' num2str(it_mod) ' of ' num2str(n_muestraC)]);  
%     mejor_logevidence
    
    % M es el modelo que se analiza.
    Modelo_M = Modelos_C(it_mod);
    if (Modelo_M.logevidence+Modelo_M.logprior-mejor_logevidence-prior0 < Ol) %fMRI
        % No tiene sentido evaluar los supermodelos de M puesto que este no
        % se encuentra en la ventana de occam.
        % Tampoco tiene sentido insertarlo en A.
        
        % Se iterara sobre el proximo modelo.
        it_mod = it_mod+1;
        continue;
    end
        
    codes_M = Modelo_M.codes;
    no_codes_M = setdiff(1:n_mod, codes_M);
    % Obtencion de los puntos de la mascara pertenecientes al Modelo M.
    puntos_M = [];
    for (it_elem = 1:length(codes_M))
        puntos_M = union(puntos_M, Modelo(codes_M(it_elem)).puntos);
    end
    
    % Se asume que el model M no se descarta.
    flag5 = 0;
    % Paso 3. Analizar cada uno de los superconjuntos inmediatos Mi de M.
    for (it_elem = 1:length(no_codes_M))
        codes_Mi = union(codes_M, no_codes_M(it_elem));
        
        if (isempty(no_codes_M))
            % M es UNIVERSO, lo qeu significa que M es de cardinalidad
            % maxima. No tiene supermodelos y por tanto, ningun supermodelo
            % lo supera. Se insertara directamente en A.
            break;
        end
        
        % Obtencion de los puntos de la mascara pertenecientes al Modelo Mi.
        puntos_Mi = union(puntos_M, Modelo(no_codes_M(it_elem)).puntos);
        priori = mean([Modelo(codes_Mi).prior]);
        priori=log(priori);%fMRI
        % Calculo del logevidence del modelo Mo.
        if strcmp(VS,'volume')
            [K,L,Ui,si,Vi,mask] = prepmask3(Ke, Le, puntos_Mi);
        elseif strcmp(VS,'surface')
            [K,L,Ui,si,Vi,mask] = prepmask(Ke, Le, puntos_Mi);
        end

        if strcmp(TF,'time')
            logevidence_Mi = evidencer(cp,Ui,si,Vi,K);
        elseif strcmp(TF,'frequency')
            logevidence_Mi = evidencec(cp,Ui,si,Vi,K);
        end

        if (logevidence_Mi+priori > mejor_logevidence+prior0) %fMRI
            mejor_logevidence = logevidence_Mi;
            prior0=priori; %fMRI
        end

        % Se asume que el elementos Mi no se va a insertar.
        insertar = 0;
        
        % Paso 4. Calculo del nivel de calidad de Mo con respecto a M.
        B = Modelo_M.logevidence+Modelo_M.logprior-logevidence_Mi-priori; %fMRI
        
        % paso 5. M no es aceptable con respecto a Mi?
        if (B < Ol)
            % Se descarta el modelo M. O sea no se incluye en
            % Modelos_A.
            flag5 = 1;
            
            insertar = 1;
        end
        
        % paso 6. Mi es aceptable con respecto a M?
        if (B >= Ol & B <= Or)
            insertar = 1;
        end
                
        if (logevidence_Mi+priori-mejor_logevidence-prior0 > Ol)%fMRI
            % Si Mo no esta contemplado en Modelos_C, incluirlo.
            if ((insertar == 1) & (pertenece(codes_Mi, Modelos_C) == 0))
                % hay un elemento mas
                n_muestraC = n_muestraC+1;
                Modelos_C(n_muestraC).codes = codes_Mi;
                Modelos_C(n_muestraC).logevidence = logevidence_Mi;
            %fMRI
                Modelos_C(n_muestraC).logprior = priori;
            end
        end
    end
    
    % Si no se cumplio la regla establecida en el paso 5 del algoritmo.
    % O sea, si ningun supermodelo Mi de M es superior a M. Entonces,
    % insertar a M.
    if (flag5 == 0)
        n_muestraA = n_muestraA+1;
        Modelos_A(n_muestraA) = Modelo_M;
    end
    
    % Se iterara sobre el proximo modelo.
    it_mod = it_mod+1;
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[Modelos_C, n_muestraC] = limpiar_A2C;

disp(' ');
disp(' ');
disp(['There are ' num2str(n_muestraC) ' models']);   
disp('LogPosterior Models');

for ind = 1:n_muestraC,
    disp([Modelos_C(ind).logevidence+Modelos_C(ind).logevidence Modelos_C(ind).codes]);
end

y = Modelos_C;

return;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [Modelos_C, n_muestraC] = limpiar_A2C
% Esta funcion lo que hace es copiar los modelos que estan en para C,
% eliminando de A aquellos que no satisfacen occam window.

global Modelos_A Modelos_C n_muestraA n_muestraC mejor_logevidence Ol Or prior0  %fMRI

% Inicialmente todos los modelos en A son contemplados.
contemplado = ones(1, n_muestraA);
for (it_Ai = 1:n_muestraA)
    % Se analiza si el modelo es valido o no.
    if (contemplado(it_Ai) == 1)  
        % Modelo analizado M.
        Modelo_M = Modelos_A(it_Ai);
                if (Modelo_M.logevidence+Modelo_M.logprior-mejor_logevidence-prior0 < Ol) %fMRI
            % El modelo no se contempla puesto que no pertenece a la
            % ventana de occam.
            contemplado(it_Ai) = 0;
        else
            codes_M = Modelo_M.codes;
            for (it_Aj = it_Ai+1:n_muestraA)
                if (contemplado(it_Aj) == 1)            
                    % Modelo analizado Mo.
                    Modelo_Mo = Modelos_A(it_Aj);
                    codes_Mo = Modelo_Mo.codes;
                    
                    if (Modelo_Mo.logevidence+Modelo_Mo.logprior-mejor_logevidence-prior0 < Ol)%fMRI
                        % El modelo no se contempla puesto que no pertenece a la
                        % ventana de occam.
                        contemplado(it_Aj) = 0;
                    elseif isempty(setdiff(codes_Mo, codes_M)) && isempty(setdiff(codes_M, codes_Mo))
                        % son iguales
                        contemplado(it_Aj) = 0;
                    elseif isempty(setdiff(codes_Mo, codes_M))
                        % Se chequea si Mo siendo un subconjunto de M tiene
                        % mas evidencia que M.
                        if (Modelo_Mo.logevidence+Modelo_Mo.logprior > Modelo_M.logevidence+Modelo_M.logprior)%fMRI
                            % M no se tiene mas nunca en cuenta.
                            contemplado(it_Ai) = 0;
                        end
                    elseif isempty(setdiff(codes_M, codes_Mo))
                        % Se chequea si M siendo un subconjunto de Mo tiene
                        % mas evidencia que Mo.
                        if (Modelo_M.logevidence +Modelo_M.logprior> Modelo_Mo.logevidence+Modelo_Mo.logprior)%fMRI
                            % Mo no se tiene mas nunca en cuenta.
                            contemplado(it_Aj) = 0;
                        end
                    end
                end
                % En el caso contrario (contemplado == 0) no tiene
                % sentido hacer nada. Simplemente no se analiza y se
                % pasa a ver el proximo elemento.
            end
        end
    end
    % En el caso contrario (contemplado == 0) no tiene sentido hacer nada. 
    % Simplemente no se analiza y se pasa a ver el proximo elemento.
end

% Al final del ciclo los indices de los elementos que valen 1 en
% contemplado indican aquellos modelos que subsisten.
Modelos_A = Modelos_A(find(contemplado));

% Iteraremos finalmentos sobre estos en Modelos_A y los guardaremos
% ordenadamente en Modelos_C.
Modelos_C = Modelos_A(1);
n_A=length(Modelos_A);
[ord,pos]=sort([Modelos_A.logevidence]+[Modelos_A.logprior],2,'descend');
Modelos_C = Modelos_A(pos);
clear Modelos_A;
n_muestraA = 0;
n_muestraC=length(Modelos_C);
return;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function y = pertenece(codes_Mo, Modelos_C)
% Mira en Modelos_C si el conjunto formado por elementos_Mo ya esta
% contemplado.
% y = 1 => esta contemplado. O sea, pertenece.
% y = 0 => no esta contemplado.

for (it = 1:length(Modelos_C))
    codes_C = Modelos_C(it).codes;
    
    if isempty(setdiff(codes_Mo, codes_C)) & ...
            isempty(setdiff(codes_C, codes_Mo))
        y = 1;
        return;
    end
end

y = 0;
return;
