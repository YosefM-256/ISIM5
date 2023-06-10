function results = plothfeIcPNP_old_function(Vce, DAC1set, pathsNconsts, simulationVariables)
    arguments
        Vce                     double      {mustBeInRange(Vce,-10,0)}
        DAC1set                 double      {mustBeNonempty, mustBePositive, mustBeInRange(DAC1set,0,4095)}
        %VceTopBreachAction      string      {mustBeMember(VceTopBreachAction,["error", "return", "notice"])}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(DAC1set));
    DAC1set = DAC1set(end:-1:1);

    CResNum = 0;
    setCRes(CResNum);
    results = {};
    setDAC1(4095);
    setSystemMode('P');

    findInitialDAC1();
    DAC1set = cutDAC1set(DAC1set);

    for i=DAC1set
        setDAC1(i);
        msg = tuneToVce;
        if msg ~= "SUCCESS"
            results = cell2mat(results);
            return;
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables); %#ok<AGROW> 
    end
    results = cell2mat(results);

    function msg = tuneToVce()
        msg = tuneBy("Vce","DAC0",Vce,"direct",pathsNconsts,simulationVariables);
        if (msg ~= "SUCCESS") && (CResNum == 0)
            informLog(['TOP BREACH occured while trying to tune DAC0 for Vc=' num2str(Vce) ...
                '.Switching to Rc=10 Ohm']);
            setCRes(1);
            CResNum = 1;
            msg = tuneToVce();
        end
        if (msg ~= "SUCCESS") && (CResNum == 1)
            informLog(['the TOP BREACH for Vc=' num2str(Vce) ' repeated when Rc=10 Ohm']);
            return;
        end
    end

    function findInitialDAC1()
        assert(CResNum == 0, "CResNum should be 0 (RC = 1k)");
        setDAC0(4095);
        tuneBy("Vce","DAC1",Vce,"inverse",pathsNconsts,simulationVariables);
    end

    function DAC1set = cutDAC1set(DAC1set)
        assert(issorted(DAC1set,"descend"),"DAC1set should be in descending order");
        global DAC1;
        minIndex = find(DAC1set < DAC1);
        informLog(['the DACset will start from ' num2str(DAC1set(minIndex(1)))]);
        DAC1set = DAC1set(minIndex:end);
    end
end
