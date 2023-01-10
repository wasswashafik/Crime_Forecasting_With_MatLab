function [X,Y] = image2input(countMap,frame,N)
[ny,nx] = size(countMap);
label = countMap(:); 
y = 1:ny;
x = 1:nx;
[x,y] = meshgrid(x,y);
y = y(:);
x = x(:);
t = frame*ones(nx*ny,1); 
if N>0
    % shrink by only keeping top 100 grids in each month
    tops = min(nx*ny,N);
    [~,index]=sort(label,'descend');
    label = label(index(1:tops));
    x = x(index(1:tops));
    y = y(index(1:tops));
    t = t(index(1:tops));
end
X = [x y t];
Y = label;