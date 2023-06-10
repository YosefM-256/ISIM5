classdef ISIMapp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        TuningAxesLabel       matlab.ui.control.Label
        ISIMLabel             matlab.ui.control.Label
        openSims              matlab.ui.control.DropDown
        ViewSimulationsLabel  matlab.ui.control.Label
        tabgroup              matlab.ui.container.TabGroup
        tabs                  struct
        circuitView           matlab.ui.container.Panel
%         saveDataba se          matlab.ui.control.Button
        CircuitViewLabel      matlab.ui.control.Label
        tuningAxesError       matlab.ui.control.UIAxes
        tuningAxesDAC         matlab.ui.control.UIAxes
        plotExists
        lastPlot
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 900 700];
            app.UIFigure.Name = 'ISIM app';
            app.UIFigure.Resize = "off";

            % Create tuningAxesError
            app.tuningAxesError = uiaxes(app.UIFigure);
            xlabel(app.tuningAxesError, 'Iteration');
            title(app.tuningAxesError,"Error");
            app.tuningAxesError.YScale = 'log';
            app.tuningAxesError.Color = [0.9412 0.9412 0.9412];
            app.tuningAxesError.Position = [179 301 179 244];

            % Create tuningAxesDAC
            app.tuningAxesDAC = uiaxes(app.UIFigure);
            xlabel(app.tuningAxesDAC, 'Iteration');
            title(app.tuningAxesDAC,"DAC");
            app.tuningAxesDAC.Color = [0.9412 0.9412 0.9412];
            app.tuningAxesDAC.Position = [0 301 179 244];

            % Create circuitView
            app.circuitView = createDiagram(app.UIFigure, "N");
            app.circuitView.AutoResizeChildren = 'off';
            app.circuitView.TitlePosition = 'centertop';
            app.circuitView.Position = [2 0 360 300];

            % Create CircuitViewLabel
            app.CircuitViewLabel = uilabel(app.circuitView);
            app.CircuitViewLabel.HorizontalAlignment = 'center';
            app.CircuitViewLabel.Position = [106 278 151 22];
            app.CircuitViewLabel.Text = 'Circuit View';

            % Create tab group
            app.tabgroup = uitabgroup(app.UIFigure);
            app.tabgroup.Position = [364 0 534 175];
            
            % Create and initialise the tabs
            app.tabs = struct();
            app.tabs.log.tab = uitab(app.tabgroup,"Title","Log");
            app.tabs.warnings.tab = uitab(app.tabgroup,"Title","Warnings");
            app.tabs.progress.tab = uitab(app.tabgroup,"Title","Progress");
            app.tabs.progress.indents = 0;
            
            % Create the log TextArea
            app.tabs.log.textarea = uitextarea(app.tabs.log.tab);
            app.tabs.log.textarea.Editable = 'off';
            app.tabs.log.textarea.Position = [0 0 app.tabs.log.textarea.Parent.Position(3:4)-[0 23]];
            app.tabs.log.textarea.Value = {'ISIM app launched',''};

            % Create the progress TextArea
            app.tabs.progress.textarea = uitextarea(app.tabs.progress.tab);
            app.tabs.progress.textarea.Editable = 'off';
            app.tabs.progress.textarea.Position = [0 0 app.tabs.log.textarea.Parent.Position(3:4)-[0 23]];
            app.tabs.progress.textarea.Value = {'ISIM app launched',''};

            % Create ViewSimulationsLabel
            app.ViewSimulationsLabel = uilabel(app.UIFigure);
            app.ViewSimulationsLabel.HorizontalAlignment = 'right';
            app.ViewSimulationsLabel.Position = [375 212 100 22];
            app.ViewSimulationsLabel.Text = 'View Simulations:';

            % Create openSims
            app.openSims = uidropdown(app.UIFigure);
            app.openSims.Items = ["- No simulations -"];
            app.openSims.Position = [491 212 300 22];
            app.openSims.ValueChangedFcn = @(~,~) showPlot(app);
            app.plotExists = false;

            % Create ISIMLabel
            app.ISIMLabel = uilabel(app.UIFigure);
            app.ISIMLabel.HorizontalAlignment = 'center';
            app.ISIMLabel.FontName = 'Bahnschrift';
            app.ISIMLabel.FontSize = 25;
            app.ISIMLabel.FontColor = [0 0.4471 0.7412];
            app.ISIMLabel.Position = [415 650 72 43];
            app.ISIMLabel.Text = 'ISIM 4';
            app.ISIMLabel.FontColor = 'green';

            % Create TuningAxesLabel
            app.TuningAxesLabel = uilabel(app.UIFigure);
            app.TuningAxesLabel.HorizontalAlignment = 'center';
            app.TuningAxesLabel.Position = [109 540 151 22];
            app.TuningAxesLabel.Text = 'Tuning Axes';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end

        function showPlot(app, ~)
            app.lastPlot.Visible = 'off';
            clickedSimulation = app.openSims.Value;
            clickedSimulation.Visible = 'on';
            app.lastPlot = clickedSimulation;
        end

    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ISIMapp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        function addPlot(app, simulations, plotType, plotName)
            mustBeText(plotName);
            newPanel = uipanel(app.UIFigure,Visible="off",Position=[400 250 450 350]);
            dataToPlot(simulations,plotType,newPanel);
            newPanel.Children(1).Position = [20 20 410 310];
            if app.plotExists
                app.openSims.Items{end+1} = char(plotName);
                app.openSims.ItemsData(end+1) = newPanel;
            else
                app.openSims.Items = {char(plotName)};
                app.openSims.ItemsData = [newPanel];
                app.plotExists = true;
                app.lastPlot = newPanel;
                app.showPlot();
            end
            
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end


    end
end