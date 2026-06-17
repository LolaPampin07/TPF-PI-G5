clc; clear all; close all;
[file,dir]=uigetfile('.bmp;.tif;.jpg;.png');
filename=[dir,file];
info=imfinfo(filename);

%%
%Conversión - RGB a L*a*b

rgb = imread(filename);
%rgb es uint8

lab = lab2double(applycform(rgb, makecform('srgb2lab')));

figure
%subplot(2,1,1);
imshow(rgb,[]);
title('Imagen original - RGB')


%subplot(2,1,2);
%imshow(lab,[]);
%title('Imagen en L*a*b*')

%canales 
L = lab(:, :, 1);
a = lab(:, :, 2);
b = lab(:, :, 3);

%(Prueba)
%max(rgb(:))
%min(rgb(:))
%max(lab(:))
%min(lab(:))

%%
%Análisis histograma de canales L, a* y b*
%Objetivo: identificacion rangos de cada color presente en imagen

figure
subplot(1,3,1);
imshow(L, []);
title('Canal L* (Luminosidad)')
%para que imagen no se mimetice con el fondo cuando exporto
c_L = colorbar;
min_val_L = min(L(:));
max_val_L = max(L(:));
c_L.Ticks = [min_val_L, max_val_L];
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;

subplot(1,3,2);
imshow(a, []);
title('Canal a* (Rojo-Verde)')
c = colorbar;
min_val_a = min(a(:));
max_val_a = max(a(:));
c.Ticks = [min_val_a, max_val_a];
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;

subplot(1,3,3);
imshow(b, []);
title('Canal b* (Amarillo-Azul)')
c_b = colorbar;
min_val_b = min(b(:));
max_val_b = max(b(:));
c_b.Ticks = [min_val_b, max_val_b];
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;

%%
figure;

subplot(3,1,1);
histogram(a);
xlim([-128,127]);
title('Histograma - Canal a*');
grid on;

subplot(3,1,2);
histogram(b);
xlim([-128,127])
title('Histograma - Canal b*');
grid on;

subplot(3,1,3);
histogram(L);
xlim([0,100]);
title('Histograma - Canal L*');
grid on;


%%
%Segmentación por Umbral 

mascara_amarillo = (b >= 90);
mascara_azul = (b <= -50);
mascara_rojo = (a >= 50);
mascara_verde = (a <= -50);

mascara_negro = (L<10); 

%%
%Conteo de objetos

[L_rojo, n_rojo] = bwlabel(mascara_rojo);
[L_azul, n_azul] = bwlabel(mascara_azul);
[L_verde, n_verde] = bwlabel(mascara_verde);
[L_negro, n_negro] = bwlabel(mascara_negro);
[L_amarillo, n_amarillo] = bwlabel(mascara_amarillo);

paleta_rojo = uint8([255 255 255; 255 0 0]);
paleta_verde = uint8([255 255 255; 0 255 0]);
paleta_azul = uint8([255 255 255; 0 0 255]);
paleta_negro = uint8([255 255 255; 0 0 0]);

% %Quiero armar la paleta con los valores RGB de la imagen original
% 
% %separo canales RGB - imagen original
% %R = rgb(:,:,1);
% %G = rgb(:,:,2);
% %B = rgb(:,:,3);
% 
% %tomo valores de cada canal para cada color
% R_rojo = R(mascara_rojo);
% G_rojo = G(mascara_rojo);
% B_rojo = B(mascara_rojo);
% 
% R_verde = R(mascara_verde);
% G_verde = G(mascara_verde);
% B_verde = B(mascara_verde);
% 
% R_azul = R(mascara_azul);
% G_azul = G(mascara_azul);
% B_azul = B(mascara_azul);
% 
% R_amarillo = R(mascara_amarillo);
% G_amarillo = G(mascara_amarillo);
% B_amarillo = B(mascara_amarillo);
% 
% %Armo paletas
% paleta_rojo = [255 255 255; R_rojo(1) G_rojo(1) B_rojo(1)];
% paleta_verde = [255 255 255; R_verde(1) G_verde(1) B_verde(1)];
% paleta_azul = [255 255 255; R_azul(1) G_azul(1) B_azul(1)];
% paleta_amarillo = [255 255 255; R_amarillo(1) G_amarillo(1) B_amarillo(1)];
% paleta_negro = uint8([255 255 255; 0 0 0]);

figure;
subplot(2,2,1)
imshow(mascara_rojo, paleta_rojo);
title(['Objetos rojos detectados: ', num2str(n_rojo)]);
%para que imagen no se mimetice con el fondo cuando exporto
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;


subplot(2,2,2)
imshow(mascara_verde, paleta_verde);
title(['Objetos verdes detectados: ', num2str(n_verde)]);
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;

subplot(2,2,3)
imshow(mascara_azul, paleta_azul);
title(['Objetos azules detectados: ', num2str(n_azul)]);
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;

subplot(2,2,4)
imshow(mascara_negro, paleta_negro);
title(['Objetos negros detectados: ', num2str(n_negro)]);
axis on;
set(gca, 'XTick', [], 'YTick', []);
box on;

% figure;
% imshow(mascara_amarillo, paleta_amarillo);
% title('Fondo');
% axis on;
% set(gca, 'XTick', [], 'YTick', []);
% box on;
