clc
close all
clear

x1 = [1:0.2:50]';
x2 = [10:2:500]';
x = [x1 x2];
yTrue = x2 + x2 .* sin(x1) + exp(x1/50);
yTrain = yTrue+5*randn(length(x),1);
theta0 = [0.2, 1.5, 0.2, 1.5];

kfcn = @(XN,XM,theta) (theta(1)^2)*exp(-(pdist2(XN,XM).^2)/(2*theta(2)^2))...
    + (theta(3)^2)*exp( -2*sin(pdist2(XN,XM)*pi/12).^2 )/(theta(4).^2);
    
kfcn = @(XN,XM,theta) (theta(1)^2)*exp(-(pdist2(XN(:,2),XM(:,2)).^2)/(2*theta(2)^2))+...%...
    + theta(3)^2*exp( -2*sin(pdist2(XN(:,1),XM(:,1))*pi/12).^2 )/(theta(4).^2);

model = fitrgp(x,yTrain,...
        'KernelFunction',kfcn,'KernelParameters',theta0,...
      'FitMethod','exact','PredictMethod','exact');
  
[y_gp,ysd] = predict(model,x);
figure;
plot3(x1,x2, yTrue, 'g'); hold on,
plot3(x1,x2, y_gp, 'r'); hold on,
plot3(x1,x2, y_gp+ysd, 'r:'); hold on,
plot3(x1,x2, y_gp-ysd, 'r:'); hold off,
legend('Ground truth', 'GP');
xlabel('x');
ylabel('count(total)');
title('Estimation of count(total)');
