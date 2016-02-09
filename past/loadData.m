%% Clean up
close all;
clear all;
format;
clc;

%% Load dataz
spatialSkip  = 5;
temporalSkip = 1;
plotting = 4;
%%

%%
% fileName = sprintf('measurement_calcit%d.mat', 0);
% load(fileName);
% theta0 = thetaUnWrapped(1:spatialSkip:end, 1:spatialSkip:end);
% 
% % Plot theta0
% figure(2);
% surf(thetaUnWrapped(1:spatialSkip:end,1:spatialSkip:end));
% 
% clearvars -except theta0 spatialSkip temporalSkip
% 
% pixel = zeros(359);
% 

%% Animate
for kkk=2:temporalSkip:2
    kkk
    fileName = sprintf('new_measurement\measurement_%d.mat', kkk);
    load(fileName);
    
    pixel(kkk+1) = frame(1,300);
    
    if plotting == 1
        figure(1);
        subplot(1,2,1);
        surf(thetaUnWrapped(1:spatialSkip:end,1:spatialSkip:end));%-theta0);
    
        % Plot aesthetics.
        xlabel('x [pixel]')
        ylabel('y [pixel]')
        zlabel('\theta [rad]')
        axis([1 120/spatialSkip 1 480/spatialSkip -700 700])
        if kkk~=0 
            if currentTime(end-2) < 0 
                currentTime(end-2) = 24 + currentTime(end-2);
            end
            if currentTime(end-1) < 0
                currentTime(end-1) = 60 + currentTime(end-1);
                currentTime(end-2) = currentTime(end-2) - 1;
            end
            titleStr = sprintf('time=%d h %d min', currentTime(end-2),currentTime(end-1));
            title(titleStr);
        end

        subplot(1,2,2);
        imshow(frame)

        % Ensure the plot is updated in real time.
        drawnow();
        pause(0.1);
    end
    
    if plotting == 2
        plot(pixel(1:kkk));
        drawnow();
    end
    
    if plotting == 3
        imagesc(frame);
        drawnow();
    end
    
    if plotting == 4
        %% Unwrap the phase angle
        % Use only a cut out of the total picture.
        xstart = 1;
        xend   = 640;
        ystart = 1;
        yend   = 480;

        % Using a more sophisticated 2D method due to Costantini.
        IM = theta(1:end,xstart:xend)*2*pi;
        thetaUnWrapped = cunwrap(IM, struct('maxblocksize',300));
        save(sprintf('new_measurement\new\measurement_%d.mat',time))
    end
    % Throw away everything except for the unwrapped theta values from the
    % data.
    clearvars -except kkk unWrappedLine spatialSkip temporalSkip theta0 pixel plotting
end

%%
plot(pixel)
