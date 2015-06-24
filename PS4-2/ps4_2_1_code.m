%Cristina Chu

%PS4
%Part 2.1 Compute angle

% Getting images
%image = im2double(imread('transA.jpg'));
%image = im2double(imread('transB.jpg'));
image = im2double(imread('simA.jpg'));
%image = im2double(imread('simB.jpg'));

original = image;

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
%row = row - win*2;
%col = col - win*2;

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

% Threshold
t = 0.08;
corners = zeros(size(image));

% Non Maximal Suppression - getting nice points
for y = 10:size(image,1)-10,
    for x = 10:size(image,2)-10,
        maxvalue = max(max(r(y-4:y+4, x-4:x+4)));
        
        if r(y,x) >= maxvalue && r(y,x) > max(r(:)) * t
            
            if sum(sum(corners(y-4:y+4,x-4:x+4))) == 0,
                corners(y,x) = 1;
            end;
            
        end;
    end;
end;

% Corners
[r2,c2]=find(corners==1);

% Getting angles and displaying
imshow(image);
hold on

angle = atan2(Iy,Ix);

pair = [r2,c2];
linePair = sub2ind(size(r),r2,c2);
f = [c2,r2,r(linePair)*10,angle(linePair)]';

h1 = vl_plotframe(f(:,:));
h2 = vl_plotframe(f(:,:));

set(h1,'color','cyan','linewidth',3);
set(h2,'color','magenta','linewidth',1);
