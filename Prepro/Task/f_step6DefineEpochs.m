function [status, EEG, newEpochRange, newEventName] = f_step6DefineEpochs(pathStep5, nameStep5, epochRange, eventName)
%Description:
%Function that defines the epochs of the marked .set given (without noisy components, and with interpolated bad channels)
%INPUTS:
%pathStep5 = Path of the .set with interpolated bad channels
%nameStep5 = Name of the .set with interpolated bad channels
%epochRange = Vector of 2x1 with the times (in s) [start end] relative to the time-locking event. ([] by default)
%eventName = Cell with the Name(s) of the event(s) of interest. ('' by default)
%   It can also be a string with the unique event of interest
%   If there is more than one event, asks the user which is the event of interest.
%   If there is only one event, takes that event as the one of interest.
%OUTPUTS:
%stauts = 1 if this script was completed succesfully. 0 otherwise.
%EEG = EEGLab structure after performing the definition of epochs
%newEpochRange = Vector of [2,1] with the times [start, end] (in seconds) that was actually considered to epoch the data
%newEventName = Cell with the name(s) of the event(s) that was/were actually used (or the last try to use) to epoch

%Defines the default inputs
if nargin < 3
    epochRange = [];
end
if nargin <4
    eventName = '';
end
status = 1;
newEventName = eventName;
newEpochRange = epochRange;

%Loads the .set
EEG = pop_loadset('filename', nameStep5, 'filepath', pathStep5);
allEventNames = {EEG.event(:).type};


%If there is no epoch range, ask the user to enter it.
if isempty(epochRange) || length(epochRange) ~= 2
    %Asks the user to enter the epoching interval
    disp('WARNING: There was no "epochRange" given when executing this function');
    disp('Please enter the range of time (in seconds) to epoch the data (can be negative, relative to the time-locked event)');
    disp('Please enter the lower bound of the time range (in seconds, as a number and decimals separated by .):');
    lowerBound = input('', 's');

    %Considers the case in which the user does not provide a valid input
    lowerBound = str2double(lowerBound);
    if isnan(lowerBound)
        disp('ERROR: Please enter a number, with decimals separated by point');
        disp('Do you want to try running this script again? (y/n)');
        runAgain = input('', 's');
        if strcmpi(runAgain, 'y')
            [status, EEG, newEpochRange, newEventName] = f_step6DefineEpochs(pathStep5, nameStep5, newEpochRange, eventName);
        else
            status = 0;
        end
        return
    end

    disp('Please enter the higher bound of the time range (in seconds, as a number and decimals separated by .):');
    higherBound = input('', 's');
    %Considers the case in which the user does not provide a valid input
    higherBound = str2double(higherBound);
    if isnan(higherBound) || higherBound <= lowerBound
        disp(strcat('ERROR: Please enter a number, with decimals separated by point AND greater than: ', num2str(lowerBound)));
        disp('Do you want to try running this script again? (y/n)');
        runAgain = input('', 's');
        if strcmpi(runAgain, 'y')
            [status, EEG, newEpochRange, newEventName] = f_step6DefineEpochs(pathStep5, nameStep5, newEpochRange, eventName);
        else
            status = 0;
        end
        return
    end

    %Finally, define the given outputs as the baselineRange vector
    newEpochRange = [lowerBound, higherBound];
end

%Checks how many different types of events this .set has
try         %Try finding the unique values as a cell (if there are strings)
    uniqueEvents = unique(allEventNames);
catch       %If there are numbers, convert them into strings
    nAll = length(allEventNames);
    for i = 1:nAll
        if isnumeric(allEventNames{i})
            allEventNames{i} = num2str(allEventNames{i});
        end
    end
    uniqueEvents = unique(allEventNames);
end


%If it is empty, send an error message
if isempty(uniqueEvents)
    disp('ERROR: The given .set does not contain any events. Please make sure that the step0 was run, and re-run steps 1-4 again');
    disp('NOTE: You could modify f_step6DefineEpochs to run step0 if it does not have any markings, but that is left for future versions');
    status = 0;
    return;
end

%If no event label is given, and there is more than one event label type, send a warning message
%(it will be managed differently depending on the number of different event types)
isMember = true;
if isempty(eventName) && (length(uniqueEvents) ~= 1) || iscell(eventName) && isempty(eventName{1}) && (length(uniqueEvents) ~= 1)
    fprintf('WARNING: No event name was given. The dataset has the following event names:\n');
    disp(uniqueEvents);
    isMember = false;

%If the user gives eventName as a cell (ideally for multiple events), check that ALL of them exist in the .set
%If any eventName DOES NOT EXIST, send a warning. Will ask for eventName again
elseif iscell(eventName)
    for i = 1:length(eventName)
        iEvent = eventName{i};
        if ~ischar(iEvent)  %If the event was given as a number, transform it to a char
            eventName{i} = char(string(iEvent));
            iEvent = eventName{i};
        end
        if ~ismember(iEvent, uniqueEvents)
            fprintf('WARNING: The event name: %s was given, but the dataset only has the following event names:\n', eventName{i});
            disp(uniqueEvents);
            isMember = false;
            break
        end
    end
    
%If the label given by parameter is a char, convert it to a cell.
%If it does not exist in the .set, send a warning message 
elseif ischar(eventName)
    eventName = {eventName};
    if ~ismember(eventName{1}, uniqueEvents)
        fprintf('WARNING: The event name: %s was given, but the dataset only has the following event names:\n', eventName{1});
        disp(uniqueEvents);
        isMember = false;
    end
    
%If the label given by parameter is not a char (e.g. a vector of numbers), transform it to a cell of chars. 
%If does not exist in the .set, send a warning message 
elseif ~ischar(eventName)
    tempEventName = {};
    for i = 1:length(eventName)
        tempEventName{i} = char(string(eventName(i)));
        if ~ismember(tempEventName{i}, uniqueEvents)
            fprintf('WARNING: The event name: %s was given, but the dataset only has the following event names:\n', tempEventName{i});
            disp(uniqueEvents);
            isMember = false;
            break
        end
    end
    eventName = tempEventName;
end


%Finally, performs the definition of epochs
if ~isMember
    %If the given event name is not in the .set, but the .set only has ONE event, assume that it is a heartbeat
    if (length(uniqueEvents) == 1)
        fprintf('Assuming that the event name of your interest is %s \n', uniqueEvents{1});
        EEG = pop_epoch( EEG, uniqueEvents(1), newEpochRange, 'epochinfo', 'yes');
        newEventName = uniqueEvents(1);
        
    else
        %Else if the given event name is not in the .set, and it has MULTIPLE events, 
        %ask the user to specify which event corresponds to the heartbeat
        disp('Please enter the name of the event that you want to analyse (see list of events above, or press q if you do not know)');
        disp('TIP: You can also enter multiple events separated by a comma (e.g.: event1, event2)');
        realEventName = input('', 's');
        if strcmpi(realEventName, 'q')
            disp('Please check which event you want to analyse, and run the script again');
            status = 0;
            return;
            
        else
            %Try to separate the input where there is a comma (',')
            realEventName = strsplit(realEventName, ',');
            
            %For all the eventNames given by input, check if they exist
            for i = 1:length(realEventName)
                %Check that the i-th event the user prompted exists in the given dataset, and give them the opportunity to run the script again
                realEventName{i} = strtrim(realEventName{i});
                if sum(strcmp(realEventName{i}, uniqueEvents)) == 0
                    disp('ERROR: The name of the event that you entered does not exist in the given .set');
                    disp('The events of this dataset are:');
                    disp(uniqueEvents);
                    disp('Do you want to run this function again (y), or skip to the next subject (any other key)?');
                    repeatScript = input('', 's');
                    if strcmpi(repeatScript, 'y')
                        [status, EEG, newEpochRange, newEventName] = f_step6DefineEpochs(pathStep5, nameStep5, newEpochRange, eventName);
                    else
                        status = 0;
                    end
                    return
                end
            end
                
            %If all the events entered by the user exist, epoch the .set with the info provided
            EEG = pop_epoch( EEG, realEventName, newEpochRange, 'epochinfo', 'yes');
            newEventName = realEventName;
        end
    end
    
else
    %If the given event name does exist, just define the epochs
    newEventName = eventName;
    EEG = pop_epoch( EEG, newEventName, newEpochRange, 'epochinfo', 'yes');
end

EEG = eeg_checkset(EEG);

disp('Defined the epochs with the time-locked event(s):');
disp(newEventName);
fprintf('With a duration of [%.3f, %.3f] seconds around the event\n', newEpochRange);

end