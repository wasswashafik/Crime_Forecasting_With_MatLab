clear
clc

%% read shapefiles
category = 'SC'; 
period = '1MO';
[X,Y,Census,T] = preprocess(category);

%% gennerate image-like data
category = 'SC'; 
period = '1MO';
gridSz = 600;

[data, countMaps, censusMaps] = generateByPeriodAndGrid(category,period,gridSz);
save([category,'_',period,'_',num2str(gridSz),'_countMaps'], 'countMaps')
bar(1:length(data.summary), data.summary);
title([category,'-',period]);

%% save gifs
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

saveGifs(category,period,countMaps,censusMaps);

%% draw top 10 from the mean image with respect to time
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
[nt,~,~] = size(countMaps);
avg_img = squeeze(mean(countMaps,1));
[~,ind] = sort(avg_img(:),'descend');
values_collect = [];
prob_collect = [];
for k=1:nt
    countMap = squeeze(countMaps(k,:,:));
    probMap = countMap./sum(countMap(:));
    values = countMap(ind(1:10));
    values_collect = [values_collect values];
    prob = probMap(ind(1:10));
    prob_collect = [prob_collect prob];
end
figure;
for k=1:2:10
    values_per_month = values_collect(k,:);
    plot(values_per_month), hold on,
end
hold off

figure;
for k=1:2:10
    prob_per_month = prob_collect(k,:);
    plot(prob_per_month), hold on,
end
hold off

%% draw percentage map for all cells with respect to time
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
[nt,ny,nx] = size(countMaps);
dataOrig = zeros(ny*nx,nt);
data = zeros(ny*nx,nt);
for t=1:nt
    img = squeeze(countMaps(t,:,:));
    img = img(:);
    dataOrig(:,t) = img;
    data(:,t) = img/sum(img);
end
muOrig = mean(dataOrig,2);
mu = mean(data,2);
% check distribution vs. time
sigmaOrig = std(dataOrig,0,2);
sigma = std(data,0,2);
figure,
subplot(221), plot(muOrig),xlabel('image index'), ylabel('\mu (count)');
subplot(222), plot(sigmaOrig),xlabel('image index'), ylabel('\sigma (count)');
subplot(223), plot(mu),xlabel('image index'), ylabel('\mu (prob)');
subplot(224), plot(sigma),xlabel('image index'), ylabel('\sigma (prob)');


%% draw histogram of "# of crimes" in each month
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
clc

f = figure;
nt = size(countMaps,1);
for t=1:nt
    img = squeeze(countMaps(t,:,:));
    img = img(:);
    img_noZero = img;
    img_noZero(img==0)=[];
    h = histogram(img_noZero,'Normalization','Probability');
    
    hold on,
    x = 1:20;
    lambda = 1;
    y = exp(-lambda).*lambda.^x./factorial(x);
    plot(x,y,'LineWidth',1.5)
    xlim([0,20]);
    title(num2str(t));
    filename = ['figs/hists/hist_',num2str(t),'.png'];
    saveas(f,filename)
    w = waitforbuttonpress;
    hold off,
end

%% collect top 100 of each month and analyze each feature's relationship with (# of crimes)
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
[nt,ny,nx] = size(countMaps);
X = [];
Y = [];
for k=1:nt
    countMap = squeeze(countMaps(k,:,:));
    [x,y] = image2input(countMap,k,100);
    X = [X;x];
    Y = [Y;y];
end
figure,
subplot(131), plot(X(:,1), Y, 'r.'); xlim([1,nx]);xlabel('x');ylabel('count');
subplot(132), plot(X(:,2), Y, 'g.'); xlim([1,ny]);xlabel('y');ylabel('count');
subplot(133), plot(X(:,3), Y, 'b.'); xlim([1,nt]);xlabel('t');ylabel('count');

% covariance matrix
allData = [X Y];
[allData_norm, ~, ~] = zscore(allData);
C = cov(allData_norm)

%% simple average baseline
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
[img_test_base, img_pred_base] = baseline_average_over_chain(countMaps,period);
% compute the range of number of hotspot
[nRange, ~] = computeResultRange(gridSz);
[PAI_pred_base,PEI_pred_base,PAI_best_base] = computePAIandPEI(img_pred_base,img_test_base,nRange,true);

%% simple temporal GLM baseline
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
[img_test_temp_glm, img_pred_temp_glm] = baseline_temporal_glm(countMaps,period);
% compute the range of number of hotspot
[nRange, ~] = computeResultRange(gridSz);
[PAI_pred_temp_glm,PEI_pred_temp_glm,PAI_best_temp_glm] = computePAIandPEI(img_pred_temp_glm,img_test_temp_glm,nRange,true);

%% simple temporal GP baseline
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all
[img_test_temp_gp, img_pred_temp_gp] = baseline_temporal_gp(countMaps,period);
% compute the range of number of hotspot
[nRange, nTotal] = computeResultRange(gridSz);
[PAI_pred_temp,PEI_pred_temp,PAI_best_temp] = computePAIandPEI(img_pred_temp_gp,img_test_temp_gp,nRange,true);

%% Gaussian Progress ~ (x,y,t)
clc
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

[model,img_test,img_pred,ysd,err_training,err_test] = gaussian_process(countMaps);

close all
figure, 
subplot(121), imshow(img_test,[]);
subplot(122), imshow(img_pred,[]);

ysd1 = ysd;
ysd1( ysd1 > min(ysd1)+ (max(ysd1)-min(ysd1))*0.9 ) = 0;
ysd1( ysd1 ~=0 ) = 1;
ysd_img = reshape(ysd1,138,163);
img_pred_norm = img_pred.*ysd_img;
err_norm = sqrt(mean( (img_pred_norm(:) - img_test(:)).^2 ));
figure
imshow(img_pred_norm, []);

% compute the range of number of hotspots
[nRange, ~] = computeResultRange(gridSz);
[PAI_pred,PEI_pred,PAI_best] = computePAIandPEI(img_pred_norm,img_test,nRange,true);

%% general linear model
category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])

close all

sum_count = mean(countMaps,1);
sum_count = squeeze(sum_count);
sum_count(sum_count<=2)=0;
mean_num = 10;
[idx_y, idx_x] = find(sum_count~=0);
crime_mat = [idx_y, idx_x];
[idx,C]= kmeans(crime_mat,mean_num);
figure;
plot(crime_mat(:,2),164-crime_mat(:,1),'k.');
hold on
for i=1:mean_num
    plot(crime_mat(idx==i,2),164-crime_mat(idx==i,1),'.','MarkerSize',12)
    hold on
    plot(C(i,2), 164-C(i,1), '+', 'MarkerSize', 30)
end
Centers = [C(:,2), C(:,1)];
[predict_mat, sigma_mat, real_mat] = bayesain_linear_regression(countMaps, Centers);
figure
imshow(predict_mat,[])
[nRange, ~] = computeResultRange(gridSz);
[PAI_pred,PEI_pred,PAI_best] = computePAIandPEI(predict_mat,real_mat,nRange,true);
