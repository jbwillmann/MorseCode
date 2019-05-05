function myReturn = FlasherTask(FlasherHandle, dotTime, codeGroup)
%FlasherTask Controls the display in the Flasher window.
%   Detailed explanation goes here

%% Initialize the user variables ----------------------------------
    myReturn = 0;

    green = [.255 .627 .225];     
    white = [1  1  1]; 
    dotTime = dotTime+.02;
    numberCharacters = size(codeGroup, 2);
    characterCount = 1;
    firstDigit = codeGroup(characterCount);
        switch firstDigit
            case '.'
                flashTime = dotTime; 
            case '-'
                flashTime = 3*dotTime;
        end 
        
        set(FlasherHandle, 'Color', green);

    startFlash = 0;
    
%% Set up a timer  ------------------------------------------------
    TimerHandle = timer(...
        'TimerFcn', @TimerTaskCallback,...
        'StartDelay', flashTime ...
    );

    % Start the timer task
        start(TimerHandle);    
    
%% TimerTaskCallback ----------------------------------------------
    function TimerTaskCallback(~,~)

        if numberCharacters == characterCount 
            set(FlasherHandle, 'Color', white);
            stop(TimerHandle);
            delete(TimerHandle);
            return
        end
        
        if startFlash == 0
            set(FlasherHandle, 'Color', white);
            stop(TimerHandle);
            delete(TimerHandle);
            
            TimerHandle = timer(...
                'TimerFcn', @TimerTaskCallback,...
                'StartDelay', dotTime ...
            );      
            start(TimerHandle);
            startFlash = 1;
            return
        end
        characterCount = characterCount + 1;          
        nextDigit = codeGroup(characterCount);
        switch nextDigit
            case '.'
                flashTime = dotTime; 
            case '-'
                flashTime = 3*dotTime;
        end
        set(FlasherHandle, 'Color', green);
        stop(TimerHandle);
        delete(TimerHandle);
            
        TimerHandle = timer(...
            'TimerFcn', @TimerTaskCallback,...
            'StartDelay', flashTime ...
        );     
        start(TimerHandle);
        startFlash = 0;
        
    end % end TimerTaskCallback

end % end FlasherTask

