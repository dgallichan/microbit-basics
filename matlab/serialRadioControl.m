% microbit bitbot driver - via serial communication with local USB-connected
% microbit

% put 'robotRemoteDriveTest_robot' on the microbit on the bitbot 
%     (available from: https://github.com/dgallichan/robotRemoteDriveTest_robot )
% put 'robotRemoteDriveTest_matlab' on the USB-connected microbit
%     (available from: https://github.com/dgallichan/robotRemoteDriveTest_matlab ) 

clear
close all
% s = serialport("/dev/cu.usbmodem14102",115200); % <-- MacOSX specific path!
% s = serialport("COM7",115200);  % <-- this worked at one point in windows!
%%% 115200 is the baud rate for the microbit serial communication: https://lancaster-university.github.io/microbit-docs/ubit/serial/

%% This manual approach of unplugging and replugging seems to work for Windows 10

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

%%

s = serialport(microbitCOM,115200);  

%% Test some commands on the bitbot:

s.writeline("Go:1000");
pause(2);
s.writeline("Rotate:400");
pause(2);
s.writeline("Go:1000");
pause(2);
s.writeline("Rotate:400");
pause(2);
s.writeline("Go:1000");
pause(2);
s.writeline("Rotate:400");
