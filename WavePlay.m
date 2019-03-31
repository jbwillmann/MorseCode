function WavePlay(userName)
% A utility to play a recorded wave file
%   Get the file from the operator 
        startDirectory = cd;
        [fileNameWithTag, fileDirectory] = uigetfile({'*.wav'},...
            'Select an audio file',...
            [startDirectory  '/UserData/' userName '/']);
        if fileNameWithTag == 0  % User canceles - get out
            return
        end
        filePath = [fileDirectory  fileNameWithTag];
        
% Play the selected .wav file
        [y,Fa] = audioread(filePath);
        sound(y,Fa);
     
end