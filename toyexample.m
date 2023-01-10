% This is a toy example of the use of the code, and the network created has
% only a lstm layer
clear
clc
close all
numberUsed =500;

category = 'SC'; 
period = '1MO';
gridSz = 600;
load([category,'_',period,'_',num2str(gridSz),'_countMaps'])
avg_img = squeeze(mean(countMaps,1));
[~,ind] = sort(avg_img(:),'descend');

[nt,ny,nx] = size(countMaps);
x = zeros(nt-3, numberUsed);

for k=1:nt-3
    countMap = squeeze(countMaps(k,:,:));
    probMap = countMap./sum(countMap(:));
    values = probMap(ind(1:numberUsed));
    data(k,:) = values;
end

x = data(1:56,:);
y = data(2:57,:);

% set parameters for the lstmcell
seq_len = size(x,1); % number of frames
len_in = size(x,2); 
len_out = size(y,2);
active_funcs = {'sigm', 'sigm'};
opt.learningRate = 0.1;
opt.weightPenaltyL2 = 0.001;
opt.momentum = 0.5;
opt.scaling_learningRate = 0.5;
lstmcell = lstmcellsetup(len_in, len_out, opt, active_funcs);

% x = rand(seq_len, len_in + 1);
% y = rand(seq_len, len_out);
x = [zeros(56,1) x];

lstmcell = lstmcellff(lstmcell, x, y);
e = y - lstmcell.mh;
loss_1 = sum(sum(e .* e)) / 2 / seq_len;
lstmcell = lstmcellbp(lstmcell, e);

%% train the network
for i = 1:100
    i
    lstmcell = lstmcellff(lstmcell, x, y);
    e = y - lstmcell.mh;
    loss(i) = sum(sum(e .* e)) / 2 / seq_len;
    lstmcell = lstmcellbp(lstmcell, -e);
    lstmcell = lstmcellupdate(lstmcell);
end
plot(loss);

%% predict and plot

img_true = squeeze(countMaps(58,:,:));

countMap = squeeze(countMaps(57,:,:));
probMap = countMap./sum(countMap(:));
values = probMap(ind(1:numberUsed));
x_test = values';
x_test = [zeros(1,1) x_test];

y_pred = lstmcellff(lstmcell, x_test, y);
img_pred = zeros(ny,nx);
img_pred(ind(1:numberUsed)) = y_pred.mh;
% compute the range of number of hotspots
% [nRange, ~] = computeResultRange(gridSz);
nRange = [19, 58];
[PAI_pred,PEI_pred,PAI_best] = computePAIandPEI(img_pred,img_true,nRange,true);


