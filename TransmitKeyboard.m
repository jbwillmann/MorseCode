function TransmitKeyboard
% TransmitKeyboard transmits code from the keyboard

%% Initialize the user variables ----------------------------------
% Load the preferences file.
    load('ProgramData/PreferencesFile.mat', 'allUsersPrefs',...
        'windowsPrefs', 'glob');
    
% Load the CodeTableFile.
    load('ProgramData/CodeTableFile.mat', 'codeTable');

% Determine Selected User.
    for activeUserIndex = 2:size(allUsersPrefs,2)
        if allUsersPrefs{9,activeUserIndex} == 1
            break;
        end
    end
    
% Set some audio variables.
    frequency = allUsersPrefs{4,activeUserIndex};
    sampleRate = frequency*200; % 200 is samples per cycle

% Set up workspace variables.
    TimerHandle = [];
    transmittingOn = 0;
    characterInCount = 0;   % Number of valid Morse input characters typed
    sentKbdString = [];         % Transmitted string
    inputString = cell(3,1);    % Clear input array
    displayInputString = [];    % To display typed input
    defaultString = ['To send code just begin typing. '...
    'All input is converted to caps and the only special '...
    'keys accepted are backspace, escape and F5. '...
    'Use F5 to toggle transmit on and off. '...
    'Backspace will delete the last keyboard input '...
    'and Escape will clear all entries to start over.'];
    transmitControlOffString = ...
        'Use F5 to toggle Transmit On/Off. Current status - Off';
    transmitControlOnString = ...
        'Use F5 to toggle Transmit On/Off. Current status - On';
    
%% Set up main user interface  ------------------------------------
% Setup GUI parameters
    windowWidth = windowsPrefs{5,5};
    windowHeight =  windowsPrefs{6,5};
    textFont = windowsPrefs{7,5};
    green = [.255 .627 .225];
    white = [1  1  1];

%   figure window
    figure(...
        'CloseRequestFcn',@CloseRequestCallback,...
        'Units', 'Characters',...
        'Position',[windowsPrefs{3,5},windowsPrefs{4,5},...
            windowWidth,windowHeight],...
        'KeyPressFcn',@KeyPressCallback,...
        'NumberTitle', 'off','MenuBar', 'none','Resize', 'off',...
        'DockControls', 'off','Toolbar', 'none','Color', white, ...
        'Name', 'Transmit Keyboard'...
    );

%   Set up Application title
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .88 1 .1 ],...
        'FontSize', textFont+2,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Transmit from Keyboard'...
    );

% Transmit Control Display 
    XmitControlHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .78 1 .1 ],...
        'FontSize', textFont+1,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'ForegroundColor',green,...
        'string', transmitControlOffString...
    ); 
  
%   Transmitted Character Display    
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .02 .6 .2 .17 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Character being Transmitted'...
    ); 
    
    XmitCharacterHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .05 .23 .13 .38 ],...
        'FontSize', 6*textFont,'FontWeight','bold',...
        'BackgroundColor',green,'HorizontalAlignment','center',...
        'string', ' '...
    ); 

    XmitCharacterNameHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .02 .08 .2 .1 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Character Name '...
    ); 

%   Transmitted Character String Display   
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .4 .67 .3 .1 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'String Being Transmitted'...
    ); 

    XmitStringHandle = uicontrol('Style', 'edit',...
        'Units', 'normalized',...
        'Position', [ .25 .22 .7 .45 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','left',...
        'min',0,'max',10,'enable','inactive',...
        'string', defaultString...
    );
    
% Keyboard Input String Display 
     uicontrol('Style', 'text',...
         'Units', 'normalized',...
        'Position', [ .23 .07 .2 .1 ],...
        'FontSize', textFont+1,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Keyboard Input:'...
    ); 
    
    KbdStringHandle = uicontrol('Style', 'edit',...
        'Units', 'normalized',...
        'Position', [ .42 .07 .44 .1 ],...                  
        'FontSize', textFont+2,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','left',...
        'min',1,'max',1,'enable','inactive',...
        'string', ' '...
    );

%% Action pushbuttons  --------------------------------------------
%   Exit pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .88 .06 .07 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',... 
        'string', 'Exit',...
        'Callback', @CloseRequestCallback ...
    );

%% Set up a timer  ------------------------------------------------
    TimerHandle = timer(...
        'TimerFcn',@TimerTaskCallback,...
        'ExecutionMode','fixedSpacing',...
        'Period', .3 ...
    );

    % Start the timer task
        start(TimerHandle);

%% KeyPressCallback -----------------------------------------------
    function KeyPressCallback(~, evnt)
        keyIn = evnt.Key;
        % Clear all entries to start over if escape is pressed
        if strcmp(keyIn, 'escape')
            set(XmitCharacterHandle, 'string', ' ');
            set(XmitStringHandle, 'string', defaultString);
            set(KbdStringHandle, 'string', ' ');
            set(XmitControlHandle,'string', transmitControlOffString);
            transmittingOn = 0;
            characterInCount = 0;   % Number of valid input characters
            sentKbdString = [];         % Transmitted string
            inputString = cell(3,1);    % Clear input array          
            displayInputString = [];    % To display typed input
            drawnow nocallbacks 
            return
        end
        
        % Remove the last character if backspace is entered 
        % and there is a character to delete   
        if characterInCount > 0 && strcmp(keyIn, 'backspace')
            characterInCount = characterInCount-1;
            inputString = inputString(:,1:characterInCount);
            displayInputString = ...
                displayInputString(1,1:size(displayInputString,2) - 1);
            set(KbdStringHandle, 'string', displayInputString);
            drawnow nocallbacks 
            return
        end
        
        % If F5 is pressed toggle transmit on/off
        if strcmp(keyIn, 'f5')
            if transmittingOn == 0              
                transmittingOn = 1;
                set(XmitControlHandle,'string', transmitControlOnString);
            else
                transmittingOn = 0;
                set(XmitControlHandle,'string', transmitControlOffString);
                set(XmitCharacterHandle, 'string', ' ');
                set(XmitCharacterNameHandle, 'string', ' ' );
            end
            return   
        end
        
     %  A character has been typed that needs to be processed. 
     %  If it is a valid character. Convert to upper and find
     %  it in the CodeTable.   
        typedCharacter = upper(evnt.Character);
        Found = 0;
        % Look through the code table for the typed character
        for m=1:60
            if typedCharacter == codeTable{m,1}
                characterInCount = characterInCount+1;
                inputString{1,characterInCount} = typedCharacter; 
                inputString{2,characterInCount} = codeTable{m,6}; 
                inputString{3,characterInCount} = codeTable{m,4}; 
                Found = 1;
                break
            end
        end
        
        %  If it wasn't found get out and wait for the next one   
        if Found == 0
            return
        end
        
        % Display the character in the keyboard input display
        if characterInCount == 1    % First one
            displayInputString = typedCharacter;          
        else
            displayInputString = [displayInputString  typedCharacter];
        end
        set(KbdStringHandle, 'string', displayInputString);
        drawnow nocallbacks 
    end % end KeyPressCallback
 
%% TimerTaskCallback ----------------------------------------------
     function TimerTaskCallback(~,~)
    %   This task is entered by the timer every .3 seconds to see if a 
    %   new character has been added to InputString. If so it is
    %   transmitted and the SentCount is increased and the bufferString
    %   count is decreased. 
    
    % If transmitting is off then exit
        if transmittingOn == 0  
            return
        end
        
    % If there are no characters to transmit then exit
        if characterInCount < 1  
            % Clear transmit character display of last sent character
            set(XmitCharacterHandle, 'string', ' ');
            set(XmitCharacterNameHandle, 'string', ' ' );
            return
        end

    % We have a character to transmit. It's the first on the string
        characterIn = inputString{1,1};        
        waveFile = inputString{2,1};
        currentCharacterName = inputString{3,1};
        
    % remove the first entry and reduce the character count
        inputString = inputString(:,2:characterInCount);
        characterInCount = characterInCount - 1;
        
    % Remove the first character in the displayInputString and 
    % add to the output string
        displayInputString = ...
                displayInputString(1,2:size(displayInputString,2));           
        sentKbdString = [sentKbdString ' ' characterIn];
  
    % Update the displays
        set(KbdStringHandle, 'string', displayInputString);
        set(XmitCharacterHandle, 'string', characterIn);
        set(XmitCharacterNameHandle, 'string', currentCharacterName );
        set(XmitStringHandle, 'string',  sentKbdString );
        drawnow nocallbacks 

    % Transmit the character
        player = audioplayer(waveFile, sampleRate);
        playblocking(player);

     end % end TimerTaskCallback
                  
%% CloseRequestCallback -------------------------------------------
    function CloseRequestCallback(~, ~)
        % Stop the timer
        stop(TimerHandle);
        delete(TimerHandle);    
        CloseWindow();
    end % end CloseRequestCallback

end % end TransmitKeyboard