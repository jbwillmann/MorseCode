function CloseWindow(~,~)
% CloseWindow function - This function closes the currently open window
% (gcf) and also saves the windows current location to the preferences file
% if the check box in the windows preferences window is selected.

% Get all varables from the PreferencesFile.mat
% This loads the varable arrays allUsersPrefs, windowsPrefs and glob
    load('ProgramData/PreferencesFile.mat',...
        'allUsersPrefs', 'windowsPrefs', 'glob');
    
% Get the current window position and size
    pos = get(gcf, 'Position');   
    leftPosition = pos(1);
    bottomPosition = pos(2);
    currentWindowName = get(gcf, 'Name');

    if glob.saveWindows % Save the new window position
         for index = 2:12
             windowName = windowsPrefs(1,index);
             if strcmp(windowName, currentWindowName)
                 windowsPrefs{3,index} = leftPosition;
                 windowsPrefs{4,index} = bottomPosition;
                 save('ProgramData/PreferencesFile.mat',...
                    'allUsersPrefs', 'windowsPrefs', 'glob');
             end
         end
    end
    
    delete(gcf)

end % end CloseWindow
