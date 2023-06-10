function results = plotIdVdsPMOS(VgsList,DAC0setRC0,DAC0setRC1,pathsNconsts,simulationVariables)
    arguments
        VgsList                 double      {mustBeNegative}
        DAC0setRC0              double      {mustBeNonempty, mustBePositive, mustBeInRange(DAC0setRC0,0,4095)}
        DAC0setRC1              double      {mustBeNonempty, mustBePositive, mustBeInRange(DAC0setRC1,0,4095)}
        pathsNconsts            struct
        simulationVariables     struct
    end
    informProgress("Starting [Id - Vds](PMOS) plot");
    addProgressIndent();

    setCRes(1);
    setSystemMode("P");
    results = {};
    
    for Vgs=VgsList
        result = struct();
        [VgsResult,msg] = IdVds(Vgs,DAC0setRC0,DAC0setRC1,pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            informLog(['abandoning Vgs plot with Vgs=' num2str(VgsList) '. A TOP BREACH occured']);
            results = cell2mat(results);
            return;
        end
        result.data = VgsResult;
        result.Vgs = Vgs;
        results{end+1} = result;
    end

    removeProgressIndent();
    results = cell2mat(results);
end

function [VgsResult, msg] = IdVds(Vgs,DAC0setRC0,DAC0setRC1,pathsNconsts,simulationVariables)
    informLog(["** starting [Id - Vds](PMOS) plot for Vgs=" num2str(Vgs) " **"]);

    setCRes(0);

    setDAC1(0);
    findInitialDAC0;
    DAC0setRC0 = cutDAC0set(DAC0setRC0);

    VgsResult = {};
    msg = "SUCCESS";

    for i=DAC0setRC0
        setDAC0(i);
        msg = tuneBy("Vbe","DAC1",Vgs,"direct",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end
   
    setCRes(1);

    setDAC1(0);
    findInitialDAC0;
    DAC0setRC1 = cutDAC0set(DAC0setRC1);

    for i=DAC0setRC1
        setDAC0(i);
        msg = tuneBy("Vbe","DAC1",Vgs,"direct",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    informProgress(["plotted for Vgs=" num2str(Vgs)])
    VgsResult = cell2mat(VgsResult);

    function findInitialDAC0
        msg = tuneBy("Vbe","DAC0",Vgs,"inverse",pathsNconsts,simulationVariables);
    end
end

function DAC0set = cutDAC0set(DAC0set)
    arguments
        DAC0set                 double      {mustBeNonempty, mustBePositive}
    end
    global DAC0;
    minIndex = find(DAC0set > DAC0);
    informLog(['the DACset will start from ' num2str(DAC0set(minIndex(1)))]);
    DAC0set = DAC0set(minIndex:end);
end