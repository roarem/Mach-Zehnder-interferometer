%% Clean up
close all;
clear all;
clc;
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


%% Adjust output voltage 
N = 50;
V = linspace(0.2,2,N);
pixel = zeros(N,1)';

for i=1:N
    % Adjust the output voltage.
    queueOutputData(s,V(i)*ones(10,1))
    startForeground(s);
    
    % Pause, ensure the NiDaq box has enough time to adjust the output
    % before we take a picture.
    pause(0.1);
    
    % Take picture and store the value at a given pixel.
    frame    = getsnapshot(camera);
    pixel(i) = frame(300,300);
end
%%
% Reset the output back to zero.
queueOutputData(s,0*ones(10,1));
startForeground(s);


%% 
N = 50
a = linspace(30,100,N);
b = linspace(5.5,7.5,N);
c = linspace(2*pi,7*2*pi,N);
d = linspace(50,100,N);

normbest = 1e300;
best = zeros(3,1);

for i=1:N
    for j=1:N
        for k=1:N
            for l=1:N
                y = d(l)+a(i)*sin(b(j)*V+c(k));
                n = norm(y-pixel);
                if n < normbest 
                    best = [a(i) b(j) c(k) d(l)];
                    normbest = n;
                end
            end
        end
    end
end

normbest
best




figure()
plot(V, pixel)
hold('on')
plot(V,best(4)+best(1)*sin(best(2)*V+best(3)),'r--');


%%

%V2 = zeros(N,1);
V2 = 1.12%/(2*pi);


for i=1:N
    % Adjust the output voltage.
    if mod(i,2)~=0
        queueOutputData(s,V2*linspace(0,1,500)')
    else
        queueOutputData(s,V2*linspace(1,0,500)')
    end
    startForeground(s);
    
    % Pause, ensure the NiDaq box has enough time to adjust the output
    % before we take a picture.
    pause(5.1);
    
    % Take picture and store the value at a given pixel.
    frame    = getsnapshot(camera);
    pixel(i) = frame(300,300,1);
end

queueOutputData(s,0*ones(10,1))
startForeground(s);
%%
figure()
plot(V2, pixel(1:4))
