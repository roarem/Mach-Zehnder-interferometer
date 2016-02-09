%% Clean up
close all;
clear all;
clc;
format;
imaqreset;


%% Allow time to leave the room.
pause(0.1);


%% Numerics / Parameters
numberOfPictures = 30;   % Number of pictures to average over.
waitPeriod       = 1;    % Wait time for the mirror to stabilize after piezo movement [s].
f                = 1.12; % Period of the interference fringes [V].
N                = 7;    % Number of pictures to take for calculating the phase angle.


%% Initialize camera
% If the camera ouputs a black image, FlyCap2 may have to run in the
% background.
camera = videoinput('tisimaq_r2013', 1);
preview(camera)

%%
% frame = getsnapshot(camera);
% imshow(frame)
%% Initialize NiDaq
s = daq.createSession('ni');
a0 = addAnalogOutputChannel(s,'Dev1','ao0','Voltage');


%% Adjust output voltage 
V = linspace(0,f,N);
I = zeros(480,640,N);

for i=1:N
    % Apply voltage to the piezo.
    if i~=1 
        queueOutputData(s,linspace(V(i-1),V(i),500)');
        startForeground(s);
    end
    
    % Make sure the vibrations from the movement has stopped before we ask
    % the camera to take selfies.
    pause(waitPeriod);
    
    % Take numberOfPictures pictures, which we later average over.
    for k=1:numberOfPictures
        frame = getsnapshot(camera);
        I(:,:,i) = I(:,:,i) + im2double(frame(:,:,1));
    end
end

% Average over the numberOfPictures number of pictures for each setting of
% the piezo.
I = I ./ numberOfPictures;

% Reset the output back to zero.
queueOutputData(s,linspace(f,0,1000)');
startForeground(s);


%% Calculate the phase angle theta
switch N
    case 3
        %Three samples
        tanTheta = (I(:,:,1)-I(:,:,3))./(-I(:,:,1)+2*I(:,:,2)-I(:,:,3));
    case 5
        %Five samples
        tanTheta = (2*I(:,:,2)-2*I(:,:,4))./(-I(:,:,1)+2*I(:,:,3)-I(:,:,5));
    case 7
        %Seven samples
        tanTheta = (-I(:,:,1)+7*I(:,:,3)-7*I(:,:,5)+I(:,:,7))./(-4*I(:,:,2)+8*I(:,:,4)-4*I(:,:,6));
end
theta = atan(tanTheta);
%%

%% "Fix" not a number entries in theta
for i = 1:480
    for j=1:640
        if isnan(theta(i,j))
            theta(i,j) = 0;
        end
    end
end


%% Unwrap the phase angle
% % Use only a cut out of the total picture.
% xstart = 250;
% xend   = 360;
% ystart = 1;
% yend   = 480;
% xstart = 1;
% xend   = 580;
% ystart = 125;
% yend   = 140;

% ystart = 102;
% yend   = 614;
% xstart = 391;
% xend   = 394;

ystart = 1;
yend   = 480;
xstart = 1;
xend   = 640;

% Using Matlabs built in 1D unwrap tool.
%thetaUnWrapped = unwrap(mean(theta(xstart:xend, ystart:yend),1)*2*pi);

% Using a more sophisticated 2D method due to Costantini.
%IM = theta(xstart:xend, ystart:yend)*2*pi;
IM = theta(ystart:yend,xstart:xend)*2*pi;
thetaUnWrapped = cunwrap(IM, struct('maxblocksize',300));


%% Plot stuffs
% Plot the resulting angle, theta 
figure();
skip = 1;
subplot(1,2,1);
surf(thetaUnWrapped(1:skip:end,1:skip:end));
xlabel('x')
ylabel('y')
h = title('uncorrected unwrapped angle, $\theta$');
set(h,'interpreter','latex')
limits = [0 (xend-xstart)/skip 0 (yend-ystart)/skip 0 700];

subplot(1,2,2);
imshow(frame(ystart:yend,xstart:xend,1)');
h = title('corrected unwrapped angle, $\theta$');
set(h,'interpreter','latex')
xlabel('x [pixel]');
ylabel('y [pixel]');
zlabel('\theta')


%%
figure();
imagesc(frame(:,:));
colormap('gray');
colorbar;
%%
% figure();
% imagesc(frame(xstart:xend,ystart:yend));
% colormap('gray');
% colorbar;


%% Save background image
%thetaUnWrappedBackground = thetaUnWrapped;
%save('background.mat','thetaUnWrappedBackground');
save('measurement_0.mat');

%% SOUND THE ALARM
for i=1:5
    beep
    pause(0.2)
end

