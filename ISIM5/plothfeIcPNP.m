function results = plothfeIcPNP(Vce, DAC0setRC0, DAC0setRC1, pathsNconsts, simulationVariables)
    arguments
        Vce                     double      {mustBeInRange(Vce,-10,0)}
        DAC0setRC0              double      {mustBeNonempty, mustBePositive, mustBeInRange(DAC0setRC0,0,4095)}
        DAC0setRC1              double      {mustBeNonempty, mustBePositive, mustBeInRange(DAC0setRC1,0,4095)}
        %VceTopBreachAction      string      {mustBeMember(VceTopBreachAction,["error", "return", "notice"])}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(DAC0setRC0));
    assert(issorted(DAC0setRC1));
    setSystemMode('P');
    results = {};

    setCRes(0);
    results = hfeIc(DAC0setRC0, results);
    setCRes(1);
    results = hfeIc(DAC0setRC1, results);

    results = cell2mat(results);
    
    %DAC1set = DAC1set(end:-1:1);
    function results = hfeIc(DAC0set, results)
        setDAC1(4095);
    
        findInitialDAC0();
        DAC0set = cutDAC0set(DAC0set);
    
        for i=DAC0set
            setDAC0(i);
            msg = tuneBy("Vce","DAC1",Vce,"inverse",pathsNconsts,simulationVariables);
            if msg ~= "SUCCESS"
%                 results = cell2mat(results);
                return;
            end
            results{end+1} = simulate(pathsNconsts,simulationVariables); %#ok<AGROW> 
        end
    end

    function msg = tuneToVce()
        msg = tuneBy("Vce","DAC1",Vce,"inverse",pathsNconsts,simulationVariables);
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

    function findInitialDAC0()
%         assert(CResNum == 0, "CResNum should be 0 (RC = 1k)");
        setDAC1(4095);
        tuneBy("Vce","DAC0",Vce,"inverse",pathsNconsts,simulationVariables);
    end

    function DAC0set = cutDAC0set(DAC0set)
        assert(issorted(DAC0set),"DACset should be sorted");
        global DAC0;
        minIndex = find(DAC0set > DAC0);
        informLog(['the DAC0set will start from ' num2str(DAC0set(minIndex(1)))]);
        DAC0set = DAC0set(minIndex:end);
    end
end
