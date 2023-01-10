function [predict_mat, sigma_mat, real_mat] = bayesain_linear_regression(countMaps, Centers)
    feature_mat = [];
    count_vec = [];
    for i=1:size(countMaps,1)-1
        [top, crime] = image2input(squeeze(countMaps(i,:,:)),i,2000);
        feature_mat = [feature_mat; top];
        count_vec = [count_vec; crime];
    end
    %% Pre process the data
    alpha = 2; beta = 25;
    time_mu_vec = [5 17 29 41 53 65];
    time_mu = repmat(time_mu_vec,size(Centers, 1), 1);
    location_mu = repmat(Centers, size(time_mu_vec, 2), 1);
    gauss_mu = [location_mu, time_mu(:)];
    sigma_time = 3;
    sigma_location = 2;
    gamma = sigma_location*eye(size(gauss_mu,2)); % basis function precisions
    gamma(end,end) = sigma_time;
    sigma = repmat(gamma, 1,1,length(gauss_mu));
    Phi = get_rbf_Phi(feature_mat, gauss_mu, sigma);
    %% Train data
    I = eye(length(gauss_mu)+1);
    S_N = (alpha*I + beta*(Phi'*Phi))^(-1);
    m_N = beta * S_N * Phi' * count_vec;
	%% Test data
    real_mat = squeeze(countMaps(end,:,:));
    [y,x] = size(real_mat);
    [x_idx, y_idx] = meshgrid(1:x, 1:y);
	x_idx = x_idx(:);
	y_idx = y_idx(:);
    test_mat = [x_idx, y_idx, repmat(size(countMaps,1), size(x_idx,1), 1)];
    Phi_test = get_rbf_Phi(test_mat, gauss_mu, sigma);
    f_bayes = Phi_test * m_N;
    sigma_N = beta^(-1) + diag(Phi_test*S_N*Phi_test');
    predict_mat = reshape(f_bayes,size(real_mat, 1), size(real_mat, 2));
    sigma_mat = reshape(sigma_N,size(real_mat,1 ), size(real_mat, 2));
end