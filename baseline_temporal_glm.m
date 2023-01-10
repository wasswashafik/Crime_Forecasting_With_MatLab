function [img_test, img_pred] = baseline_temporal_glm(countMaps,period)
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
    t = t';
    x_train = [1:nt-3]';
    t_train = t(1:end-1);
    x_test = [1:nt-2]';
    t_test = t;
    alpha = 2; beta = 25;
    % compute mu and gamma
    chain_period = 12;
    mu = 7.5:chain_period:nt+chain_period;
    firstIndexMonth = 3; mu = mu - firstIndexMonth + 1;
    mu = mu';
    Sigma = repmat(2*2, 1, 1, length(mu));
    Phi = get_rbf_Phi(x_train, mu, Sigma);
    I = eye(length(mu)+1);
    S_N = (alpha*I + beta*(Phi'*Phi))^(-1);
    m_N = beta * S_N * Phi' * t_train;
    Phi_test = get_rbf_Phi(x_test, mu, Sigma); % N x (M+1)
    f_bayes = Phi_test * m_N;
    sigma_N = beta^(-1) + diag(Phi_test*S_N*Phi_test');
end

figure;
bar(x_test, t_test),ylim([0,4000]), hold on,
plot(x_test, f_bayes, 'r', 'linewidth', 3); hold on,
plot(x_test, f_bayes+sigma_N, 'r:'); hold on,
plot(x_test, f_bayes-sigma_N, 'r:'); hold off,
legend('Ground truth', 'Bayesian');
xlabel('x');
ylabel('count(total)');
title('Estimation of count(total)');

%% distribute crimes into each cell
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
data_img = f_bayes(end).*mu;
img_pred = reshape(data_img,ny,nx);