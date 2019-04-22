function  InitilizeProgram()
% InitilizeProgram - This function sets up all of the necessary default
% program data.

% Make sure there is a ProgramData directory
    if exist('ProgramData','dir') == 0
        newDir = 'ProgramData';
        dirMkStat = mkdir(newDir);
    end
    
% Create the default variable arrays allUsersPrefs, windowsPrefs and glob
% and save them to the PreferencesFile.mat file

    [allUsersPrefs, windowsPrefs, glob] = CreatePrefsArray();
    save('ProgramData/PreferencesFile.mat', 'allUsersPrefs',...
            'windowsPrefs','glob');
        
% Remove the old UserData directory and all files therein
    dirToRemove = 'UserData';
    dirRmStat = rmdir(dirToRemove, 's');
                
% Make a new directory with DefaultUser as a sub directory
    newDir = 'UserData/DefaultUser';
    dirMkStat = mkdir(newDir);

% Make a default Code Groups file
    codeGroups = ['OVLH MYBL URQXO HIKZO VICT. FINX SCXS HTYV IQGNT UBMPL '...
        'ABLB EJLN CY1ZB ZWCN, JNDZ U2TLZ KLAB4 DEFZ VNUW KFRE JICOY '...
        'TXSTY 38Ø95 RDIHA JXTDZ OXYDW XPZSY RSPHD 89706 CUSPI'];
    fid = fopen('UserData/DefaultUser/CodeGroups.txt', 'w');
    fprintf(fid, codeGroups);
    closeStat = fclose(fid);
end % end InitilizeProgram

