function  FlasherHandle = FlasherWindow(winPosition)
%FlasherWindow A window to visually  display transmitted code
%   Detailed explanation goes here
%% Initialize the user variables ----------------------------------

% Load the PreferencesFile.mat file from the ProgramData directory.
    load('ProgramData/PreferencesFile.mat',...
        'allUsersPrefs', 'windowsPrefs', 'glob');
       
%% Set up main user interface  ------------------------------------
% Setup GUI parameters 
    if winPosition == 0
        windowLeft = windowsPrefs{3,13};
        windowBottom = windowsPrefs{4,13};
        windowWidth = windowsPrefs{5,13};
        windowHeight =  windowsPrefs{6,13};
    else
        windowLeft = winPosition(1) + winPosition(3) + 1;
        windowBottom = winPosition(2);
        windowWidth = 3*winPosition(4);
        windowHeight =  winPosition(4);
        
    end

%   Main figure window
    FlasherHandle = figure(...
        'CloseRequestFcn',@CloseWindow,...
        'Units', 'Characters',...
        'Position',[windowLeft,windowBottom,...
            windowWidth,windowHeight],...
        'NumberTitle', 'off','MenuBar', 'none',...
        'DockControls', 'off','Toolbar', 'none',...
        'Color', glob.flasherOff,...
        'Name', 'Flasher'...
    );

end % end Flasher

