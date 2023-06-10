function results = sweepDAC0Vgs(VgsList,DAC0set,pathsNconsts,simulationVariables)
    arguments
        VgsList                 double      {mustBePositive}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    informProgress(['starting [Id - Vds](NMOS) plot']);
    addProgressIndent;

    setCRes(1);
    setEpwr(0);
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