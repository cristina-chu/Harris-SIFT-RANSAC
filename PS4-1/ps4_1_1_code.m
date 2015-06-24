%Cristina Chu

%PS4
%Part 1.1 Compute X and Y gradients

% Getting images
simA = im2double(imread('simA.jpg'));
transA = im2double(imread('transA.jpg'));


% Filtering images - Gaussian
filter = fspecial('gaussian', [5,5], 0.5);
filterSimA = imfilter(simA, filter , 'replicate');
filterTransA = imfilter(transA, filter , 'replicate');

% Derivatives
dy = [-1, -1, -1; 0, 0, 0; 1, 1, 1];
dx = dy';

% Getting gradient pairs
simAx = conv2(filterSimA, dx, 'same');
simAy = conv2(filterSimA, dy, 'same');

transAx = conv2(filterTransA, dx, 'same');
transAy = conv2(filterTransA, dy, 'same');


%Show images
imshow([simAx,simAy],[min(simAx(:)),max(simAx(:))]);
figure(2);
imshow([transAx,transAy],[min(transAx(:)),max(transAx(:))]);