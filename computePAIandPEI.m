function [PAI_pred,PEI_pred,PAI_best] = computePAIandPEI(img_pred,img_test,nRange,showResult)

[ny,nx] = size(img_test);
oneCol_test = img_test(:);
[oneCol_test_sorted,ind_test]=sort(oneCol_test,'descend');
PAI_best = [];
PEI_best = [];

oneCol_pred = img_pred(:);
[~,ind_pred]=sort(oneCol_pred,'descend');
oneCol_pred_sorted = oneCol_test(ind_pred);
PAI_pred = [];
PEI_pred = [];
for k=floor(nRange(1)):floor(nRange(2))
    n_best = sum(oneCol_test_sorted(1:k));
    N = nx*ny;
    a = k;
    A = N;
    PAI_best = [PAI_best (n_best/N)/(a/A)];
    PEI_best = [PEI_best 1]; % because we already choose the best PAI_test.
    
    n_pred = sum(oneCol_pred_sorted(1:k));
    PAI_pred = [PAI_pred (n_pred/N)/(a/A)];
    PEI_pred = [PEI_pred n_pred/n_best];
end

if showResult
    figure;
    plot(PAI_best), hold on
    plot(PAI_pred), hold on
    [best_PAI,best_ind] = sort(PAI_pred,'descend');
    best_PAI = best_PAI(1); best_ind = best_ind(1);
    plot(best_ind,best_PAI,'ko','MarkerSize',10), hold off
    title('PAI')
    legend('true', 'pred')

    figure;
    plot(PEI_best), hold on
    plot(PEI_pred), hold on
    [best_PEI,best_ind] = sort(PEI_pred,'descend');
    best_PEI = best_PEI(1); best_ind = best_ind(1);
    plot(best_ind,best_PEI,'ko','MarkerSize',10), hold off
    ylim([0,1]);
    title('PEI')
    legend('true', 'pred')
    
    % show hotspot image
    img_result = uint8((rescaleMat(img_test, 0, 255)));
    best_k = floor(nRange(1)) + best_ind - 1;
    ind_best = ind_test(1:best_k);
    ind_prop = ind_pred(1:best_k);
    [I,J] = ind2sub(size(img_test),ind_best);
    pos = [J I];
    img_result = insertMarker(img_result,pos,'+','color','green','size',2);
    [I,J] = ind2sub(size(img_test),ind_prop);
    pos = [J I];
    img_result = insertMarker(img_result,pos,'x','color','red','size',2);
    figure;
    imshow(img_result,[]);
end