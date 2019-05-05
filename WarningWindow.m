function userAction = WarningWindow(messageString)
%  This function creates a new warning figure and 
%  returns 1 if the user selects OK, otherwise it returns 0.

% Load the preferences file.
    load('ProgramData/PreferencesFile.mat', 'allUsersPrefs',...
        'windowsPrefs', 'glob');
    
% Set up some variables
    windowWidth = windowsPrefs{5,9};
    windowHeight =  windowsPrefs{6,9};
    textFont = windowsPrefs{7,9};

    white = [1  1  1];
    green = [.255 .627 .225];
                
% Create the figure
    WarningHandle = figure(...
        'CloserequestFcn', {@ActionCallback, 0},...
        'Units', 'Characters',...
        'Position',[windowsPrefs{3,9},windowsPrefs{4,9},...
            windowWidth,windowHeight],...
        'NumberTitle', 'off','MenuBar', 'none','Resize', 'off',...
        'DockControls', 'off','Toolbar', 'none','Color', white,...
        'Name', 'Warning Window'...
    );

%   Set up Application title
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .87 1 .12 ],...
        'FontSize', textFont+2,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string','Warning'...
    ); 

% uicontrol to display message
     uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .34 1 .5 ],...
        'FontSize', textFont+2,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string',messageString ...
    ); 

%   OK pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [.13 .1 .3 .2 ],...
        'FontSize', textFont-2,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',... 
        'string', 'OK',...
        'callback', {@ActionCallback, 1} ...
    );
    
%   Cancel pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [.57 .1 .3 .2 ],...
        'FontSize', textFont-2,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',... 
        'string', 'Cancel',...
        'callback', {@ActionCallback, 0} ...
    );

% Wait for the operator to respond before returning
    uiwait(WarningHandle);

 % ActionCallback Callback  
    function ActionCallback(~, ~, num)
        % Define the return argument
        switch num
            case 0  % Cancel
                userAction = 0;
            case 1  % OK
                userAction = 1;
        end
        
    % Enable return
        uiresume(WarningHandle);
        
    % Get the current window position and save it if enabled
        if glob.saveWindows % Save the new window position
            pos = get(gcf, 'Position');  
            windowsPrefs{3,9} = pos(1);
            windowsPrefs{4,9} = pos(2);
            save('ProgramData/PreferencesFile.mat',...
                'allUsersPrefs', 'windowsPrefs', 'glob');
        end
        
        delete(gcf)

    end % end ActionCallback
                                   
end % end WarningWindow
