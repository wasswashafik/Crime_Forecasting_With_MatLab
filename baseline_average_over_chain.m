function [img_test, img_pred] = baseline_average_over_chain(countMaps,period)
period = validatestring(period,{'1MO'});
[nt,ny,nx] = size(countMaps);
ind_pred = nt-2;
img_test = squeeze(countMaps(ind_pred,:,:));
img_pred = zeros(ny,nx);
if strcmp(period, '1MO')
    % compute chain indices
    chain_period = 12;
    ind = ind_pred:-1*chain_period:1;
    ind = ind(end:-1:2);
    % average by chain
    img_pred = squeeze(mean(countMaps(ind,:,:), 1));
end