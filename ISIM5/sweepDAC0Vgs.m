function results = sweepDAC0Vgs(VgsList,DAC0set,pathsNconsts,simulationVariables)
    arguments
        VgsList                 double      {mustBePositive}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(VgsList),"VgsList must be sorted in ascending order");
    assert(issorted(DAC0set),"DAC0set must be sorted in ascending order");
    
    informProgress(['starting DAC0 sweep for NMOS']);
    addProgressIndent;

    setCRes(1);
    setSystemMode("N");
    results = {};
    
    for Vgs=VgsList
        result = struct();
        [VgsResult,msg] = IdVds(Vgs,DAC0set,pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            informLog(['abandoning Vgs plot with Vgs=' num2str(VgsList) '. A TOP BREACH occured']);
            results = cell2mat(results);
            return;
        end
        result.data = VgsResult;
        result.Vgs = Vgs;
        results{end+1} = result;
    end
    results = cell2mat(results);
    removeProgressIndent;
end

function [VgsResult, msg] = IdVds(Vgs,DAC0set,pathsNconsts,simulationVariables)
    informLog(["** starting [Id - Vds] plot for Vgs=" num2str(Vgs) " **"]);

    setCRes(1);
    VgsResult = {};
    msg = "SUCCESS";

    for i=DAC0set
        setDAC0(i);
        msg = tuneBy("Vbe","DAC1",Vgs,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    VgsResult = cell2mat(VgsResult);
    informProgress(['[Id - Vds](NMOS) plot completed for Vgs=' num2str(Vgs)]);
end