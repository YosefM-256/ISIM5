function results = plotIdVgsPMOS(Vds, DAC1set, VdsTopBreachAction, pathsNconsts, simulationVariables)
    arguments
        Vds                     double      {mustBeInRange(Vds,-10,0)}
        DAC1set                 double      {mustBeNonempty, mustBePositive}
        VdsTopBreachAction      string      {mustBeMember(VdsTopBreachAction,["error", "return", "notice"])}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(DAC1set),"DAC1set must be in ascending order");
    informLog(["** starting [Id - Vgs](PMOS) plot for Vds=" num2str(Vds) " **"]);
    
    setSystemMode("P");
    setClevel(0);
    CResNum = 0;
    setCRes(CResNum);
    results = {};

    findInitialDAC1;
    DAC1set = cutDAC1set(DAC1set);
    DAC1set = DAC1set(end:-1:1);

    for i=DAC1set
        setDAC1(i);
        msg = tuneToVds;
        if msg ~= "SUCCESS"
            if VdsTopBreachAction == "error"
                informLog("FATAL ERROR: TOP BREACH occured while tuning Vds in [Id - Vgs](PMOS) plot");
                informLog("***");
                error("TOP BREACH occured while tuning Vds to %d",Vds);
            end
            if VdsTopBreachAction == "return"
                results = cell2mat(results);
                informLog("ERROR: [Id - Vgs](PMOS) plot has ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vds. The program will continue to run");
                informProgress("finished [Id - Vgs](PMOS) plot successfully");
                return;
            end
            if VdsTopBreachAction == "notice"
                results = cell2mat(results);
                informLog("ERROR: [Id - Vgs] plot was ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vds. The program will continue to run");
                informLog("the option VdsTopBreachAction=notice is not defined yet");
                results = cell2mat(results);
                return;
            end
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end

    informProgress("finished [Id - Vgs](PMOS) plot successfully");
    results = cell2mat(results);

    function msg = tuneToVds
        msg = tuneBy("Vce","DAC0",Vds,"inverse",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS" && CResNum == 0
            informLog(['a TOP BREACH occured while trying to tune DAC0 for Vds=' num2str(Vds) ...
                '.Switching to Rc=10 Ohm']);
            CResNum = 1;
            setCRes(CResNum);
            msg = tuneToVds;
        end
        if msg ~= "SUCCESS" && CResNum == 1
            informLog(['the TOP BREACH for Vc=' num2str(Vds) ' repeated when Rc=10 Ohm']);
            msg = "TOP BREACH";
            return;
        end
    end

    function findInitialDAC1
        setCRes(1);
        setDAC1(4095);
        msg = tuneBy("Vce","DAC0",Vds,"inverse",pathsNconsts,simulationVariables);
        assert(msg == "SUCCESS");
        msg = tuneBy("Vbe","DAC1",0,"direct",pathsNconsts,simulationVariables);
        assert(msg == "SUCCESS");
        return;
    end

    function DAC1set = cutDAC1set(DAC1set)
        global DAC1;
        maxIndex = find(DAC1set > DAC1);
        informLog(['the DAC1set will start from ' num2str(DAC1set(maxIndex(1)))]);
        DAC1set = DAC1set(1:maxIndex);
    end


end

