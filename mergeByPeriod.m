function data = mergeByPeriod(X,Y,Census,T,period)
if strcmp(period,'1MO')
    T = (T - mod(T,100))/100;
    [a,b]=hist(T,unique(T));
    data.summary = a';
    N = cell(length(b),1);
    for k = 1:length(b)
        effective = (T==b(k));
        x = X(effective); 
        y = Y(effective);
        census = Census(effective);
        N{k} = [x,y,census];
    end
    data.detail = N;
end