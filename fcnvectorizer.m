function fvals = fcnvectorizer(objfcn, X)
particle_num = size(X, 1);
fvals = zeros(particle_num,1);
for i = 1:particle_num
    fvals(i) = objfcn(X(i,:));
end
end