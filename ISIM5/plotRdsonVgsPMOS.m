function results = plotRdsonVgsPMOS(Id, VgSet, pathsNconsts, simulationVariables)
    arguments
        Id                      double     {mustBeInRange(Id,-1,0)}
        VgSet                   double      {mustBeNonempty, mustBePositive, mustBeInRange(VgSet,0,4095)}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(VgSet),"The Vgs set must be in ascending order");
    informLog(["** starting [Rdson - Vgs](PMOS) plot for Id=" num2str(Id) " **"]);
    
    setSystemMode("P");
    setClevel(1);
    CResNum = 0;
    setCRes(CResNum);
    results = {};

    for i = VgSet
        setDAC1(i);
        msg = tuneToId;
        if msg == "SUCCESS"
            results{end+1} = simulate(pathsNconsts,simulationVariables);
        else
            results = cell2mat(results);
            informProgress(['[Rdson - Vgs](PMOS) plot for Id=' num2str(Id) ' completed']);
            return;
        end
    end
    results = cell2mat(results);
    informProgress(['[Rdson - Vgs](PMOS) plot for Id=' num2str(Id) ' completed']);

    function msg = tuneToId
        msg = tuneBy("Ic","DAC0",Id,"inverse",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS" && CResNum == 0
            informLog(['a TOP BREACH occured while trying to tune DAC0 for Id=' num2str(Id) ...
                '.Switching to Rc=10 Ohm']);
            CResNum = 1;
            setCRes(CResNum);
            msg = tuneToId;
        end
        if msg ~= "SUCCESS" && CResNum == 1
            informLog(['the TOP BREACH for Id=' num2str(Id) ' repeated when Rc=10 Ohm']);
            msg = "TOP BREACH";
            return;
        end
    end 
end