function results = plotIdVgs(Vds, VgsSet, VdsTopBreachAction, pathsNconsts, simulationVariables)
    arguments
        Vds                     double      {mustBeInRange(Vds,0,10)}
        VgsSet                  double      {mustBeNonempty, mustBePositive}
        VdsTopBreachAction      string      {mustBeMember(VdsTopBreachAction,["error", "return", "notice"])}
        pathsNconsts            struct
        simulationVariables     struct
    end
    informLog(["** starting [Id - Vgs](NMOS) plot for Vds=" num2str(Vds) " **"]);
    
    CResNum = 0;
    setCRes(CResNum);
    results = {};
    setSystemMode("N");

    for i = VgsSet
        setDAC1(i);
        msg = tuneToVds;
        if msg ~= "SUCCESS"
            if VdsTopBreachAction == "error"
                informLog("FATAL ERROR: TOP BREACH occured while tuning Vds in [Id - Vgs](NMOS) plot");
                informLog("***");
                informProgress("[Id - Vgs](NMOS) graph could not finish. Simulation stopped");
                error("TOP BREACH occured while tuning Vds to %d",Vds);
            end
            if VdsTopBreachAction == "return"
                results = cell2mat(results);
                informLog("ERROR: [Id - Vgs](NMOS) plot was ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vds. The program will continue to run");
                informProgress("[Id - Vgs](NMOS) successufully finished");
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
    results = cell2mat(results);
    informProgress("[Id - Vgs](NMOS) graph successufully finished");

    function msg = tuneToVds
        informLog("finding maximum DAC1 to start the DAC1set from");
        msg = tuneBy("Vce","DAC0",Vds,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && CResNum == 0
            informLog(['a TOP BREACH occured while trying to tune DAC0 for Vds=' num2str(Vds) ...
                '.Switching to Rc=10 Ohm']);
            CResNum = 1;
            setCRes(CResNum);
            msg = tuneToVds;
        end
        if msg == "TOP BREACH" && CResNum == 1
            informLog(['the TOP BREACH for Vce=' num2str(Vds) ' repeated when Rc=10 Ohm']);
            msg = "TOP BREACH";
            return;
        end
    end
end