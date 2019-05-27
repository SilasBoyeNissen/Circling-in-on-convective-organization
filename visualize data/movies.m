clear; close all; tic;

%% PARAMETERS
N = 10; % the initial number of circles in the system
SEED = 1; % the seed that was used as the random number generator
COLOR = 1; % 1 for the blue color scheme; 2 for the red color scheme
tSTART = -2; % the start of the movie on a logaritmic scale (10^-2 = 0.01)
tEND = 1; % the end of the movie on a logaritmic scale (10^1 = 10)
RES = 1000; % the number of frames of the movie

%% SCRIPT
colors          = [247 251 255; 222 235 247; 198 219 239; 158 202 225; 107 174 214;  66 146 198;  33 113 181;   8  81 156;   8  48 107]/255; % the blue color scheme
colors(:, :, 2) = [255 255 229; 255 247 188; 254 227 145; 254 196  79; 254 153  41; 236 112  20; 204  76   2; 153  52   4; 102  37   6]/255; % the red color scheme
load(['../generated mat-files/S' num2str(N) '-' num2str(SEED)]); % load the data file
S(:, 3) = S(:, 3) - max(S(:, 3)); % go back in time to the start of generation 1
figure(1); clf; % clear figure 1
set(figure(1), 'Position', [0 0 500 525]); % set the window position and size
video = VideoWriter(['../visualized movies/movie' num2str(N) '-' num2str(SEED)], 'MPEG-4'); % set the name of the movie file
open(video);
g = 1; % generation 1
for dt = logspace(tSTART, tEND, RES) % logarithmically spaced time
    clf;
    T = S + [0 0 dt 0 0]; % go to the current time point
    if all(T(T(:, 4) == g+1, 3) > 0)
        g = min(g+1, max(T(:, 4)-1)); % visible generations
    end
    T(T(:, 3) < 0, :) = []; % delete all circles with negative radius (those did not appear yet)
    T(T(:, 3) > 1.5, :) = []; % delete all circles bigger than a radius of 1.5 (those span the entire domain)
    T((T(:, 1) > 1) + (T(:, 2) > 1) + (((T(:, 1)-1).^2 + (T(:, 2)-1).^2) > T(:, 3).^2) == 3, :) = []; % delete all unnecessary circles to the top right of the domain
    T((T(:, 1) > 1) + (T(:, 2) < 0) + (((T(:, 1)-1).^2 + T(:, 2).^2) > T(:, 3).^2) == 3, :) = []; % delete all unnecessary circles to the top left of the domain
    T((T(:, 1) < 0) + (T(:, 2) > 1) + ((T(:, 1).^2 + (T(:, 2)-1).^2) > T(:, 3).^2) == 3, :) = []; % delete all unnecessary circles to the bottom right of the domain
    T((T(:, 1) < 0) + (T(:, 2) < 0) + ((T(:, 1).^2 + T(:, 2).^2) > T(:, 3).^2) == 3, :) = []; % delete all unnecessary circles to the bottom left of the domain
    T((T(:, 1) < 0) + (T(:, 2) > 0) + (T(:, 2) < 1) + (abs(T(:, 1)) > T(:, 3)) == 4, :) = []; % delete all unnecessary circles to the left of the domain
    T((T(:, 1) > 0) + (T(:, 2) < 0) + (T(:, 1) < 1) + (abs(T(:, 2)) > T(:, 3)) == 4, :) = []; % delete all unnecessary circles below the domain
    T((T(:, 1) > 1) + (T(:, 2) > 0) + (T(:, 2) < 1) + (T(:, 1)-1 > T(:, 3)) == 4, :) = []; % delete all unnecessary circles to the right of the domain
    T((T(:, 1) > 0) + (T(:, 2) > 1) + (T(:, 1) < 1) + (T(:, 2)-1 > T(:, 3)) == 4, :) = []; % delete all unnecessary circles above the domain
    tightsubplot(1, 1, [0 0], [0.005 0.05], [0.005 0.005]); % set the properties of tightsubplot. See the tightsubplot file for details.
    vis = find(T(:, 4) >= g)'; % find all visible circles
    rectangle('Position', [0 0 1 1], 'FaceColor', colors(mod(g-2, 9)+1, :, COLOR)); hold on; % set the background color
    for i = vis(1:1:end) % draw each circle as a rectangle with curvature [1 1] (that gives a circle)
        rectangle('Position', [T(i, 1)-T(i, 3) T(i, 2)-T(i, 3) 2*T(i, 3) 2*T(i, 3)], 'Curvature', [1 1], 'EdgeColor', 'none', 'FaceColor', colors(mod(T(i, 4)-1, 9)+1, :, COLOR));
    end
    title(['Time = ' num2str(dt, 2)], 'FontSize', 20); % write the current time stamp above the domain
    set(gca, 'Box', 'on', 'LineWidth', 3); % draw a black edge around the domain
    axis([0 1 0 1]); % show only the domain
    writeVideo(video, getframe(gcf)); % write the current frame to the movie file
end
close(video);
toc;