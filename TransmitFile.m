function TransmitFile()
% TransmitFile transmits code from a user selected text file.

%% Initialize the user variables ----------------------------------
% Load the preferences file.
    load('ProgramData/PreferencesFile.mat', 'allUsersPrefs',...
        'windowsPrefs', 'glob');
    
% Load the codeTable file.
    load('ProgramData/CodeTableFile.mat', 'codeTable');

% Determine SelectedUser.
    for activeUserIndex = 2:size(allUsersPrefs,2)
        if allUsersPrefs{9,activeUserIndex} == 1
            break;
        end
    end
    
% Set up workspace variables.   
    userName = allUsersPrefs{1,activeUserIndex}; 
    stopXmit = 0;
    firstTime = 0;
    saveAudioFile = 0;
    firstXmitFile = 0;
    baseFileName = ' ';
    textFileToSend = [];
    audioFileToRecord = [];
    enableAction = 'off';
    windowTitle = 'Transmit from File:  Select a File';
    defaultString = 'First select a text file to send';
 
% Set some audio variables.
    frequency = allUsersPrefs{4,activeUserIndex};
    sampleRate = frequency*200; % 200 is samples per cycle

%% Set up main user interface  ------------------------------------
% Setup GUI parameters  
    windowWidth = windowsPrefs{5,4};
    windowHeight =  windowsPrefs{6,4};
    textFont = windowsPrefs{7,4};
    green = [.255 .627 .225];   
    white = [1  1  1];

%   figure window
    TransmitFileHandle = figure(...
        'CloseRequestFcn',@CloseRequestCallback,...
        'Units', 'Characters',...
        'Position',[windowsPrefs{3,4},windowsPrefs{4,4},...
            windowWidth,windowHeight],...
        'NumberTitle', 'off','MenuBar', 'none','Resize', 'off',...
        'DockControls', 'off','Toolbar', 'none','Color', white, ...
        'Name', 'Transmit File'...
    );
      
%   Set up Application title   
    TitleHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ 0 .89 1 .1 ],...
        'FontSize', textFont+2,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', windowTitle...
    );  

%   Transmitted Character Display    
    uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .02 .72 .2 .17 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'Character being Transmitted'...
    ); 
    
    XmitCharacterHandle = uicontrol('Style', 'text',...
        'Units', 'normalized',...
        'Position', [ .06 .25 .13 .45 ],...
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
        'Position', [ .4 .78 .3 .1 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','center',...
        'string', 'String Being Transmitted'...
    ); 

    XmitStringHandle = uicontrol('Style', 'edit',...
        'Units', 'normalized',...
        'Position', [ .25 .23 .7 .53 ],...
        'FontSize', textFont,'FontWeight','bold',...
        'BackgroundColor',white,'HorizontalAlignment','left',...
        'min',0,'max',10,'enable','inactive',...
        'string', defaultString...
    );

%% Action pushbuttons  --------------------------------------------
% Save an audio file of a transmitted text file in the users
% UserDirectory with the same name as the input text file
% but with a file tag of .wav - any existing file with
% the same name will be overwritten.
    uicontrol('Style', 'checkbox',...
        'Units', 'normalized',...
        'Position', [ .25 .06 .17 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',...
        'string', 'Save audio file',...
        'Callback', @CheckBoxCallback ...
    );


%   Select Mode pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .43 .06 .17 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',...   
        'string', 'Select Input File',...
        'Callback', @SelectInputFileCallback ...
    );

%   Start/Stop pushbutton
    StartStopHandle = uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .63 .06 .22 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',...
        'string', 'Start Transmission',...
        'Enable', enableAction,...
        'Callback', @StartStopCallback ...
    );
    
%   Exit pushbutton
    uicontrol('Style', 'pushbutton',...
        'Units', 'normalized',...
        'Position', [ .88 .06 .07 .1 ],...
        'FontSize', textFont-1,'FontWeight','bold',...
        'ForegroundColor', green,'HorizontalAlignment','center',... 
        'string', 'Exit',...
        'Callback', @CloseRequestCallback ...
    );

%%  Open Flasher window if enabled --------------------------------
    if glob.flasherEnabled == 1
        FlasherHandle = FlasherWindow();
        pause(.3);
        figure(TransmitFileHandle);
    end

%%  SelectInputFileCallback ---------------------------------------
    function SelectInputFileCallback(~, ~, ~)

        % ProcessInputFile - Function lets operator select
        % an input text file, converts it to upper case and
        % removes excess spaces.
        [textFileToSend, fileNameWithTag] = ...
            PreprocessInputFile(userName);

        if fileNameWithTag == ' ' % No file was selected
            return
        end

        % File was selected
        firstXmitFile = 1;
        [~, baseFileName, ~] = fileparts(fileNameWithTag);
        windowTitle = ['Transmit from File:  ' fileNameWithTag];
        set(StartStopHandle, 'Enable', 'on'),
        set(TitleHandle, 'string', windowTitle);
        set(XmitCharacterHandle, 'string', ' ' );
        set(XmitStringHandle, 'string', ' ' );

    end % end SelectInputFileCallback

%%  XmitFile ------------------------------------------------------
    function XmitFile
    %Transmits the chosen file.
    % Setup some variables
        persistent  charCount
        persistent  sentFileString
        numberToSend = size(textFileToSend,2);
        
        if firstXmitFile == 1
            sentFileString = [];
            charCount = 0;
            firstXmitFile = 0;
        end

        while stopXmit == 0

            charCount = charCount + 1;
            currentCharacter = textFileToSend(charCount);
            space = 0;
                for m=1:60
                    if currentCharacter == codeTable{m,1}
                        waveFile = codeTable{m,6};
                        currentCharacterName = codeTable(m,4);
                        codeGroup = codeTable{m,2};
                        if m == 60
                            space = 1;
                        end
                        break
                    end
                end

            sentFileString = [sentFileString ' ' currentCharacter];
            
            % Update the displays
            set(XmitCharacterNameHandle, 'string', currentCharacterName );
            set(XmitCharacterHandle, 'string', currentCharacter );
            set(XmitStringHandle, 'string', sentFileString );
            drawnow
            
            if glob.flasherEnabled == 1
                if space == 0
                    FlasherTask(FlasherHandle, glob.dotTime, codeGroup);
                end
            end
            
            % Transmit the character
            player = audioplayer(waveFile, sampleRate);
            playblocking(player);
                    
            % Write to the audio file if checked
            if saveAudioFile == 1
                audioFileToRecord = [audioFileToRecord, waveFile];              
            end

            % Exit when the end of file is reached
            if charCount > numberToSend
                stopXmit = 1;
            end
        end % end while stopXmit == 0
        
        % Save the audio file if it was generated
        if saveAudioFile == 1
            fileName = ['UserData/' userName '/' baseFileName '.wav'];
            audiowrite(fileName, audioFileToRecord, sampleRate);
        end

    % Stopped transmitting. Clear transmit character display of last
    % sent character
        if ishandle(XmitCharacterHandle)
            set(XmitCharacterHandle, 'string', ' ' );
            set(XmitCharacterNameHandle, 'string', ' ' );
        end
        stopXmit = 0;

    end % end XmitFile

%% StartStopCallback ----------------------------------------------
    function StartStopCallback(src, ~, ~)
        if firstTime == 0           
            firstTime = 1;
            set(src, 'string', 'Pause Transmission')
            XmitFile;                   
        else
            stopXmit = 1;
            firstTime = 0;
            set(src, 'string', 'Start Transmission')           
        end      
    end % end StartStopCallback

%% CheckBoxCallback -----------------------------------------------
    function CheckBoxCallback(src , ~)
        saveAudioFile = get(src,'Value');
    end % end CheckBoxCallback

%% CloseRequestCallback -------------------------------------------
    function CloseRequestCallback(~, ~)
        stopXmit = 1;

    % Close Flasher window if enabled
        if glob.flasherEnabled == 1
            if ishandle(FlasherHandle)
                pause(2);
                close(FlasherHandle);
            end
        end
        
    % Finish closing
        CloseWindow()
    end % end CloseRequestCallback

end % end TransmitFile