function setUpCirFile(pathsNconsts, variablesToSave)
    arguments
        pathsNconsts        struct
        variablesToSave     char
    end
    cirFileName = pathsNconsts.cirFileName;
    cirFile = fileread(cirFileName);
    splitCirfile = splitlines(string(cirFile));

    circuitParams = setUpParams(variablesToSave);
    for param = circuitParams
        paramIndex = find(contains(splitCirfile, param.lineInCirfile));
        splitCirfile(paramIndex) = param.lineInCirfile + num2str(param.value,8);
    end

    file = fopen(cirFileName, 'w');
    fprintf(file, strjoin(splitCirfile, "\n"));
    fclose(file);
end

function circuitParams = setUpParams(variablesToSave)
    global DAC0 DAC1;           % DACx has to be an integer
    global sMode;               % sMode is the mode of the switches (is an array of 4)
    
    % THAT COULD IMPROVE
    % confirms that the global variabels have been initialized
    globalCheck = find([isempty(DAC0), isempty(DAC1), isempty(sMode)],1);
    if globalCheck
        varsForError = ["DAC0" "DAC1" "sMode"];
        errorMSG = varsForError(globalCheck) + " is not initialized";
        error(errorMSG);
    end

    % makes sure all the global variables have valid values
    mustBeInteger(DAC0); mustBeInRange(DAC0,0,4095);
    mustBeInteger(DAC1); mustBeInRange(DAC1,0,4095);
    mustBeMember(sMode,[0 1]);
    assert(length(sMode) == 5);

    circuitParams = ...
        [struct( 'lineInCirfile', { ".PARAM DAC0Param=",".PARAM DAC1Param=",".PARAM S0state=", ...
                                    ".PARAM S1state=",".PARAM S2state=",".PARAM S3state=",".PARAM S4state="}, ...
                'value', {DACbinToVolt(DAC0), DACbinToVolt(DAC1), sMode(1), sMode(2), sMode(3), sMode(4), sMode(5)}), ...
         struct( 'lineInCirfile', ".SAVE ", 'value', variablesToSave)];

end