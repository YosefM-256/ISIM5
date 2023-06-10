function upCirDiagram(result)
    arguments
        result     struct
    end
    global DAC0 DAC1 sMode circuitDiagram;
    mustBeNonempty(DAC0);
    mustBeNonempty(DAC1);
    mustBeMember(sMode,[1 0]);
    mustBeNonempty(sMode);
    mustBeNonempty(circuitDiagram);
    
    updateVI();
    updateDAC(0); updateDAC(1);
    updateVoltageDiff();
    
    resultsSmode = getSmode();
    resultsRCnum = getRCnum();
    resultsClevel = getClevel();

    if (circuitDiagram.cLevel ~= resultsClevel) && (resultsSmode == "P")
        updateClevel();
        circuitDiagram.cLevel = resultsClevel;
    end

    if circuitDiagram.mode ~= resultsSmode
        updateSmode();
        circuitDiagram.mode = resultsSmode;
    end

    if (circuitDiagram.RCnum) ~= resultsRCnum 
        updateRes(resultsRCnum); 
        circuitDiagram.RCnum = resultsRCnum;
    end
    % checks if the direction of Ib has changed. If it has, it updates the
    % Ib arrow (swaps it's direction) and saves the new direction in the
    % IbArrowDirection property of circuitDiagram
    if (result.Ib*circuitDiagram.IbArrowDirection < 0) 
        temp = circuitDiagram.Ib.Position;
        circuitDiagram.Ib.Position = [(temp(1)+temp(3)) temp(2) -1*temp(3) temp(4)];
        circuitDiagram.IbArrowDirection = -1*circuitDiagram.IbArrowDirection;
    end

    function updateVI
        for i = ["Vb" "Vc" "Ve" "Ib" "Ic" "Ie"]
            circuitDiagram.(strjoin([i "text"],'')).String = num2str(result.(i),5);
        end
    end

    function updateDAC(DACnum)
        mustBeMember(DACnum,[0 1]);
        if DACnum==1 DACvalue = DAC1; else DACvalue = DAC0; end;
        circuitDiagram.(strjoin(["DAC" num2str(DACnum)],'')).String = [strjoin([num2str(2*DACbinToVolt(DACvalue),5) "V"],'') DACvalue];
    end

    function updateRes(ResNum)
        for i=0:1
            resistor = strjoin(["RC" num2str(i) "branch"], '');
            if ResNum==i
                set(struct2array(circuitDiagram.(resistor)),'Color','g','LineWidth',2,'LineStyle','-');
                circuitDiagram.(resistor).(strjoin(["RC" num2str(i)], '')).EdgeColor = 'g';
            else
                set(struct2array(circuitDiagram.(resistor)),'Color','black','LineWidth',0.5,'LineStyle',':');
                circuitDiagram.(resistor).(strjoin(["RC" num2str(i)], '')).EdgeColor = 'b';
            end
        end
    end

    function updateVoltageDiff
        circuitDiagram.Vcbtext.String = strjoin(["Vcb =" num2str(result.Vc - result.Vb,3)]);
        circuitDiagram.Vbetext.String = strjoin(["Vbe =" num2str(result.Vb - result.Ve,3)]);
        circuitDiagram.Vcetext.String = strjoin(["Vce =" num2str(result.Vc - result.Ve,3)]);
    end

    function updateSmode()
        mustBeMember(resultsSmode,["N" "P"]);
        global app;
        app.circuitView = createDiagram(app.UIFigure, resultsSmode);
    end

    function updateClevel()
        mustBeMember(resultsClevel,[0 1]);
        if resultsClevel == 1
            set(struct2array(circuitDiagram.EpwrPinBox.ground),'Visible','off');
            set(circuitDiagram.EpwrPinBox.high,'Visible','on');
        else
            set(struct2array(circuitDiagram.EpwrPinBox.ground),'Visible','on');
            set(circuitDiagram.EpwrPinBox.high,'Visible','off');
        end
    end

    function mode = getSmode()
        if any(result.sModeBinForm == [24 28 25 29])
            mode = "N";
            return;
        end
        if any(result.sModeBinForm == [2 6 3 7])
            mode = "P";
            return;
        end
        error("the system is neither in N nor in P state");
    end

    function resultsClevel = getClevel()
        resultsClevel = not(sMode(5));
        end
    
    function RCnum = getRCnum()
        smode = result.sMode;
        RCnum = smode(3);
    end

    drawnow limitrate;
end