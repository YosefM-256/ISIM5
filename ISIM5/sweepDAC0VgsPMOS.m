function results = sweepDAC0VgsPMOS(VgsList,DAC0set,pathsNconsts,simulationVariables)
    arguments
        VgsList                 double      {mustBeNegative}
        DAC0set                 double      {mustBeNonempty, mustBePositive,mustBeInRange(DAC0set,0,4095)}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(DAC0set), "The DAC0set must be in ascending order")
    assert(issorted(VgsList,'descend'), "The Vgs set must be in descending order");

    informProgress("Starting DAC0 sweep for fixed values of Vgs for PMOS");
    addProgressIndent();
    
    setSystemMode('P');
    setCRes(1);
    results = {};
    
    for Vgs=VgsList
        result = struct();
        [VgsResult,msg] = IdVds(Vgs,DAC0set,pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            informLog(['abandoning Vgs plot with Vgs=' num2str(Vgs) '. A TOP BREACH occured']);
            informProgress(['DAC0 sweep for Vgs=' num2str(Vgs) ' was abandoned'])
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

function [VgsResult, msg] = IdVds(Vgs,DAC0set,pathsNconsts,simulationVariables)
    informLog(["** starting PMOS DAC0 sweep for Vgs=" num2str(Vgs) " **"]);

    setDAC1(0);
    setClevel(1);
    findInitialDAC0();
    DAC0setHC = cutDAC0set(DAC0set);
    VgsResult = {};
    msg = "SUCCESS";

    for i=DAC0setHC
        setDAC0(i);
        msg = tuneBy("Vbe","DAC1",Vgs,'direct',pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end

    lastVce = VgsResult{end}.Vc - VgsResult{end}.Ve;
    setClevel(0);
    setDAC1(4095);

    tuningMsg = tuneBy("Vce","DAC0",lastVce,"inverse",pathsNconsts,simulationVariables);
    assert(tuningMsg == "SUCCESS");
    VceDAC0requirement = getDAC(0);
    setDAC1(0);
    tuningMsg = tuneBy("Vbe","DAC0",Vgs,"inverse",pathsNconsts,simulationVariables);
    assert(tuningMsg == "SUCCESS");
    VbeDAC0requirement = getDAC(0);
    DAC0start = max(VceDAC0requirement,VbeDAC0requirement);
    setDAC0(DAC0start);

    DAC0setLE = cutDAC0set(DAC0set);

    informLog(["switched to grounded emitter"]);
    informLog(['-']);

    for i=DAC0setLE
        setDAC0(i);
        msg = tuneBy("Vbe","DAC1",Vgs,"direct",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end

    informProgress(["finished DAC0 sweep for Vgs=" num2str(Vgs)])
    VgsResult = cell2mat(VgsResult);

    function findInitialDAC0()
        setCRes(1);
        msg = tuneBy("Vce","DAC0",0,"inverse",pathsNconsts,simulationVariables);
    end

    function state = getDAC(DACnum)
        if DACnum == 0
            global DAC0; state = DAC0;
        elseif DACnum == 1
            global DAC1; state = DAC1;
        end
    end
end

function DAC0set = cutDAC0set(DAC0set)
    arguments
        DAC0set                 double      {mustBeNonempty, mustBePositive}
    end
    global DAC0;
    minIndex = find(DAC0set > DAC0);
    informLog(['the DAC0set for high emitter will start from ' num2str(DAC0set(minIndex(1)))]);
    DAC0set = DAC0set(minIndex:end);
end