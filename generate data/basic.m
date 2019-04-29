clear; close all;
N = 100; % initial number of cells 
for seed = 1:3 % seeds to test for
    tic; rng(seed);
    S = multiply([rand(N, 2) zeros(N, 1) ones(N, 1) (1:4:4*N)']);
    save(['../generated mat-files/S' num2str(N) '-' num2str(seed)], 'S');
end
for seed = 1:3
	load(['../generated mat-files/S' num2str(N) '-' num2str(seed)]);
    for G = 1:1000 % generations to run
    	tic;
        if any(S(:, 4) == G)
            col = ones(0, 3);
            S(:, 3) = S(:, 3) - max(S(S(:, 4) == G, 3));
            NB = neighbor(G, S);
            [~, in] = sort(NB(:, 1));
            for i = in'
                dr = cp3cols(S(S(:, 4) == G, :), S(NB(i, 2:4), :));
                if ~isnan(dr(1))
                    S(:, 3) = S(:, 3) + dr(1);
                    NB(:, 1) = NB(:, 1) - dr(1);
                    nbs = NB(i, 2:4);
                    ijk = zeros(1, 3);
                    ijk(nbs>0) = S(nbs(nbs>0), 5);
                    if all(sum((col == ijk(1)) + (col == ijk(2)) + (col == ijk(3)), 2) < 3)
                        S = [S; multiply([dr(2:3) 0 G+1 size(S, 1)+1])];
                        col(end+1, :) = ijk;
                    end
                end
            end
            disp(['N=' num2str(N) ' seed=' num2str(seed) ' gen=' num2str(G) ': #circ=' num2str(sum(S(:, 4) == G)/4) ' time=' num2str(toc)]);
        end
        save(['../generated mat-files/S' num2str(N) '-' num2str(seed)], 'S');
    end
end