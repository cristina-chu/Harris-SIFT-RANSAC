%Cristina Chu

%PS4
%Part 2.2 SIFT descriptor extraction functions

% Getting images
imageA = im2double(imread('transA.jpg'));
imageB = im2double(imread('transB.jpg'));
%imageA = im2double(imread('simA.jpg'));
%imageB = im2double(imread('simB.jpg'));

originalA = imageA;
originalB = imageB;

% Filtering images - Gaussian
filter = fspecial('gaussian', 7, .5);
filteredA = imfilter(imageA, filter, 'replicate');
filteredB = imfilter(imageB, filter, 'replicate');

%% ImageA
% Deriviatives
dy=[-1,-1,-1;0,0,0;1,1,1];
dx=dy';

% Getting gradient pairs
Ix = conv2(filteredA, dx, 'same');
Iy = conv2(filteredA, dy, 'same');

% Matrices for M
Ixx=Ix.*Ix;
Iyy=Iy.*Iy;
Ixy=Ix.*Iy;

%Calculating M
%-design decisions
win = 3;
alpha = 0.04;
[row, col] = size(imageA);

imageA = padarray(imageA,[win,win]);
Ixy = padarray(Ixy,[win,win]);
Ixx = padarray(Ixx,[win,win]);
Iyy = padarray(Iyy,[win,win]);

rA = zeros(row, col);

for i=1:row
    for j=1:col
        sum_Ixy = sum(sum(filter.*Ixy(i:i+win*2,j:j+win*2)));
        sum_Ixx = sum(sum(filter.*Ixx(i:i+win*2,j:j+win*2)));
        sum_Iyy = sum(sum(filter.*Iyy(i:i+win*2,j:j+win*2)));
        
        m = [sum_Ixx, sum_Ixy; sum_Ixy, sum_Iyy];
        
        rA(i,j) = det(m)-alpha*trace(m)^2;
    end
end

% Threshold
t = 0.08;
corners = zeros(size(imageA));

% Non Maximal Suppression - getting nice points
for y = 10:size(imageA,1)-10,
    for x = 10:size(imageA,2)-10,
        maxvalue = max(max(rA(y-4:y+4, x-4:x+4)));
        
        if rA(y,x) >= maxvalue && rA(y,x) > max(rA(:)) * t
            
            if sum(sum(corners(y-4:y+4,x-4:x+4))) == 0,
                corners(y,x) = 1;
            end;
            
        end;
    end;
end;

% Corners
[r_A,c_A]=find(corners==1);

% Angles
anglesA = atan2(Iy,Ix);

%% ImageB
% Deriviatives
dy=[-1,-1,-1;0,0,0;1,1,1];
dx=dy';

% Getting gradient pairs
Ix = conv2(filteredB, dx, 'same');
Iy = conv2(filteredB, dy, 'same');

% Matrices for M
Ixx=Ix.*Ix;
Iyy=Iy.*Iy;
Ixy=Ix.*Iy;

%Calculating M
%-design decisions
win = 3;
alpha = 0.04;
[row, col] = size(imageB);
%row = row - win*2;
%col = col - win*2;

imageB = padarray(imageB,[win,win]);
Ixy = padarray(Ixy,[win,win]);
Ixx = padarray(Ixx,[win,win]);
Iyy = padarray(Iyy,[win,win]);

rB = zeros(row, col);

for i=1:row
    for j=1:col
        sum_Ixy = sum(sum(filter.*Ixy(i:i+win*2,j:j+win*2)));
        sum_Ixx = sum(sum(filter.*Ixx(i:i+win*2,j:j+win*2)));
        sum_Iyy = sum(sum(filter.*Iyy(i:i+win*2,j:j+win*2)));
        
        m = [sum_Ixx, sum_Ixy; sum_Ixy, sum_Iyy];
        
        rB(i,j) = det(m)-alpha*trace(m)^2;
    end
end

% Threshold
t = 0.08;
corners = zeros(size(imageB));

% Non Maximal Suppression - getting nice points
for y = 10:size(imageB,1)-10,
    for x = 10:size(imageB,2)-10,
        maxvalue = max(max(rB(y-4:y+4, x-4:x+4)));
        
        if rB(y,x) >= maxvalue && rB(y,x) > max(rB(:)) * t
            
            if sum(sum(corners(y-4:y+4,x-4:x+4))) == 0,
                corners(y,x) = 1;
            end;
            
        end;
    end;
end;

% Corners
[r_B,c_B]=find(corners==1);

% Angles
anglesB = atan2(Iy,Ix);

%% Displaying everything
imshow( [originalA, originalB]);
hold on

linePairA = sub2ind(size(rA), r_A, c_A);
fA = [c_A, r_A, rA(linePairA)*10, anglesA(linePairA)]';

linePairB = sub2ind(size(rB), r_B, c_B);
fB = [c_B, r_B, rB(linePairB)*10, anglesB(linePairB)]';

f = [fA fB];

h1 = vl_plotframe(f(:,:));
h2 = vl_plotframe(f(:,:));

set(h1,'color','cyan','linewidth',3);
set(h2,'color','magenta','linewidth',1);

fB = [c_B, r_B, rB(linePairB)*10, anglesB(linePairB)]';

% Matching points on the images
fA_1 = fA;
fB_1 = fB;
fA_1(3,:) = 1;
fB_1(3,:) = 1;

[fA_2, dA_2] = vl_sift(single(originalA),'frames', fA_1);
[fB_2, dB_2] = vl_sift(single(originalB),'frames', fA_1);

matches = vl_ubcmatch(dA_2, dB_2);

kA = fA_2(:,matches(1,:));
kB = fB_2(:,matches(2,:));

offset = size(originalA, 2);

for i = 1:size(matches,2)
    plot([fA_2(1, matches(1, i)), (fB_2(1, matches(2, i)) + offset)], [fA_2(2, matches(1, i)), fB_2(2, matches(2, i))]);
end

