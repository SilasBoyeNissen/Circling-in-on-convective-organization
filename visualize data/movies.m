clear; close all; tic;
COL = {'#f7fbff', '#deebf7', '#c6dbef', '#9ecae1', '#6baed6', '#4292c6', '#2171b5', '#08519c', '#08306b'}; % generation colors
DT = 0.01; % time resolution
Rmax = 10; % maximum radius
for N = 100  % initial number of cells 
    for seed = 1:3 % seeds number
        load(['../generated mat-files/S' num2str(N) '-' num2str(seed)]);
        figure(1); clf;
        S = sortrows(S, 4);
        S(:, 3) = S(:, 3) - max(S(:, 3));
        tightsubplot(1, 1, [0 0], [0 0], [0 0]);
        set(figure(1), 'Position', [0, 0, 250, 250]);
        video = VideoWriter(['../visualized movies/movie' num2str(N) '-' num2str(seed)], 'MPEG-4');
        open(video);
        g = 1;
        while sum((S(:, 3) < min(Rmax, 0.2)))
            clf;
            tightsubplot(1, 1, [0 0], [0 0], [0 0]);
            S(S(:, 3) < Rmax, 3) = S(S(:, 3) < Rmax, 3) + DT;
            if all(S(S(:, 4) == g+1, 3) > 0)
                g = min(g+1, max(S(:, 4)-1));
            end
            rectangle('Position', [-1, -1, 3, 3], 'Curvature', [1, 1], 'EdgeColor', 'none', 'FaceColor', hex2rgb(COL{mod(g-2, 9)+1})); hold on;
            for i = find((S(:, 3) > 0) + (S(:, 4) >= g) == 2)'
                rectangle('Position', [S(i, 1)-S(i, 3), S(i, 2)-S(i, 3), 2*S(i, 3), 2*S(i, 3)], ...
                    'Curvature', [1, 1], 'EdgeColor', 'none', 'FaceColor', hex2rgb(COL{mod(S(i, 4)-1, 9)+1})); hold on;
            end
            axis off;
            axis([0 1 0 1]);
            writeVideo(video, getframe(gcf));
        end
        close(video);
    end
end
toc;