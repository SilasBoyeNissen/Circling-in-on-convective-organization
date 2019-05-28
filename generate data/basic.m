clear; close all;

%% PARAMETERS
N = 100; % the initial number of circles in the system
SEED = 1; % the seed to be used as the random number generator
LIMIT = 1000; % an upper bound on the number of generations to run

%% SCRIPT
rng(SEED); % set the random number generator
S = multiply([rand(N, 2) zeros(N, 1) ones(N, 1) (1:4:4*N)']); % the system: [X-position Y-position Radius Generation Replicas]. Three replicas are made as periodic boundary conditions.
for G = 1:LIMIT % generations to run
    tic; % start a timer
    if any(S(:, 4) == G) % only if any circles of that generation are present in the system
        col = ones(0, 3); % the collision matrix keeps track of that no triplets collide multiple times
        S(:, 3) = S(:, 3) - max(S(S(:, 4) == G, 3)); % go back in time to the first circle of that generation was seeded
        NB = neighbor(G, S); % finds the neighborhoods in the system for this generation
        [~, in] = sort(NB(:, 1)); % sort the collision points in the order as they appear
        for i = in' % loop over all the collision points (that is all potential circles)
            dr = cp3cols(S(S(:, 4) == G, :), S(NB(i, 2:4), :)); % calculate the location and the distance to the new circle
            if ~isnan(dr(1)) % only if it obeys all requirements
                S(:, 3) = S(:, 3) + dr(1); % all circles in the system grow with the distance to the new circle
                NB(:, 1) = NB(:, 1) - dr(1); % the distance to all future circles schrink with the same amount
                nbs = NB(i, 2:4); % the indices of the three circles that collide (might be a replica)
                ijk = zeros(1, 3);
                ijk(nbs>0) = S(nbs(nbs>0), 5); % the indices of the three original circles that collide (exclude replicas)
                if all(sum((col == ijk(1)) + (col == ijk(2)) + (col == ijk(3)), 2) < 3) % self-interactions are not allowed
                    S = [S; multiply([dr(2:3) 0 G+1 size(S, 1)+1])]; % expand the system with the new circle
                    col(end+1, :) = ijk; % add to the collision matrix
                end
            end
        end
        disp(['N=' num2str(N) ' Seed=' num2str(SEED) ' Generation=' num2str(G) ': #circles=' num2str(sum(S(:, 4) == G)/4) ' time=' num2str(toc)]); % display the status of the system
    end
    save(['../generated mat-files/S' num2str(N) '-' num2str(SEED)], 'S'); % save the system matrix
end
