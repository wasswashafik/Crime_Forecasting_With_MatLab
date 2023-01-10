function Phi = get_rbf_Phi(x, mu, Sigma)
N = length(x);
M = length(mu);
Phi = zeros(N, M+1);
for i = 1:N
    for j = 1:M+1
        if j==1
            Phi(i, j) = 1;
        else
            Phi(i, j) = exp(-1/2*(x(i,:)-mu(j-1,:))*Sigma(:,:,j-1)^(-1)*(x(i,:)-mu(j-1,:))');
        end
    end
end 