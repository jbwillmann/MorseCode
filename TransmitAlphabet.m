function TransmitAlphabet()
% TransmitAlphabet transmits the alphabet from the codeTable

%% Initilize the user variables -----------------------------------
% Load the preferences file.
    load('ProgramData/PreferencesFile.mat', 'allUsersPrefs', 'windowsPrefs', 'glob');
    
% Load the codeTable file.
    load('ProgramData/CodeTableFile.mat', 'codeTable');

% Determine SelectedUser.
    for activeUserIndex = 2:size(allUsersPrefs,2)
        if allUsersPrefs{9,activeUserIndex} == 1
            break;
        end
    end
    
% Set up workspace variables.
    alphaPrefs = allUsersPrefs{5,activeUserIndex};
    stopXmit = 0;
    firstTime = 0;
    
% Set up alphabet preferences
    switch alphaPrefs.include
        case 1  % Alphabet = 26
            alphaChosen = 'Alphabet Only';
            stopCount = 26;
        case 2  % Plus Numbers = 36
            alphaChosen = 'Alphabet + Numbers';
            stopCount = 36;
        case 3  % Plus Puncuation = 53
            alphaChosen = 'Alpha + Num + Puncuation';
            stopCount = 53;
        case 4  % Plus Special Characters = 59
            alphaChosen = 'Alpha + Num + Puncuation + Special';
            stopCount = 59;
    end
    
    if alphaPrefs.format == 1
        alphaMode = 'Continuous';
    else
        alphaMode = 'Random';
    end

    if alphaPrefs.group == 1
        isGroupName = 'No Groups';
    else
        isGroupName = 'Groups';
        currentGroupSize = alphaPrefs.min;
    end

    moseDisplay = ['Mode:  '  alphaChosen ' -  ' ...
        alphaMode ' -  ' isGroupName];
    enableAction = 'on';
    firstXmitAlpha = 0;
    defaultString = [];

% Set some audio variables.
    frequency = allUsersPrefs{4,activeUserIndex};
    sampleRate = frequency*200; % 200 is samples per cycle
    
%% Set up main user interface  ------------------------------------
% Setup GUI parameters     
    windowWidth = windowsPrefs{5,3};
    windowHeight =  windowsPrefs{6,3};
    textFont = windowsPrefs{7,3};
    green = [.255 .627 .225];   
    white = [1  1  1]; 
    
%   figure window
    AlphabetWinHandle = figure(...
        'CloserequestFcn',@CloseRequestCallback,...
        'Units', 'Characters',...
        'Position', [ windowsPrefs{3,3}, windowsPrefs{4,3},...
            windowWidth, windowHeight],...
        'NumberTitle', 'off','MenuBar', 'none','Resize', 'off',...
        'DockControls', 'off','Toolbar', 'none','Color', white, ...
        'Name', 'Transmit Alphabet'...
    );
      
%   Set up Application title
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .89 1 .1 ],...
        'FontSize', textFont+2,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Transmit Alphabet'...
    );

%   Set up Mode Display   
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .80 1 .1 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', moseDisplay...
    ); 
   
%   Transmitted Character Display    
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .02 .65 .2 .17 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...            
        'string', 'Character being Transmitted'...
    ); 
    
    XmitCharacterHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .05 .20 .13 .45 ],...
        'FontSize', 6*textFont,'FontWeight','bold',...
        'BackgroundColor',green,'HorizontalAlignment','center',...
        'string', ' '...
    ); 

    XmitCharacterNameHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .01 .08 .2 .1 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Character Name'...
    ); 

%   Transmitted Character String Display   
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .4 .65 .3 .1 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',... 
        'string', 'String Being Transmitted'...
    ); 

    XmitStringHandle = uicontrol('Style', 'edit',...
        'Units', 'normalized',...
        'Position', [ .25 .20 .7 .45 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','left',...
        'min',0,'max',10,'enable','inactive',...
        'string', defaultString...
    );

%% Action pushbuttons  --------------------------------------------
%   Select Mode pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .25 .06 .15 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',...    
        'string', 'Select Mode',...
        'Callback', @SelectModeCallback ...
    );

%   Start/Stop pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .51 .06 .22 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',... 
        'string', 'Start Transmission',...
        'Enable', enableAction,...
        'Callback', @StartStopCallback ...
    );
    
%   Exit pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .85 .06 .1 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',... 
        'string', 'Exit',...
        'Callback', @CloseRequestCallback ...
    );
        
%%  Xmit Alphabet Processing --------------------------------------
% This function is called by the StartStopCallback when the 
% Start Transmission button is selected
    function XmitAlphabet
        
        isRandom = alphaPrefs.format;   % 1 = continuous; 2 = random
        isGroup = alphaPrefs.group;     % 1 = no group; 2 = group
        groupMin = alphaPrefs.min;      % group minimum size
        groupMax = alphaPrefs.max;      % group maximum size

        persistent characterIndex sentString groupCount 
        
        if firstXmitAlpha == 0
            sentString = [];
            characterIndex = 0;
            firstXmitAlpha = 1;
            groupCount = 0;
        end
        
    %  Output the CodeTable a character at a time;
        previousCharacterIndex = 0;

        while stopXmit == 0
            if isRandom == 1    % Sequential
                characterIndex = characterIndex + 1;
                if characterIndex > stopCount
                    characterIndex = 1;
                end
            else    % Random
                characterIndex = randi(stopCount);
                if characterIndex == previousCharacterIndex
                    characterIndex = randi(stopCount);
                end
                previousCharacterIndex = characterIndex;
            end
            
            if isGroup == 2 % Make groups
                groupCount = groupCount + 1;
                if groupMin == groupMax  % Fixed group Size           
                    if groupCount > groupMax% Send a space
                        saveCharacterIndex = characterIndex;
                        characterIndex = 60;
                        groupCount = 0;
                    end
                else    % Random group size
                    if groupCount > currentGroupSize  % Send a space
                        saveCharacterIndex = characterIndex;
                        characterIndex = 60;
                        groupCount = 0;
                        currentGroupSize = randi([groupMin,groupMax]);
                    end
                end
            end

            currentCharacter = codeTable{characterIndex,1};
            currentCharacterName = codeTable{characterIndex,4};
            sentString = [sentString ' ' currentCharacter];
            
            % Update the displays
            set(XmitCharacterHandle, 'string', currentCharacter );
            set(XmitCharacterNameHandle, 'string', currentCharacterName );
            set(XmitStringHandle, 'string', sentString );
            drawnow

            % Transmit the character
            player = audioplayer(codeTable{characterIndex,6}, sampleRate);
            playblocking(player);
            
            if characterIndex == 60
                characterIndex = saveCharacterIndex-1;
            end
        end
        
        stopXmit = 0;
        
    end

%%  SelectModeCallback --------------------------------------------
    function SelectModeCallback(~, ~, ~)
        if activeUserIndex == 2
            messageString = [' Cant change Default User.',...
                ' Change to another user or add a new user',...
                ' from main window drop down menu - User Preferences'];
            WarningWindow(windowsPrefs,messageString);
            return
        else
           AlphabetPreferences(AlphabetWinHandle);
        end
    end

%% StartStopCallback callback -------------------------------------
    function StartStopCallback(src, ~, ~)
        if firstTime == 0           
            firstTime = 1;           
            set(src, 'string', 'Pause Transmission')
            XmitAlphabet;
        else
            stopXmit = 1;
            firstTime = 0;
            set(src, 'string', 'Start Transmission')           
        end       
    end

%% CloseRequestCallback -------------------------------------------
    function CloseRequestCallback(~, ~)
        stopXmit = 1;
        CloseWindow()
    end

end % end TransmitAlphabet