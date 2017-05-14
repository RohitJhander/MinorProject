

close all;
clear all;


im  = imread('Image140.jpg');

feature('SetPrecision', 64);


%% set parameters
up_scale = 2;
model = 'x2.mat';

% up_scale = 2;
% model = 'model\x2.mat'; 
% up_scale = 4;
% model = 'model\x4.mat';

%% work on illuminance only
if size(im,3)>1
    im = rgb2ycbcr(im);
    im = im(:, :, 1);
end
im_gnd = crop(im, up_scale);
im_gnd = single(im_gnd)/255;

%% bicubic interpolation
im_l = imresize(im_gnd, 1/up_scale, 'bicubic');
tic
im_b = imresize(im_l, up_scale, 'bicubic');
toc

%% SRCNN
im_h = superresolution(model, im_b);

%% remove border
im_h = remove_border(uint8(im_h*255 ), [up_scale, up_scale]);
im_gnd = remove_border(uint8(im_gnd*255 ), [up_scale, up_scale]);
im_b = remove_border(uint8(im_b*255 ), [up_scale, up_scale]);

%% compute PSNR
psnr_bic = compute_psnr(im_gnd,im_b);
psnr_srcnn = compute_psnr(im_gnd,im_h);

%% show results
fprintf('PSNR for Bicubic Interpolation: %f dB\n', psnr_bic);
fprintf('PSNR for SRCNN Reconstruction: %f dB\n', psnr_srcnn);

figure, imshow(im_l); title('Bicubic Interpolation');
figure, imshow(im_h); title('SRCNN Reconstruction');
figure, imshow(im_gnd); title('ground truth');
%imwrite(im_b, ['Bicubic Interpolation' '.bmp']);
%imwrite(im_h, ['SRCNN Reconstruction' '.bmp']);
imwrite(im_gnd, ['SRCNNN140' '.jpg']);
