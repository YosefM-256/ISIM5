close all; clear all;
global DAC1 DAC0 sMode;

DAC1 = 1000; DAC0 = 4095; sMode = [1 1 1 0 0];

pathsNconsts = struct(  'simulationCommand',    'XVIIx64.exe -b -ascii', ...
                        'homePath',             'U:\ISIM5\PMOS_NX3008PBKW', ...
                        'cirFileName',          'ISIM5cir_PMOS_NX3008PBKW.cir', ...
                        'rawFileName',          'ISIM5cir_PMOS_NX3008PBKW.raw', ...
                        'variablesFile',        'variables_PMOS_NX3008PBKW.txt', ...
                        'LTSpicePath',          'C:\Program Files\LTC\LTspiceXVII', ...
                        'databasePath',         'database_PMOS_NX3008PBKW.mat');

simulationVariables = getSimulationVariables(pathsNconsts);

findall(0,'Name','ISIM app').delete();
global app; app = ISIMapp;


%%
% k = plotIcVce([5e-4 1e-3 2e-3 3e-3],[100:100:4000],pathsNconsts,simulationVariables);
% l = plothfeIc(5,[[1:0.5:9]*1e-5 [1:0.5:9]*1e-4 [1:0.5:9]*1e-3 ],"return",pathsNconsts,simulationVariables);
% z = plotVsatIcNPN(10,[ [5:9]*1e-4 [1:9]*1e-3 [1:9]*1e-2 [1:4]*1e-1 ],pathsNconsts,simulationVariables);


% x = plotIcVcePNP([-1:-1:-4]*1e-3,100:100:4000,pathsNconsts,simulationVariables);
% c = plothfeIcPNP(-5,[25:25:4075],[25:25:4075],pathsNconsts,simulationVariables);
% p = plotVsatIcPNP(10,[10:5:100 120:20:300]*-1e-3,300,pathsNconsts,simulationVariables);


% v = sweepDAC0Vgs([2.5 3 4 5],[100:100:4000],pathsNconsts,simulationVariables);
% b = plotRdsonVgs(0.05,[50:50:4050],pathsNconsts,simulationVariables);
% n = plotIdVgs(5,25:25:4075,"return",pathsNconsts,simulationVariables);


m = sweepDAC0VgsPMOS([-2 -3 -4 -5],[50:50:4050],pathsNconsts,simulationVariables);
q = plotRdsonVgsPMOS(-0.05,[50:50:2500],pathsNconsts,simulationVariables); 
w = plotIdVgsPMOS(-5,[10:10:4000],'return',pathsNconsts,simulationVariables);

saveDatabase(pathsNconsts);