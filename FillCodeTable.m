function  codeTable = FillCodeTable(codeSpeed, wordSpeed,...
                                frequency, samplesPerCycle)
% Creates the CodeTable and fills it with wave files based on the 
% code and word rate and frequenct.

%%  FillCodeTable Function ---------------------------------------
% Get the initial CodeTable setup
    codeTable = BuildCodeTable();

% Set wave parameters
        time = 1/codeSpeed;
        wordRate = wordSpeed/codeSpeed;

% Make wave samples
    %   Dit File
        amp = 1;
        dit = MakeWave(time, amp, frequency, samplesPerCycle ); 
    %   Daw File
        amp = 1;
        daw = MakeWave(3*time, amp, frequency, samplesPerCycle );
    %   Space
        amp = 0;
        space = MakeWave(time, amp, frequency, samplesPerCycle );
    %   Character Space
        amp = 0;
        characterSpace = MakeWave(3*time/wordRate, amp,...
            frequency, samplesPerCycle );
    %   Word Space
        amp = 0;
        wordSpace = MakeWave(6*time/wordRate, amp,...
            frequency, samplesPerCycle );

% Add wave files to the CodeTable array
    for count = 1:59
        characterCode = codeTable{count, 2};
        waveFile = MakeCharacter( characterCode, dit, daw,...
            space, characterSpace );
        codeTable{count,6} = waveFile;
    end

%  Add a WordSpace at the end
    codeTable{60,6} = wordSpace;
    
end % end FillCodeTable
    
%%  MakeCharacter Function ---------------------------------------
function waveFile = MakeCharacter( characterCode, dit, daw,...
                        space, characterSpace)
% MakeCharacter puts together the wave file of a 
% complete Morse character
    siz = size(characterCode,2); 
%   Initilize WaveFile
    waveFile = 0;
%   Make the WaveFile
    for count = 1:siz
        digit = characterCode(count);
        switch digit
            case '.'
                wavePart = [dit space]; 
            case '-'
                wavePart = [daw space];
        end 
        waveFile = [waveFile wavePart];              
    end
%   Put a character space at the end
    waveFile = [waveFile characterSpace];
end % end MakeCharacter Function

%%  MakeWave Function --------------------------------------------
function wavReturn = MakeWave(time, amp, freq, samplesPerCycle )
%   Created a wave file specified by the input parameters.
%   This section was changet to improve the audio quality.
%   Now the amplitude of each tone has a gradual increase at the
%   beginning and a gradual decrease at the end.  This reduces
%   harmonics and mahes a more pleasant sound.

    length = round(time*freq*samplesPerCycle);  % Length of the tone.
    sig = zeros(1,length);                      % Initilize the array.
    co = 6;                                     % # of cycles for ramp.
    ro = co*samplesPerCycle;                    % Data points in ramp.

    for n = 1:length
        if n < ro                               % Starting ramp
            mplier = n/ro;
        end
        if n > length-ro                        % Finishing ramp.
            mplier = (length-n)/ro;
        end
        sig(n) = amp*mplier*sin(2*pi*(n/samplesPerCycle));
        mplier = 1;
    end
    wavReturn = sig ;
end % end MakeWave Function

