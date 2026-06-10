clear; close all; clc;
%% 1. CARGA
mag_log = load('esp_mag_g5.txt');
fase = load('esp_fase_g5.txt');
mag = exp(mag_log) - 1; % decompresion rango dinamico --> PREGUNTAR

%% VISUALIZACIÓN
figure(1);
subplot(1,2,1); imshow(mag_log, []); title('Magnitud (log centrada)'); colormap gray; colorbar;
subplot(1,2,2); imshow(fase, []); title('Fase centrada'); colormap gray; colorbar;
%[xp, yp] = ginput(1);
%xp

%% 2. DESCENTRAR ESPRECTRO Y FASE + DFT POLAR
mag = ifftshift(mag);
fase = ifftshift(fase);

F = mag .* exp(1i * fase); % PREGUNTAR - PPT

%% 3. IMAGEN CONTAMINADA
img_cont = ifft2(F, 'symmetric'); % inversa DFT en 2D

figure(2);
imshow(img_cont, []);title('Imagen contaminada');

%% 4. ESPECTRO PARA DETECTAR RUIDO
F_shift = fftshift(log(1 + abs(F))); % espectro magnitud centrado logaritmo imagen con ruido

%% 5. FILTRO NOTCH p/ limpiar el ruido periodico
[M,N]= size(F);
H = ones(size(F)); %matriz p/ filtro
[X,Y]= meshgrid(1:N,1:M);

picos = [700 450
         740  450];

radio = 1; % circulo del filtro --> pequeno pq el ruido es 1 pixel

for i=1:size(picos,1)
    x0=picos(i,1);
    y0=picos(i,2);
    dist= sqrt((X-x0).^2+(Y-y0).^2);
    H(dist<radio)=0;

end


%% aplicar notch correctamente
F_notch = fftshift(F) .* H;
F_notch = ifftshift(F_notch);

img_filtrada = real(ifft2(F_notch));

figure(4);
imshow(img_filtrada, []);
title('Imagen sin ruido periódico');

%% 9. CORRECCIÓN DE MOVIMIENTO (WIENER)

THETA = 90;
LEN = 180;

PSF = fspecial('motion', LEN, THETA);

img_final = deconvwnr(img_filtrada, PSF, 0);

figure(5);
imshow(img_final, []);
title('Imagen restaurada final');

%figure (6);
%I_rgb = cat(3, img_final, img_final, img_final);         % MxNx3