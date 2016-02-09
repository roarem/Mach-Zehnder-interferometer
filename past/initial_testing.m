%% Clean up
close all;
clear all;
format;
imaqreset;

%% Initialize camera
% If the camera ouputs a black image, FlyCap2 may have to run in the
% background.
camera = videoinput('tisimaq_r2013', 1);
preview(camera)

%% Initialize NiDaq
s = daq.createSession('ni');
a0 = addAnalogOutputChannel(s,'Dev1','ao0','Voltage');
a0.Range = [-10, 10];
% sub = a0.Device.Subsystems;
% sub(2).RangesAvailable
queueOutputData(s,zeros(10,1))
startForeground(s);

%% Intensity difference test
% frame1 = getsnapshot(camera);
% pause(0.5);
% frame2 = getsnapshot(camera);
% frameDiff = abs(frame2(:,:,1)-frame1(:,:,1));
% S = sprintf('Difference: %g',norm(im2double(frameDiff)))
% % figure();
% % imagesc(frameDiff);
% % title('Test')
% % colorbar;
% 
% % Average intensity difference, no movement
% V2 = 1.12;
% N = 10;
% 
% frameDiff = 0;
% for i=1:N
%     frame1 = getsnapshot(camera);
%     pause(0.5);
%     frame2 = getsnapshot(camera);
%     frameDiff = frameDiff + abs(frame2(:,:,1)-frame1(:,:,1));
%     S = sprintf('Difference: %i',norm(im2double(frameDiff)))
%     pause(0.5);
% end
% S=sprintf('sum of difference: %g',norm(im2double(frameDiff)))
% frameDiff = frameDiff/N;
% S=sprintf('average of difference: %g',norm(im2double(frameDiff)))
% figure();
% imagesc(frameDiff)
% title('No shift')
% colorbar;

%% Average intensity difference, one period back and forth
pause(5)
frameDiff = 0;
V2 = 1.12;

I1 = zeros(480,640);
I2 = zeros(480,640);
iMax = 1
kMax = 30
tic
for i=1:iMax
    for k=1:kMax
        frame1 = getsnapshot(camera);
        I1 = I1 + im2double(frame1(:,:,1));
    end
    queueOutputData(s,V2*linspace(0,1,500)')
    startForeground(s);
    queueOutputData(s,V2*linspace(1,0,500)')
    startForeground(s);
    pause(1)
    for k=1:kMax
        frame2 = getsnapshot(camera);
        I2 = I2 + im2double(frame2(:,:,1));
    end
    %frameDiff = frameDiff + abs(frame2(:,:,1)-frame1(:,:,1));
    
end
toc
queueOutputData(s,zeros(10,1))
startForeground(s);
close all
frameDiff = (I1-I2)/kMax;
norm(frameDiff)
% S=sprintf('sum of difference: %g',norm(im2double(frameDiff)))
% frameDiff = frameDiff/N;
% S=sprintf('average of difference: %g',norm(im2double(frameDiff)))
% figure();
figure
imshow(I1/kMax)
colorbar;
figure
imshow(frameDiff)
title('Moved piezo back and forth one period')
colorbar;



% %%
% pause(2)
% kmax = 1;
% imax = 20;
% n = zeros(kmax,1)';
% for k=1:kmax
%     I1 = zeros(480,640);
%     I2 = zeros(480,640);
%     for i=1:imax
%         f = getsnapshot(camera);
%         I1 = I1 + im2double(f(:,:,1));
%     end
%     for i=1:imax
%         f = getsnapshot(camera);
%         I2 = I2 + im2double(f(:,:,1));
%     end
% 
%     I1 = I1 ./ imax;
%     I2 = I2 ./ imax;
% 
%     n(k) = norm(I1-I2)
% end
% close all
% sum(n)/kmax
% %hist(n)
% imagesc((I1-I2))
% colorbar()
% 
% %%
% pause(1)
% tic
% for i=1:20
%     f = getsnapshot(camera);
% end
% toc