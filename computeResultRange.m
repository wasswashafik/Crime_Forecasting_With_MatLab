function [nRange, nTotal] = computeResultRange(gridSz)
classes = {'numeric'};
attributes = {'>=',250,'<=',600};
funcName = 'computeResultRange';
validateattributes(gridSz,classes,attributes,funcName)
areaRange = [0.25, 0.75] * 5280^2;
nRange = areaRange./gridSz^2;

Portland = './data/police_district/Portland_Police_Districts.shp';
info_Portland = shapeinfo(Portland);
bbox = info_Portland.BoundingBox;
xCoor = bbox(1,1):gridSz:bbox(2,1);
yCoor = bbox(1,2):gridSz:bbox(2,2);
cols = length(yCoor);
rows = length(xCoor);
nTotal = cols*rows;