function [img_test, img_pred] = baseline_temporal_gp(countMaps,period)
period = validatestring(period,{'1MO'});
[nt,ny,nx] = size(countMaps);

if strcmp(period, '1MO')
    ind_pred = nt-2;
    img_test = squeeze(countMaps(ind_pred,:,:));
    img_pred = zeros(ny,nx);
    for k=1:nt-2
        img = squeeze(countMaps(k,:,:));
        t(k) = sum(img(:));
    end
    t= t';
    x_train = [1:nt-3]';
    t_train = t(1:end-1);
    x_test = [1:nt-2]';
    t_test = t;
    
%     sigma0 = std(t_train);
%     sigmaF0 = sigma0;
%     d = size(x_train,2);
%     sigmaM0 = 10*ones(d,1);
    kfcn = @(XN,XM,theta) (theta(1)^2)*exp(-(pdist2(XN,XM).^2)/(2*theta(2)^2))...
    + theta(3)*exp( -2*sin(pdist2(XN,XM)*pi/12).^2 )/(theta(4).^2);

    model = fitrgp(x_train,t_train,'Basis','linear',...
        'KernelFunction',kfcn,'KernelParameters',[0.2, 1.5, 0.2, 1.5],...
      'FitMethod','exact','PredictMethod','exact');
end

[t_gp,tsd] = predict(model,x_test);
figure;
bar(x_test, t_test); hold on,
plot(x_test, t_gp, 'r', 'linewidth',3); hold on,
plot(x_test, t_gp+tsd, 'r:'); hold on,
plot(x_test, t_gp-tsd, 'r:'); hold off,
legend('Ground truth', 'GP');
xlabel('x');
ylabel('count(total)');
title('Estimation of count(total)');

%%
data = zeros(ny*nx,nt);
for t=1:nt
    img = squeeze(countMaps(t,:,:));
    img = img(:);
    imgN = img/sum(img);
    data(:,t) = imgN;
end
mu = mean(data,2);
mu = mu/sum(mu);
% check distribution vs. time
Sigma = std(data,0,2);
disp(['maximum standard deviation of all grids = ', num2str(max(Sigma))]);
% distribute crimes
data_img = t_gp(end).*mu;
img_pred = reshape(data_img,ny,nx);
