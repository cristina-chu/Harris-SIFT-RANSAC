%Cristina Chu

%PS4
%Part 1.2 Compute Harris value

% Getting images
%image = im2double(imread('transA.jpg'));
%image = im2double(imread('transB.jpg'));
%image = im2double(imread('simA.jpg'));
image = im2double(imread('simB.jpg'));

% Filtering images - Gaussian
filter = fspecial('gaussian', 7, .5);
filtered = imfilter(image, filter, 'replicate');

% Deriviatives
dy=[-1,-1,-1;0,0,0;1,1,1];
dx=dy';

% Getting gradient pairs
Ix = conv2(filtered, dx, 'same');
Iy = conv2(filtered, dy, 'same');

% Matrices for M
Ixx=Ix.*Ix;
Iyy=Iy.*Iy;
Ixy=Ix.*Iy;

%Calculating M
%-design decisions
win = 3;
alpha = 0.04;
[row, col] = size(image);
row = row - win*2;
col = col - win*2;

image = padarray(image,[win,win]);
Ixy = padarray(Ixy,[win,win]);
Ixx = padarray(Ixx,[win,win]);
Iyy = padarray(Iyy,[win,win]);

r = zeros(row, col);

for i=1:row
    for j=1:col
        sum_Ixy = sum(sum(filter.*Ixy(i:i+win*2,j:j+win*2)));
        sum_Ixx = sum(sum(filter.*Ixx(i:i+win*2,j:j+win*2)));
        sum_Iyy = sum(sum(filter.*Iyy(i:i+win*2,j:j+win*2)));
        
        m = [sum_Ixx, sum_Ixy; sum_Ixy, sum_Iyy];
        
        r(i,j) = det(m)-alpha*trace(m)^2;
    end
end

%Showing image
imshow(r,[min(r(:)),max(r(:))]);