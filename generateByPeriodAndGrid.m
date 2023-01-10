function [data,countMaps,censusMaps] = generateByPeriodAndGrid(category,period,gridSz)
narginchk(3,3); 
category = validatestring(category,{'ACFS','BURG','SC','TOA'});
period = validatestring(period,{'1MO'});

load(category)
data = mergeByPeriod(X,Y,Census,T,period);
Portland = './data/police_district/Portland_Police_Districts.shp';
info_Portland = shapeinfo(Portland);
bbox = info_Portland.BoundingBox;
xCoor = bbox(1,1):gridSz:bbox(2,1);
yCoor = bbox(1,2):gridSz:bbox(2,2);
[XCoor, YCoor] = meshgrid(xCoor, yCoor);
cols = length(yCoor);
rows = length(xCoor);
Rects = zeros(cols*rows, 4);
% up-left corner
Rects(:,1) = XCoor(:);
Rects(:,2) = YCoor(:);
% down-right corner
Rects(:,3) = XCoor(:) + gridSz;
Rects(:,4) = YCoor(:) + gridSz;
img = zeros(cols, rows);
img_census = zeros(cols, rows);
countMaps = zeros(length(data.summary), cols, rows);
censusMaps = zeros(length(data.summary), cols, rows);
for k = 1:length(data.summary)
    k
    coords = data.detail{k};
    Xcord = coords(:,1);
    Ycord = coords(:,2);
    census = coords(:,3);
    for ii=1:length(Rects)
        ind = Xcord>Rects(ii,1) & Xcord<Rects(ii,3) & Ycord>Rects(ii,2) & Ycord<Rects(ii,4);
        img(ii) = sum(ind);
        img_census(ii) = mean(census(ind));
    end
    img_census(isnan(img_census)) = 0;
    countMaps(k,:,:) = img;
    censusMaps(k,:,:) = img_census;
    
end
