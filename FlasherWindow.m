function  FlasherHandle = FlasherWindow()
%FlasherWindow A window to visually  display transmitted code
%   Detailed explanation goes here
%% Initialize the user variables ----------------------------------

% Load the PreferencesFile.mat file from the ProgramData directory.
    load('ProgramData/PreferencesFile.mat',...
        'allUsersPrefs', 'windowsPrefs', 'glob');
       
%% Set up main user interface  ------------------------------------
% Setup GUI parameters       
    windowWidth = windowsPrefs{5,13};
    windowHeight =  windowsPrefs{6,13};

    green = [.255 .627 .225];     
    white = [1  1  1]; 

%   Main figure window
    FlasherHandle = figure(...
        'CloseRequestFcn',@CloseWindow,...
        'Units', 'Characters',...
        'Position',[windowsPrefs{3,13},windowsPrefs{4,13},...
            windowWidth,windowHeight],...
        'NumberTitle', 'off','MenuBar', 'none',...
        'DockControls', 'off','Toolbar', 'none','Color', white, ...
        'Name', 'Flasher'...
    );

end % end Flasher

