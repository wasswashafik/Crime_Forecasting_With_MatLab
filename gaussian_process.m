function [model,img_test,img_pred,ysd,err_training,err_test] = gaussian_process(countMaps)

% transfer images to features and counts

[nt,ny,nx] = size(countMaps);
x_train = [];
y_train = [];
for k=1:nt-3
    countMap = squeeze(countMaps(k,:,:));
    [x,y] = image2input(countMap,k,100);
    x_train = [x_train;x];
    y_train = [y_train;y];
end

if exist('gpModel.mat', 'file') == 0
    % fit
    disp('begin fitting');
    sigma0 = std(y_train);
    sigmaF0 = sigma0;
    sigmaM0 = 10;
    
    kfcn = @(XN,XM,theta) ...
        (theta(1)^2)*exp( -(pdist2(XN(:,1:2),XM(:,1:2)).^2)/(2*theta(2)^2) ) +...
        (theta(3)^2)*exp( -2*sin(pdist2(XN(:,3),XM(:,3))*pi/12).^2 /(theta(4).^2) )+ ...
        (theta(5)^2)*exp( -(pdist2(XN(:,3),XM(:,3)).^2)/(2*theta(6)^2) );
%         (theta(1)^2)*(1+sqrt(3)*pdist2(XN(:,1:2),XM(:,1:2))/theta(2))*exp(-sqrt(3)*pdist2(XN(:,1:2),XM(:,1:2))/theta(2)) +... % k_s(s,s')
%         (theta(3)^2)*exp(-(pdist2(XN(:,3),XM(:,3)).^2)/(2*theta(4)^2));% +...  % k_t(t,t')
%         (theta(5)^2)*(1+sqrt(3)*pdist2(XN(:,1:2),XM(:,1:2))/theta(6))*exp(-sqrt(3)*pdist2(XN(:,1:2),XM(:,1:2))/theta(6)) *...
%         exp(-(pdist2(XN,XM).^2)/(2*theta(7)^2)) +...  % k_st(s,t,s',t')
%         (theta(8)^2)*exp( -2*sin(pdist2(XN(:,3),XM(:,3))*pi/12).^2 )/(theta(9).^2);  %k_P(t,t')  

    model = fitrgp(x_train,y_train,'KernelFunction',kfcn,'Sigma',sigma0,...
        'KernelParameters',[sigmaF0,sigmaM0,sigmaF0,sigmaM0,sigmaF0,sigmaM0],...
        'FitMethod','exact','PredictMethod','exact','Standardize',1);

    save('gpModel', 'model')
else
    % load
    disp('load model from disk');
    load('gpModel')
end
% estimate training error
disp('begin estimating training error');
err_training = sqrt(resubLoss(model));

% predict
disp('begin predicting');
countMap = squeeze(countMaps(end-2,:,:));
[x_test,y_test] = image2input(countMap,nt-2,-1);
[y_test_pred,ysd] = predict(model,x_test);
% weight = (ysd - min(ysd)) * (max(ysd) - min(ysd));
% y_test_pred = y_test_pred.*weight;
% estimate test error
disp('begin estimating test error');
err_test = sqrt(mean((y_test_pred-y_test).^2));

% transfer features back to image
disp('begin transfering back to image');
img_test = reshape(y_test,138,163);
img_pred = reshape(y_test_pred,138,163);