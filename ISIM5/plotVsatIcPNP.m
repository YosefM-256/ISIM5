function results = plotVsatIcPNP(beta,Icset,DAC1maxDelta,pathsNconsts,simulationVariables)
    arguments                             
        beta                    double      {mustBePositive}
        Icset                   double      {mustBeNonempty, mustBeNegative}
        DAC1maxDelta            double      {mustBeInRange(DAC1maxDelta,0,4095), mustBeInteger}
        pathsNconsts            struct
        simulationVariables     struct
    end

    informLog(["starting [Vsat - Ic](PNP) graph for beta=" num2str(beta)]);

    results = {};
    setCRes(0);
    CResNum = 0;
    setDAC1(0);
    setDAC0(2048);
    setSystemMode("P");
    setClevel(1);

    for ic = Icset
        Icmsg = tuneToIc(ic);
        if Icmsg ~= "SUCCESS"
            error("TOP BREACH occured while tuning Ic to %d",ic);
        end
        betamsg = tuneToBeta();
        if betamsg ~= "SUCCESS"
            error("TOP BREACH occured while tuning beta to %d",beta);
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    informProgress("[Vsat - Ic](PNP) graph successufully finished");
    results = cell2mat(results);
    
    function result = tuneToIc(ic)
        result = "SUCCESS";
        % the tuning is to Ie because the 'Ie' in the circuit is the Ic of
        % a PNP transistor
        msg = tuneBy("Ic","DAC0",ic,"inverse",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS" && CResNum == 0  
            informLog(['TOP BREACH occured while trying to tune DAC0 for Ic=' num2str(ic) ...
                '.Switching to Rc=10 Ohm']);
            setCRes(1);
            CResNum = 1;
            msg = tuneToIc(ic);
        end
        if msg ~= "SUCCESS" && CResNum == 1
            informLog(['the TOP BREACH for Ic=' num2str(ic) ' repeated when Rc=10 Ohm']);
            result = "TOP BREACH";
            return;
        end
    end
        
    function result = tuneToBeta
        result = "SUCCESS";
        setDAC1(getStartingDAC1());
        msg = tuneBy("beta","DAC1",beta,"direct",pathsNconsts,simulationVariables,getDAC0()-DAC1maxDelta);
        if msg ~= "SUCCESS" 
            informLog(["TOP BREACH occured while tuning beta to" num2str(beta)]);
            result = msg;
            return;
        end           
    end

    function startDAC1 = getStartingDAC1()
        global DAC0;
        DAC0voltage = DACbinToVolt(DAC0);
        Ic = simulate(pathsNconsts,simulationVariables).Ic;
        startDAC1voltage = DAC0voltage - 0.8 + Ic*10;
        startDAC1 = max([round(startDAC1voltage*4095/5), 0]);
    end

    function DAC0value = getDAC0()
        global DAC0;
        DAC0value = DAC0;
    end
end