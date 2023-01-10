function [X,Y,Census,T] = preprocess(category)
% 'ACFS': 'all call for service'
% 'BURG'" 'BURGLARY'
% 'SC': 'STREET CRIMES'
% 'TOA': 'MOTOR VEHICLE THEFT'

fileFilter = './data/train/*.shp';
filenames = dir(fileFilter);
X = [];
Y = [];
T = [];
Census = [];
for k=1:length(filenames)
    k
    filename = [filenames(k).folder, '/', filenames(k).name];
    if strcmp(category,'ACFS')
        S = shaperead(filename, 'Attributes',{'occ_date','census_tra'});
    elseif strcmp(category,'BURG')
        S = shaperead(filename, 'Attributes',{'occ_date','census_tra'},...
        'Selector', {@(v1) (strcmp(v1,'BURGLARY')),'CATEGORY'});
    elseif strcmp(category,'SC')
        S = shaperead(filename, 'Attributes',{'occ_date','census_tra'},...
        'Selector', {@(v1) (strcmp(v1,'STREET CRIMES')),'CATEGORY'});
    else
        S = shaperead(filename, 'Attributes',{'occ_date','census_tra'},...
        'Selector', {@(v1) (strcmp(v1,'MOTOR VEHICLE THEFT')),'CATEGORY'});
    end
    x = [S.X]';
    y = [S.Y]';
    census = [S.census_tra]';
    t = str2double({S.occ_date}); t = t';
    effective = ~isnan(t);
    x = x(effective);
    y = y(effective);
    census = census(effective);
    t = t(effective);
    X = [X;x];
    Y = [Y;y];
    T = [T;t];
    Census = [Census;census];
end
save(category, 'X','Y','T','Census');