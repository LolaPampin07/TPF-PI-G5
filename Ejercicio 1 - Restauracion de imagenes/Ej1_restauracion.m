clear; close all; clc;
%% 1. CARGA
mag_log = load('esp_mag_g5.txt');
fase = load('esp_fase_g5.txt');
mag = exp(mag_log) - 1; % decompresion rango dinamico --> PREGUNTAR

%% VISUALIZACIÓN
figure(1);
subplot(1,2,1); imshow(mag_log, []); title('Magnitud (log centrada)'); colormap gray; colorbar;
subplot(1,2,2); imshow(fase, []); title('Fase centrada'); colormap gray; colorbar;

%% 2. DESCENTRAR ESPRECTRO Y FASE + DFT POLAR
mag = ifftshift(mag);
fase = ifftshift(fase);

F = mag .* exp(1i * fase); % DFT POLAR

%% 3. IMAGEN CONTAMINADA
img_cont = ifft2(F, 'symmetric'); % inversa DFT en 2D

figure(2);
imshow(img_cont, []);title('Imagen contaminada');

%% 4. Filtro NOTCH
F_shift = fftshift(log(1 + abs(F))); % espectro magnitud centrado logaritmo imagen con ruido

[M,N]= size(F);
H = ones(size(F)); %matriz p/ filtro
[X,Y]= meshgrid(1:N,1:M); %matriz con coordenadas en x y matriz con coordenas en y

picos = [700 450
         740  450];

radio = 1; % circulo del filtro --> pequeno pq el ruido es 1 pixel

for i=1:size(picos,1)
    x0=picos(i,1);
    y0=picos(i,2);
    dist= sqrt((X-x0).^2+(Y-y0).^2);
    H(dist<radio)=0;
end

% aplicar notch 
F_notch = fftshift(F) .* H;
F_notch = ifftshift(F_notch);

img_filtrada = real(ifft2(F_notch));

figure(3);
imshow(img_filtrada, []);
title('Imagen sin ruido periódico');

%% 5. CORRECCIÓN DE MOVIMIENTO
THETA = 90; % muy claro por observacion
rango_len = 177:182; % de 175 a 180 (va de a 1 pixel) en el rango posible de mov

figure(4); % grafico comparativo para los =/= valores de len

for i = 1:length(rango_len)
    len = rango_len(i);

    PSF = fspecial('motion', len, THETA);
 
    Im = deconvwnr(img_filtrada, PSF, 0);

    subplot(2,3,i);
    imshow(Im, []);
    title(['Len=' num2str(len) ' px']);
end

sgtitle('Visualizacion para =/= valores de LEN');

% valores que ajustaron la imagen
LEN = 180; 

PSF = fspecial('motion', LEN, THETA);

img_final = deconvwnr(img_filtrada, PSF, 0);

figure(5);
imshow(img_final, []);
title('Imagen restaurada final');
