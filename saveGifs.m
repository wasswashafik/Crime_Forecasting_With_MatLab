function saveGifs(category,period,countMaps,censusMaps)
narginchk(4,4); 
category = validatestring(category,{'ACFS','BURG','SC','TOA'});
period = validatestring(period,{'1MO'});

filename_count = ['figs/',category,'_',period,'_count.gif'];
filename_census = ['figs/',category,'_',period,'_census.gif'];

for k = 1:size(countMaps,1)
    img = squeeze(countMaps(k,:,:));
    img_census = squeeze(censusMaps(k,:,:));
    img = rescaleMat(img, 1, 255);
    img_census = rescaleMat(img_census, 1, 255);
    if k == 1
        imwrite(img,filename_count,'gif', 'Loopcount',inf);
        imwrite(img_census,filename_census,'gif', 'Loopcount',inf);
    else
        imwrite(img,filename_count,'gif','WriteMode','append');
        imwrite(img_census,filename_census,'gif','WriteMode','append');
    end
end