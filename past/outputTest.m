%% Clean up
close all;
clear all;
clc;
format;


%% Set up dig. output with the nidaq
s = daq.createSession('ni'); 
addDigitalChannel(s,'Dev1','Port1/Line1:0','OutputOnly');
outputSingleScan(s, [1 1])


%% Shut off the digital output
outputSingleScan(s, [0 0])


%% Set up analog output with the nidaq
clear all;
s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1','ao0','Voltage');
queueOutputData(s,0.5*ones(10,1));
startForeground(s);


%queueOutputData(s,0*ones(10,1));
%startForeground(s);


%% Create video input object with pointgrey camera



