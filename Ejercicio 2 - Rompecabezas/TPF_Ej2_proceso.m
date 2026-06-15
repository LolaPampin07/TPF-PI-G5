% Abro la Imágen deseada
clc; clear all; close all;
[file,dir]= uigetfile ('*.bpm;*.jpg;*.png;*.tiff'); %filtro por tipo de archivo
filename=[dir,file]; %obtengo ruta y nombre de archivo
info=imfinfo(filename); % obtengo la metadata del archivo

I_rgb = imread(filename);

%% Verificamos si puede subdividirse en 16 piezas iguales.
[M_original, N_original, p] = size(I_rgb);

residuo_M = mod(M_original,4);
residuo_N = mod(N_original,4);

if residuo_N ~= 0 || residuo_M ~= 0
    if residuo_N ~= 0
        N_final = N_original - residuo_N;
    end
    if residuo_M ~= 0
        M_final = M_original - residuo_M;
    end

    % Hacemos un resize de la imágen
    I_rgb = imresize(I_rgb,[M_final,N_final]);

else
    M_final = M_original;
    N_final = N_original;
end

%% Paso de RGB a Lab y grafico para ver los distintos canales.
I_lab = lab2double(applycform(I_rgb , makecform('srgb2lab')));

L = I_lab(:, :, 1); % Luminosidad (0 a 100)
a = I_lab(:, :, 2); % Canal Rojo-Verde
b = I_lab(:, :, 3); % Canal Azul-Amarillo

% Visualización de los distintos canales
figure 
subplot(221); imshow(I_rgb); title('Imagen Original RGB');

% Canal L (Se ve como una imagen en escala de grises limpia)
subplot(222); imshow(L, [0 100]); title('Canal L* (Luminosidad)');

% Canal a (Zonas grises = neutro, zonas brillantes = rojo, oscuras = verde)
subplot(223); imshow(a, [-100 100]); title('Canal a* (Verde a Rojo)');

% Canal b (Zonas grises = neutro, zonas brillantes = amarillo, oscuras = azul)
subplot(224); imshow(b, [-100 100]); title('Canal b* (Azul a Amarillo)');

%% División de piezas
m_pieza = M_final/4;
n_pieza = N_final/4;

% Utilizo mat2cell para covertir la imagen en una celda de 4x4, donde cada
% pieza es una submatriz de [m_pieza, n_pieza]
piezas = mat2cell(I_lab, repmat(m_pieza,1,4), repmat(n_pieza,1,4), p);

% Muestro en una imágen las piezas (en rgb porque no puede graficar en Lab)
figure
for i=1:4
    for j=1:4
        subplot(4, 4, (i-1)*4+j);
        imshow(lab2rgb(piezas{i,j}));
    end
end

%% Mezclado de piezas
piezas_vector = reshape(piezas, 1, 16); %Paso de celda de matrices a vector de matrices
orden_piezas = randperm(16); % genera un vector con los números de 1 a 16 ordenados de forma aleatoria
piezas_mezcladas = reshape(piezas_vector(orden_piezas),4,4);


% Utilizo cell2mat para armar la imágen mezclada.
I_mezclada = cell2mat(piezas_mezcladas);

figure
imshow(lab2rgb(I_mezclada));title('Imágen con piezas mezcladas');

%% Algoritmo para rearmado de la imágen original
% Para las comparaciones utilizo la distancia euclídea sqrt(dL2 + dA2 + dB2).

% Realizo una celda auxiliar, donde voy a ubicar las piezas a medida que se
% vayan ordenando
piezas_mezcladas_vector = reshape(piezas_mezcladas, 1, 16); %para recorrer más facil las piezas
armado = cell(4,4);

% Mi pieza semilla va a ser la (1,1)
armado{1,1} = piezas{1,1};

% El rearmado va a ser de izquierda a derecha y de arriba hacia abajo,
% haciendo las comparaciones con los bordes de las piezas ya ubicadas anteriormente.

% Las comparaciones las realizo sobre el borde, pixel a pixel, tomando en cuenta los tres canales. 
piezas_usadas = false(1,16); % Para ir marcando y sacando del algoritmo las piezas ya colocadas.

% Busco cual es la pieza {1,1}, para marcarla
for i = 1:16
    if piezas_mezcladas_vector{1,i} == armado{1,1}
        piezas_usadas(i)=true;
    end
end

% % % Busco la pieza {1,2} para el armado de mi puzzle
%     borde_lat1 = armado{1,1}(:,n_pieza,:); % Tomo los valores de la columna hacia la derecha de la pieza
%     borde_inf = armado{1,1}(m_pieza,:,:); % Tomo los valores de la fila inferior
%     menor_error_lat = 1000000000000000; % Tomo un error alto
%     menor_error_infsup = 1000000000000000; % Tomo un error alto
% 
%     for i = 1:16
%         if piezas_usadas(i)==true %Si está usada la pieza, pasa a la siguiente
%             continue;
%         end
%         borde_lat2 = piezas_mezcladas_vector{1,i}(:,1,:); %Tomo los valores de la columna hacia izquierda de la pieza
%         dL_lat = borde_lat1(:,1) - borde_lat2(:,1);
%         dA_lat = borde_lat1(:,2) - borde_lat2(:,2);
%         dB_lat = borde_lat1(:,3) - borde_lat2(:,3);
% 
%         dE_lat = sqrt(dB_lat.^2+dA_lat.^2+dL_lat.^2); % Calculo delta E pixel a pixel
% 
%         error_medio_lat = mean(dE_lat(:)); % Calculo la media del error
%         if error_medio_lat < menor_error_lat
%             menor_error_lat = error_medio_lat;
%             mejor_opcion_lat = i;
%         end
%     end
%     armado{1,2} = piezas_mezcladas_vector{1,mejor_opcion_lat};
%     piezas_usadas(mejor_opcion_lat) = true;
% 
%     for n=1:16
%         if piezas_usadas(n)==true %Si está usada la pieza, pasa a la siguiente
%             continue;
%         end
%         borde_sup = piezas_mezcladas_vector{1,n}(1,:,:); %Tomo los valores de la columna hacia izquierda de la pieza
%         dL_infsup = borde_inf(:,1) - borde_sup(:,1);
%         dA_infsup = borde_inf(:,2) - borde_sup(:,2);
%         dB_infsup = borde_inf(:,3) - borde_sup(:,3);
% 
%         dE_infsup = sqrt(dB_infsup.^2+dA_infsup.^2+dL_infsup.^2); % Calculo delta E pixel a pixel
% 
%         error_medio_infsup = mean(dE_infsup(:)); % Calculo la media del error
%         if error_medio_infsup < menor_error_infsup
%             menor_error_infsup = error_medio_infsup;
%             mejor_opcion_infsup = n;
%         end
%     end
%     armado{2,1} = piezas_mezcladas_vector{1,mejor_opcion_infsup};
%     piezas_usadas(mejor_opcion_infsup) = true;

% 
% figure
% subplot(2,2,1); imshow(lab2rgb(armado{1,1}));
% subplot(2,2,2); imshow(lab2rgb(armado{1,2}));
% subplot(2,2,3); imshow(lab2rgb(armado{2,1}));

% figure
% for a=1:4
%     for b=1:4
%         subplot(4,4,(a-1)*4+b);
%         imshow(lab2rgb(armado{a,b}));
%     end
% end

% Armo funciones para buscar la mejor opcion
% 
% for i=1:4
%     for j=1:4
%         if i==1 && j==1 % Salteo el primero, ya conozco la posición
%             continue;
%         end
%         if i==1  % En la primera fila, solo hay comparación lateral con el anterior.
%            borde_lat1 = armado{i,j-1}(:,end,:); % Tomo los valores de la columna hacia la derecha de la pieza
%            menor_error_lat = 1000000000000000; % Tomo un error alto
% 
%            for l = 1:16
%                if piezas_usadas(l)==true %Si está usada la pieza, pasa a la siguiente
%                    continue;
%                end
%                borde_lat2 = piezas_mezcladas_vector{1,l}(:,1,:); %Tomo los valores de la columna hacia izquierda de la pieza
%                dL_lat = borde_lat1(:,1) - borde_lat2(:,1);
%                dA_lat = borde_lat1(:,2) - borde_lat2(:,2);
%                dB_lat = borde_lat1(:,3) - borde_lat2(:,3);
% 
%                dE_lat = sqrt(dB_lat.^2+dA_lat.^2+dL_lat.^2); % Calculo delta E pixel a pixel
% 
%                error_medio_lat = mean(dE_lat(:)); % Calculo la media del error
%                if error_medio_lat < menor_error_lat
%                    menor_error_lat = error_medio_lat;
%                    mejor_opcion_lat = l;
%                end
%            end
%            armado{i,j} = piezas_mezcladas_vector{1,mejor_opcion_lat};
%            piezas_usadas(mejor_opcion_lat) = true;
% 
%         elseif j==1 % En la primera columna solo hay comparación inferior-superior.
%             borde_inf = armado{i-1,j}(end,:,:); % Tomo los valores de la fila inferior
%             menor_error_infsup = 1000000000000000; % Tomo un error alto
%             for n=1:16
%                 if piezas_usadas(n)==true %Si está usada la pieza, pasa a la siguiente
%                     continue;
%                 end
%                 borde_sup = piezas_mezcladas_vector{1,n}(1,:,:); %Tomo los valores de la columna hacia izquierda de la pieza
%                 dL_infsup = borde_inf(:,1) - borde_sup(:,1);
%                 dA_infsup = borde_inf(:,2) - borde_sup(:,2);
%                 dB_infsup = borde_inf(:,3) - borde_sup(:,3);
% 
%                 dE_infsup = sqrt(dB_infsup.^2+dA_infsup.^2+dL_infsup.^2); % Calculo delta E pixel a pixel
% 
%                 error_medio_infsup = mean(dE_infsup(:)); % Calculo la media del error
%                 if error_medio_infsup < menor_error_infsup
%                     menor_error_infsup = error_medio_infsup;
%                     mejor_opcion_infsup = n;
%                 end
%             end
%             armado{i,j} = piezas_mezcladas_vector{1,mejor_opcion_infsup};
%             piezas_usadas(mejor_opcion_infsup) = true;
% 
%         else % Debo calcular ambos bordes
%             borde_lat1 = armado{i,j-1}(:,end,:); % Tomo los valores de la columna hacia la derecha de la pieza
%             borde_inf = armado{i-1,j}(end,:,:); % Tomo los valores de la fila inferior
%             menor_error_lat = 1000000000000000; % Tomo un error alto
%             menor_error_infsup = 1000000000000000; % Tomo un error alto
% 
%             for k = 1:16
%                 if piezas_usadas(k)==true %Si está usada la pieza, pasa a la siguiente
%                     continue;
%                 end
%                 borde_lat2 = piezas_mezcladas_vector{1,k}(:,1,:); %Tomo los valores de la columna hacia izquierda de la pieza
%                 dL_lat = borde_lat1(:,1) - borde_lat2(:,1);
%                 dA_lat = borde_lat1(:,2) - borde_lat2(:,2);
%                 dB_lat = borde_lat1(:,3) - borde_lat2(:,3);
% 
%                 dE_lat = sqrt(dB_lat.^2+dA_lat.^2+dL_lat.^2); % Calculo delta E pixel a pixel
% 
%                 error_medio_lat = mean(dE_lat(:)); % Calculo la media del error
%                 if error_medio_lat < menor_error_lat
%                     menor_error_lat = error_medio_lat;
%                     mejor_opcion_lat = k;
%                 end
%             end
% 
%             for c=1:16
%                 if piezas_usadas(c)==true %Si está usada la pieza, pasa a la siguiente
%                     continue;
%                 end
%                 borde_sup = piezas_mezcladas_vector{1,c}(1,:,:); %Tomo los valores de la columna hacia izquierda de la pieza
%                 dL_infsup = borde_inf(:,1) - borde_sup(:,1);
%                 dA_infsup = borde_inf(:,2) - borde_sup(:,2);
%                 dB_infsup = borde_inf(:,3) - borde_sup(:,3);
% 
%                 dE_infsup = sqrt(dB_infsup.^2+dA_infsup.^2+dL_infsup.^2); % Calculo delta E pixel a pixel
% 
%                 error_medio_infsup = mean(dE_infsup(:)); % Calculo la media del error
%                 if error_medio_infsup < menor_error_infsup
%                     menor_error_infsup = error_medio_infsup;
%                     mejor_opcion_infsup = c;
%                 end
%             end
% 
%             if mejor_opcion_infsup == mejor_opcion_lat
%                 armado{i,j} = piezas_mezcladas_vector{1,mejor_opcion_infsup};
%                 piezas_usadas(mejor_opcion_infsup) = true;
%             else 
%                 disp('Hay mas de una opcion posible para la posición')
%             end
%         end
%     end
% end
% 
% figure
% for a=1:4
%     for b=1:4
%         subplot(4,4,(a-1)*4+b);
%         imshow(lab2rgb(armado{a,b}));
%     end
% end

for i=1:4
    for j=1:4
        if i==1 && j==1 % Salteo el primero, ya conozco la posicion
            continue;
        end
 
        if i==1  % Primera fila: solo comparacion lateral
           borde_lat1 = armado{i,j-1}(:,end,:); % columna derecha de la pieza anterior
           menor_error_lat = 1000000000000000;
 
           for l = 1:16
               if piezas_usadas(l)==true % Si ya fue utilizada, sigo con el siguiente candidato
                   continue;
               end
               borde_lat2 = piezas_mezcladas_vector{1,l}(:,1,:); % columna izquierda de candidata
               dL_lat = borde_lat1(:,1) - borde_lat2(:,1);
               dA_lat = borde_lat1(:,2) - borde_lat2(:,2);
               dB_lat = borde_lat1(:,3) - borde_lat2(:,3);
 
               dE_lat = sqrt(dB_lat.^2+dA_lat.^2+dL_lat.^2);
               error_medio_lat = mean(dE_lat(:));
               if error_medio_lat <  menor_error_lat % Si es la de menor error, me quedo con la posición y continúo
                   menor_error_lat = error_medio_lat;
                   mejor_opcion_lat = l;
               end
           end
           armado{i,j} = piezas_mezcladas_vector{1,mejor_opcion_lat};
           piezas_usadas(mejor_opcion_lat) = true; % Marco la opción elegida para que no vuelva a tomarla como candidata
 
        elseif j==1 % Primera columna: solo comparacion superior-inferior
            borde_inf = armado{i-1,j}(end,:,:); 
            menor_error_infsup = 1000000000000000;
 
            for n=1:16
                if piezas_usadas(n)==true
                    continue;
                end
                borde_sup = piezas_mezcladas_vector{1,n}(1,:,:); 

                dL_infsup = borde_inf(:,:,1) - borde_sup(:,:,1);
                dA_infsup = borde_inf(:,:,2) - borde_sup(:,:,2);
                dB_infsup = borde_inf(:,:,3) - borde_sup(:,:,3);
 
                dE_infsup = sqrt(dB_infsup.^2+dA_infsup.^2+dL_infsup.^2);
                error_medio_infsup = mean(dE_infsup(:));
                if error_medio_infsup < menor_error_infsup
                    menor_error_infsup = error_medio_infsup;
                    mejor_opcion_infsup = n;
                end
            end
            armado{i,j} = piezas_mezcladas_vector{1,mejor_opcion_infsup};
            piezas_usadas(mejor_opcion_infsup) = true;
 
        else % Caso general: combina ambos bordes en un unico criterio
            borde_lat1 = armado{i,j-1}(:,end,:); % columna derecha de la pieza a la izquierda
            borde_inf  = armado{i-1,j}(end,:,:); % fila inferior de la pieza de arriba
 
            menor_error_total = 1000000000000000;
 
            for k = 1:16
                if piezas_usadas(k)==true
                    continue;
                end
 
                % --- error lateral (izquierda-derecha) ---
                borde_lat2 = piezas_mezcladas_vector{1,k}(:,1,:);
                dL_lat = borde_lat1(:,1) - borde_lat2(:,1);
                dA_lat = borde_lat1(:,2) - borde_lat2(:,2);
                dB_lat = borde_lat1(:,3) - borde_lat2(:,3);
                dE_lat = sqrt(dB_lat.^2+dA_lat.^2+dL_lat.^2);
                error_lat = mean(dE_lat(:));
 
                % --- error superior-inferior ---
                borde_sup = piezas_mezcladas_vector{1,k}(1,:,:);
                dL_infsup = borde_inf(:,:,1) - borde_sup(:,:,1);
                dA_infsup = borde_inf(:,:,2) - borde_sup(:,:,2);
                dB_infsup = borde_inf(:,:,3) - borde_sup(:,:,3);
                dE_infsup = sqrt(dB_infsup.^2+dA_infsup.^2+dL_infsup.^2);
                error_infsup = mean(dE_infsup(:));
 
                % --- error combinado ---
                error_total = error_lat + error_infsup;
                if error_total < menor_error_total
                    menor_error_total = error_total;
                    mejor_opcion = k;
                end
            end
 
            armado{i,j} = piezas_mezcladas_vector{1,mejor_opcion};
            piezas_usadas(mejor_opcion) = true;
        end
    end
end
 
figure
for a=1:4
    for b=1:4
        subplot(4,4,(a-1)*4+b);
        imshow(lab2rgb(armado{a,b}));
    end
end
 



