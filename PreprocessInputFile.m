function [upperText, fileNameWithTag] = PreprocessInputFile(userName)
% PreprocessInputFile This function takes the input file and converts all
% characters to upper case and removes extra spaces if there are 
% more than 2 in a row and removes all spaces at the end of the file.

%   Get the file from the operator
    startDirectory = cd;

    [fileNameWithTag, fileDirectory] = uigetfile({'*.txt'},...
        'Select a Text file',...
        [startDirectory  '/UserData/' userName '/']);
    if fileNameWithTag == 0  % User canceles - display error message
            upperText = ' ';
            fileNameWithTag = ' ';
        return
    end
    filePath = [fileDirectory  fileNameWithTag];
        
%   Load the file
    inputFile = fileread(filePath);
        
%   Convert all text to upper
        upperText = upper(inputFile);
%     %   Find the space characters in the file
%         spaceData = isspace(upperText);
%     %   Get the length of the file
%         inputSize = size(upperText,2);
%         spaceCount = 0;
%         outputCount = 0;
% 
%     for i=1:inputSize
% %                vvv = abs(upperText(1,i))
%         if spaceData(1,i) == 0
%             outputCount = outputCount+1;
%             currentCharacter = upperText(1,i);
%             if abs(upperText(1,i)) == 8217
%                 currentCharacter = '''';
%             end
% 
%             textToSend(outputCount) = currentCharacter; 
%             spaceCount = 0;
%         else
%            if spaceCount == 0
%                 outputCount = outputCount+1;
%                 textToSend(outputCount) = ' ';
%                 spaceCount = spaceCount+1;
%             end
%         end  
%         
%     end % end for
%         
%     if textToSend(outputCount) == ' '
%         textToSend(outputCount) = [];
%     end
    
end % end PreprocessInputFile

