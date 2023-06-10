function results = plotIcVcePNP(Ibs,DAC0set,pathsNconsts,simulationVariables)
    arguments
        Ibs                     double      {mustBeNonempty, mustBeNegative}
        DAC0set                 double      {mustBeNonempty, mustBePositive, mustBeInteger}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(Ibs,"descend"),"The 'Ibs' argument must be in ascending order");
    
    informLog("starting [Ic - Vce](PNP) plot");
    informProgress("starting [Ic - Vce](PNP) plot");
    addProgressIndent;

    results = {};
    for Ib = Ibs
        informLog(['starting plot for Ib=' num2str(Ib)]);
        result = struct();
        [IbResult, msg] = IcVce(Ib,DAC0set,pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            informLog(['abandoning Ib plot with Ib=' num2str(Ib) '. A ' msg ' occured']);
            results = cell2mat(results);
            return;
        end
        result.data = IbResult;
        result.Ib = Ib;
        results{end+1} = result;
    end
    results = cell2mat(results);
    removeProgressIndent;

end

function [results,msg] = IcVce(Ib,DAC0set,pathsNconsts,simulationVariables)
    arguments 
        Ib                      double      {mustBeNegative}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    setSystemMode("P");
    setCRes(1);
 
    setDAC1(0);
    setClevel(1);
    findInitialDAC0();
    DAC0setHC = cutDAC0set(DAC0set);

    informLog(["starting with high collector"]);
    informLog(['-']);

    results = {}; 
    for i=DAC0setHC
        setDAC0(i);
        msg = tuneBy("Ib","DAC1",Ib,"direct",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            informLog(['unable to establish Ib=' num2str(Ib) '. Abandoning plot.']);
            results = 0;
            return;
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end

    lastVce = results{end}.Vc - results{end}.Ve;
    setClevel(0);
    setDAC1(4095);
    tuneBy("Vce","DAC0",lastVce,"inverse",pathsNconsts,simulationVariables);
    DAC0setLC = cutDAC0set(DAC0set);

    informLog(["switched to grounded collector"]);
    informLog(['-']);

    for i=DAC0setLC
        setDAC0(i);
        msg = tuneBy("Ib","DAC1",Ib,"direct",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            informLog(['A' msg 'occured. Aborting']);
            results = 0;
            return;
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end

    results = cell2mat(results);
    informProgress(['[Ic - Vce](PNP) plot completed for Ib=' num2str(Ib)]);

    function findInitialDAC0()
        setCRes(1);
        msg = tuneBy("Vce","DAC0",0,"inverse",pathsNconsts,simulationVariables);
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