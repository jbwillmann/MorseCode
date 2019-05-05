function CloseWindow(~,~)
% CloseWindow function - This function closes the currently open window
% (gcf) and also saves the windows current location to the preferences file
% if the check box in the windows preferences window is selected.

% Get all variables from the PreferencesFile.mat
% This loads the variable arrays allUsersPrefs, windowsPrefs and glob
    load('ProgramData/PreferencesFile.mat',...
        'allUsersPrefs', 'windowsPrefs', 'glob');

    if glob.saveWindows % Save the new window position
    % Get the current window position and size
        pos = get(gcf, 'Position');   
        leftPosition = pos(1);
        bottomPosition = pos(2);
        currentWindowName = get(gcf, 'Name');

        for index = 2:14
            windowName = windowsPrefs(1,index);
            if strcmp(windowName, currentWindowName)
                windowsPrefs{3,index} = leftPosition;
                windowsPrefs{4,index} = bottomPosition;

                if index == 13
                    windowsPrefs{5,index} = pos(3);
                    windowsPrefs{6,index} = pos(4);
                end

                save('ProgramData/PreferencesFile.mat',...
                    'allUsersPrefs', 'windowsPrefs', 'glob');
            end           
        end
        
    end % end if glob.saveWindows
    
    delete(gcf)

end % end CloseWindow
