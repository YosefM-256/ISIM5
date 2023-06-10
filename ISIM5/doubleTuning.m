function doubleTuning(DAC0tuning,DAC1tuning,DAC0target,DAC1target,DAC0inf,DAC1inf,pathsNconsts,simulationVariables)
    arguments
        DAC0tuning          {mustBeMember(DAC0tuning, {'Ib','Vb','Ic','Vc','Ie','beta','beta PNP','Vcb','Vce','Vbe'})}
        DAC1tuning          {mustBeMember(DAC1tuning, {'Ib','Vb','Ic','Vc','Ie','beta','beta PNP','Vcb','Vce','Vbe'})}
        DAC0target          {mustBeNumeric}
        DAC1target          {mustBeNumeric}
        DAC0inf             {mustBeMember(DAC0inf, {'direct', 'inverse'})}
        DAC1inf             {mustBeMember(DAC1inf, {'direct', 'inverse'})}
        pathsNconsts        struct
        simulationVariables struct
    end

    % phase 1

    DAC0state = getDAC(0);
    DAC1state = getDAC(1);
    DAC0jumpIndex = 1; DAC0jump = getJump(DAC0jumpIndex);
    DAC1jumpIndex = 1; DAC1jump = getJump(DAC1jumpIndex);
    if (DAC0inf == "direct") DAC0inf = 1; else DAC0inf = -1; end
    if (DAC1inf == "direct") DAC1inf = 1; else DAC1inf = -1; end
    if ((DAC0target-getState(0))*DAC0inf > 0) DAC0dir = 1; else DAC0dir = -1; end
    if ((DAC1target-getState(1))*DAC1inf > 0) DAC1dir = 1; else DAC1dir = -1; end

    msg = "SUCCESS";

    while true
        
        if DAC0state + DAC0jump*DAC0dir < 0
            setDAC(DACnum=0,DACvalue=0);
        elseif DAC0state + DAC0jump*DAC0dir > 4095
            setDAC(DACnum=0,DACvalue=4095);
        else
            setDAC(0, DAC0state + DAC0jump*DAC0dir);
        end
        
        if DAC1state + DAC1jump*DAC1dir < 0
            setDAC(DACnum=1,DACvalue=0);
        elseif DAC1state + DAC1jump*DAC1dir > 4095
            setDAC(DACnum=1,DACvalue=4095);
        else
            setDAC(1, DAC1state + DAC1jump*DAC1dir);
        end

        DAC0state = getDAC(0); DAC1state = getDAC(1);
        if ( (DAC0target - getState(0))*DAC0inf*DAC0dir ) < 0 && ...
           ( (DAC1target - getState(1))*DAC1inf*DAC1dir ) < 0
            break;
        end

        if getDAC(0) == 4095 && DAC0dir > 0
            msg = "DAC0 TOP BREACH";
            return;
        end
        if getDAC(0) == 0 && DAC0dir < 0
            msg = "DAC0 BOTTOM BREACH";
            return;
        end 
        
        if getDAC(1) == 4095 && DAC1dir > 0
            msg = "DAC1 TOP BREACH";
            return;
        end
        if getDAC(1) == 0 && DAC1dir < 0
            msg = "DAC1 BOTTOM BREACH";
            return;
        end         
        
        if (DAC0target - getState(0))*DAC0inf > 0, DAC0dir = 1; else, DAC0dir = -1; end
        if (DAC1target - getState(1))*DAC1inf > 0, DAC1dir = 1; else, DAC1dir = -1; end
        
        DAC0jumpIndex = DAC0jumpIndex + 1; DAC0jump = getJump(DAC0jumpIndex);
        DAC1jumpIndex = DAC1jumpIndex + 1; DAC1jump = getJump(DAC1jumpIndex);
    end
    
    function state = getState(DACnum)
        mustBeMember(DACnum,[0 1]);
        result = simulate(pathsNconsts, simulationVariables);
        if (DACnum == 0) tune = DAC0tuning; else tune = DAC1tuning; end

        % this adds support to tuning a DAC by beta
        if tune == "beta"
            state = abs(result.Ic/result.Ib);
        elseif tune == "beta PNP"
            state = abs(result.Ie/result.Ib);
        elseif tune == "Vcb"
            state = result.Vc - result.Vb;
        elseif tune == "Vce"
            state = result.Vc - result.Ve;
        elseif tune == "Vbe"
            state = result.Vb - result.Ve;
        else
            state = result.(tune);
        end
    end

    function state = getDAC(DACnum)
        mustBeMember(DACnum,[0 1]);
        if DACnum == 0
            global DAC0; state = DAC0;
        else
            global DAC1; state = DAC1;
        end
    end
    
    function setDAC(DACnum, DACvalue)
        mustBeMember(DACnum,[0 1]);
        mustBeInteger(DACvalue);
        mustBeInRange(DACvalue,0,4095);

        if DACnum == 0
            global DAC0; DAC0 = DACvalue;
        else
            global DAC1; DAC1 = DACvalue;
        end
    end

    function jump = getJump(jumpIndex)
        jumps = [1 2 4 8 16 round(2.^[4:0.25:12])];
        jump = jumps(jumpIndex);
    end
end