% matlab_log_serial.m
%
% gallichand@cardiff.ac.uk - Feb 2023
%
% Simple approach to using MATLAB as a data logger of USB serial
% communications from a microcontroller such as micro:bit (or Arduino, etc)
%
% With the micro:bit, can be used with
% https://github.com/dgallichan/microbit-serialDataToMatlab code on the
% microbit

clear
close all

useFixedCOMport = true;

if useFixedCOMport

    % s = serialport("/dev/cu.usbmodem14102",115200); % <-- MacOSX specific path!
    % s = serialport("COM7",115200);  % <-- this is the windows-specific
    % example method, but the number of the COM port can change between PCs and setups  
    %%% 115200 is the baud rate for the microbit serial communication: https://lancaster-university.github.io/microbit-docs/ubit/serial/

    s = serialport("COM29",115200);
else

    % This manual approach of unplugging and replugging seems to work for Windows 10

    disp('Unplug your microbit from USB, then press a key')
    commandwindow
    pause % wait for keypress

    pause(2) % wait 2 seconds
    slistUnplug = serialportlist;
    nUnplug = length(slistUnplug);
    disp("Found " + nUnplug + " USB devices")

    disp('Now plug your microbit back into USB, and press a key')
    commandwindow
    pause  % wait for keypress
    pause(2) % wait 2 seconds
    slistPlugged = serialportlist;
    nPlugged = length(slistPlugged);
    disp("This time found " + nPlugged + " USB devices")

    if nPlugged == (nUnplug + 1)
        microbitCOM = slistPlugged(not(contains(slistPlugged,slistUnplug)));
        disp("Microbit identifed as: " + microbitCOM);
    else
        disp("Sorry, unable to identify the microbit device!")
    end

    s = serialport(microbitCOM,115200);
    % the second value here is 'Baud rate' which is 115200 if using micro:bit MakeCode, but can be a different value in general

end

%% Read some values - match parameters here to your data!
% It is assumed to be comma separated, with no additional text, e.g:
%
% 40753,12.894,31.258,2.196     
% 40777,11.394,31.858,0.696     
% 40801,9.744,32.908,-0.204     
% 40829,8.244,34.258,-4.704     
% 40853,6.294,34.558,-5.754     
% 40877,5.844,34.408,-6.354     
% 40901,5.844,34.108,-5.754     
% 40925,6.294,34.708,-6.654     
% 40949,4.044,34.558,-7.554  
%
% (Note that above you can see that the first column is 'time' so we can
% set the 'firstParameterIsTime' variable below to 'true'!)
%
% It should also work with just one variable, e.g:
%
% 1006                          
% 1019                          
% 1022                          
% 1019                          
% 1010                          
% 1009                          
% 1018                          
% 1006                          
% 1010  
%

totalRecordTime = 15;
nominalSampleRate = 10; % expected sample rate of serial data (Hz) (based on microcontroller code)
nSamplesTotal = nominalSampleRate*totalRecordTime;
nParametersPerLine = 1; % how many (comma separated) parameters are in the serial line
firstParameterIsTime = false; % whether to assume first datapoint is time

if firstParameterIsTime && nParametersPerLine == 1
    error("No point just recording time!")
end

showLiveText = true; % whether to show the serial line itself as it comes in or not (can slow things down for fastest collection)
showLivePlot = true; % whether to show the data as it comes in or not (can slow things down for fastest collection)


figure
allData = nan(nSamplesTotal,nParametersPerLine);

s.flush; % necessary to clear the serial buffer up until now
s.Timeout = 60; % number of seconds to wait when there is no data yet

linespec = {'linewidth',3,'marker','x'};

disp('Recording...')


if showLivePlot 
    % create the axes and datapoints to update in real-time (a bit faster
    % in MATLAB graphics than replotting the whole thing)

    if firstParameterIsTime
        hp = plot(allData(:,1)-allData(1,1),allData(:,2:end),linespec{:});
    else
        hp = plot(allData,linespec{:});
    end
    grid on
    grid minor
end

for i = 1:nSamplesTotal

    thisLine = s.readline; % <-- actually read the data

    if showLiveText
        fprintf(thisLine);
    else
        if mod(i,100)==0
            fprintf('.');
        end
    end
    
    if nParametersPerLine > 1
        thisLine = split(thisLine,',');
    end

    allData(i,:) = str2double(thisLine);

    if showLivePlot
        if firstParameterIsTime
            for iP = 1:nParametersPerLine-1
                hp(iP).XData = allData(:,1)-allData(1,1);
                hp(iP).YData = allData(:,iP+1);
            end
        else
            for iP = 1:nParametersPerLine
                hp(iP).YData = allData(:,iP);
            end
        end
    end

end
fprintf('\n');

disp('Done')

if firstParameterIsTime
    t = allData(:,1) - allData(1,1);
    allData = allData(:,2:end);
else
    t = [];
end

if ~showLivePlot
    if firstParameterIsTime
        plot(t,allData,linespec{:})
    else
        plot(allData,linespec{:});
    end
    grid on
    grid minor
end





