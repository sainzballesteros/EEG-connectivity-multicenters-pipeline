function [y, Modelo_muestra, n_muestra] = greedyG(cp, Ke, Le, Modelo, VS, TF, cota_intervalo);

% Comentarios:
%   Esta es una subrutina interna del BMA_MC3.M que implementa un algoritmo tipo
%   "greedy" que encuentra un modelo que esta en el camino del maximo global de las
%   distribucion. A partir de un modelo inicial va adicionando o quitando modelos
%   simples, de forma tal que el modelo con el que se opere sea el que mas incremente
%   la evidencia.
%
% Sintaxis:
%   [y, Modelo_muestra, n_muestra] = greedy(cp, Ke, Le, Modelo, n_mod, cota_intervalo);
%
% Entrada:
%   cp:             Matriz de datos
%   Ke:             Matriz del Leadfield
%   Le:             Matriz del Laplaciano
%   Modelo:         Variable de tipo struct" que contiene la informacion sobre los modelos
%                   simples iniciales
%   cota_intervalo: Contiene el intervalo de logevidencia que define el tamanno de la
%                   entana de Occam es un parametro importante en la estimacion via OW,
%                   pero es irrelevante para la estimacion via MC3
%
% Salida:
%   y:              Variable "struct" que contiene la informacion sobre el modelo de mas
%                   evidencia
%   Modelo_muestra: Variable "struct" que contiene la informacion sobre los modelos que caen
%                   dentro de la Ventana de Occam.
%   n_muestra:      Numero total de modelos que caen denro de la Ventana de Occam
%
% Autor: Jose Miguel Bornot
% Fecha: 2/06/2003

if nargin<7,
    cota_intervalo=10;
end;

n_mod=length(Modelo);
mejor_Modelo.elementos = zeros(1, n_mod);
mejor_Modelo.puntos = [];
mejor_Modelo.logprior = -realmax;
ncard=0;
mejor_Modelo.logevidence=-realmax;


%*****************************************************************
% En la muestra esta inicialmente el modelo inicial.
Modelo_muestra(1).elementos = mejor_Modelo.elementos;
Modelo_muestra(1).logevidence = mejor_Modelo.logevidence;
Modelo_muestra(1).logprior = mejor_Modelo.logprior;
n_muestra=0;
%*****************************************************************

while 1
    cardinalidad = length(find(mejor_Modelo.elementos));
    Proximo.modelo = -1;
    % Se inicializa asi porque se quiere que mejore la logevidence del modelo anterior.
    Proximo.logevidence = mejor_Modelo.logevidence;
    Proximo.logprior = mejor_Modelo.logprior;
    if cardinalidad~=0
        disp(sprintf('Greedy model dimensionality = %d, elements:', cardinalidad));
        disp(find(mejor_Modelo.elementos))
    end

    % Calculo del nivel de logevidence del proximo modelo.
    for (it = 1:n_mod)
        %         if length(Modelo(it).puntos)>1
        %             if (mejor_Modelo.elementos(it) == 1)
        elementos_temp = mejor_Modelo.elementos;
        if (mejor_Modelo.elementos(it) == 1) && (sum(mejor_Modelo.elementos)>1)
            elementos_temp(it) = 0;
            puntos_temp = setdiff(mejor_Modelo.puntos, Modelo(it).puntos);
            ncard = cardinalidad-1;
        else
            elementos_temp(it) = 1;
            puntos_temp = union(mejor_Modelo.puntos, Modelo(it).puntos);
            ncard = cardinalidad+1;
        end

        if (ncard == 0)
            continue;
        end
        % Calculo del nivel de logevidence del modelo analizado.
        if strcmp(VS,'volume')
            [K,L,Ui,si,Vi,mask] = prepmask3(Ke, Le, puntos_temp);
        elseif strcmp(VS,'surface')
            [K,L,Ui,si,Vi,mask] = prepmask(Ke, Le, puntos_temp);
        end

        if strcmp(TF,'time')
            logevidence = evidencer(cp,Ui,si,Vi,K);
        elseif strcmp(TF,'frequency')
            logevidence = evidencec(cp,Ui,si,Vi,K);
        end
            
       
        modelo_temp.elementos = elementos_temp;
        modelo_temp.logevidence = logevidence;
        cod=find(elementos_temp);
        prior=mean([Modelo(cod).prior]);
        prior=log(prior);
        modelo_temp.logprior = prior;
        modelo_temp.puntos = puntos_temp;
        insertar_modelo(modelo_temp);
        if (logevidence+prior> Proximo.logevidence+Proximo.logprior)
            Proximo.logevidence = logevidence;
            Proximo.logprior = prior;
            Proximo.modelo = it;
        end
    end

    if (Proximo.modelo == -1)
        % No se mejoro el modelo.
        y = mejor_Modelo;
        return;
    end
    % end

    % En Proximo se encuentra almacenado el mejor modelo, con el cual actualizamos
    % al modelo mejor_Modelo.
    if (mejor_Modelo.elementos(Proximo.modelo) == 1)
        mejor_Modelo.elementos(Proximo.modelo) = 0;
        mejor_Modelo.logevidence = Proximo.logevidence;
        mejor_Modelo.logprior = Proximo.logprior;
        mejor_Modelo.puntos = setdiff(mejor_Modelo.puntos, Modelo(Proximo.modelo).puntos);
    else
        mejor_Modelo.elementos(Proximo.modelo) = 1;
        mejor_Modelo.logevidence = Proximo.logevidence;
        mejor_Modelo.logprior = Proximo.logprior;
        mejor_Modelo.puntos = union(mejor_Modelo.puntos, Modelo(Proximo.modelo).puntos);
    end
end
%     end
% ******************************************************

y = mejor_Modelo;
Modelo_muestra = Modelo_muestra(1:n_muestra);
return;

    function insertar_modelo(modelc)
        % ******************************************************
        % Verificamos si el modelo puede ser introducido en la muestra o no.

        %         % Antes de insertar el modelo chequeamo si ya fue insertado.
        %         % Asumimos que es la primera vez que este modelo es visto.
        if (modelc.logevidence + modelc.logprior> Modelo_muestra(1).logevidence + Modelo_muestra(1).logprior -cota_intervalo)
            set2 = find(modelc.elementos == 1);
            for (it_muestra = 1:n_muestra)
                set1 = find(Modelo_muestra(it_muestra).elementos == 1);
                if (isempty(setdiff(set1, set2)) & isempty(setdiff(set2, set1)))
                    % modeloc ya esta contenido en el conjunto de modelos
                    % en Modelo_muestra
                    return;
                end
            end
            % El modelo puede ser insertado. Por tanto hay un modelo mas.
            n_muestra = n_muestra+1;
            Modelo_muestra(n_muestra).elementos = modelc.elementos;
            Modelo_muestra(n_muestra).logevidence = modelc.logevidence;
            Modelo_muestra(n_muestra).logprior = modelc.logprior;

            %             if n_muestra>1
            % Reordenamos Modelo_muestra.
            it_muestra = n_muestra;
            while (it_muestra > 1) && (Modelo_muestra(it_muestra-1).logevidence + Modelo_muestra(it_muestra-1).logprior < Modelo_muestra(it_muestra).logevidence + Modelo_muestra(it_muestra).logprior)
                temp = Modelo_muestra(it_muestra);
                Modelo_muestra(it_muestra) = Modelo_muestra(it_muestra-1);
                Modelo_muestra(it_muestra-1) = temp;
                it_muestra = it_muestra-1;
            end
            
            if (it_muestra == 1) && (n_muestra > 1)
                % El modelo es mejor que el mejor modelo observado hasta el momento.
                while (n_muestra > 1)
                    if (Modelo_muestra(n_muestra).logevidence + Modelo_muestra(n_muestra).logprior > Modelo_muestra(1).logevidence + Modelo_muestra(1).logprior-cota_intervalo)
                        break;
                    else
                        % Eliminamos el modelo.
                        n_muestra = n_muestra-1;
                    end
                end
            end
        end
    end         % fin de function insertar_modelo
end