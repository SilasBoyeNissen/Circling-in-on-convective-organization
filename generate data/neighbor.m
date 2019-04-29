function NB = neighbor(G, S)
lav = find(S(:, 4) == G);
Sg = S(lav, :);
if Sg(1, 4) == 1
    TRI = delaunay(Sg(:, 1:2));
    NB = [zeros(size(TRI, 1), 1) TRI];
else
    n = 1;
    inc = min(size(Sg, 1)-1, 1000);
    NB = zeros(size(lav, 1)/4, 4);
    [~, ID] = mink(sqrt((Sg(:, 1)' - Sg(1:4:size(lav, 1), 1)).^2 + (Sg(:, 2)' - Sg(1:4:size(lav, 1), 2)).^2) - Sg(1:4:size(lav, 1), 3) - Sg(:, 3)', inc+1, 2);
    for i = 1:4:size(lav, 1)
        in = ID((i+3)/4, 2:inc+1);
        xy = Sg(i, 1:2) - Sg(in, 1:2);
        nDis = (xy(:, 1)/2 - xy(:, 1)').^2 + (xy(:, 2)/2 - xy(:, 2)').^2;
        nDis(eye(inc, inc) == 1) = 1000;
        v = nchoosek(in(sum(nDis < (xy(:, 1).^2 + xy(:, 2).^2)/4, 2) <= 10), 2);
        NB(n:n+size(v, 1)-1, :) = [repmat([-1 i], size(v, 1), 1) v];
        n = n + size(v, 1);
    end
end
NB = unique(sort(NB, 2), 'rows');
NB(NB>0) = lav(NB(NB>0));
ijk = NB;
ijk(ijk>0) = S(ijk(ijk>0), 5);
NB = NB(all(diff(sort(ijk, 2), 1, 2) > eps, 2), :);
NB(:, 5:6) = 0;
parfor i = 1:size(NB, 1)
    NBi = NB(i, :);
	T = cp3cols(Sg, S(NBi(:, 2:4), :));
    NB(i, :) = [T(1) NBi(2:4) T(2:3)];
end
NB(isnan(NB(:, 1)), :) = [];