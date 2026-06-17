function [BirdName, Hemisphere, State, ElectrodeConfig, ...
          AP, ML, Depth, Current, RespChannel, DataPath] = ...
          getRespirationPlotInputs()
    
% ========================================================================
% Function: getRespirationPlotInputs
%
% Description:
% This function launches a graphical user interface (GUI) to collect
% metadata and directory information required for respiration plotting
% experiments involving electrical stimulation.
%
% The GUI allows the user to input:
% - Bird name
% - Hemisphere (LH or RH)
% - Experimental state (Anesthetized or Awake)
% - Electrode configuration (E1E2 or E2E1)
% - Electrode coordinates:
%       • AP (Anterior-Posterior)
%       • ML (Medial-Lateral)
%       • Depth
% - Stimulation current (µA)
% - Path to the experiment/data directory
%
% Outputs:
%   BirdName         : Name/identifier of the subject
%   Hemisphere       : Hemisphere used (LH or RH)
%   State            : Experimental condition (Anesthetized or Awake)
%   ElectrodeConfig  : Electrode polarity configuration
%   AP               : AP coordinate (mm)
%   ML               : ML coordinate (mm)
%   Depth            : Electrode depth (mm)
%   Current          : Stimulation current (µA)
%   DataPath         : Selected experiment/data directory
%
% Workflow:
% 1. GUI window is launched
% 2. User enters experiment metadata
% 3. User optionally browses for experiment directory
% 4. Pressing "Plot" validates and returns all parameters
%
% Usage:
%   [BirdName, Hemisphere, State, ElectrodeConfig, ...
%    AP, ML, Depth, Current, DataPath] = getRespirationPlotInputs();
%
% Example:
%   [BirdName, Hemisphere, State, ElectrodeConfig, ...
%    AP, ML, Depth, Current, DataPath] = getRespirationPlotInputs();
%
% Notes:
% - Intended as a front-end metadata input module for respiration analysis
% - Can be extended to directly call plotting/analysis functions
% - GUI-based input reduces manual entry errors and improves consistency
%
% Written by Anand C Krishnan (2026)
% For use in the Rajan Lab, IISER Pune
%
% 
% Disclaimer:
% This MATLAB GUI script was written with the assistance of generative AI
% tools. Its role is limited to collecting user inputs necessary to run the
% accompanying analysis scripts. The underlying analysis scripts and 
% analytical methods were written entirely by the author (Anand C Krishnan).
%
% This code is intended for research use within the lab.
% Please acknowledge the author if this code contributes to your work.
% ========================================================================

% ---------------------- Initialize Outputs ----------------------
BirdName = [];
Hemisphere = [];
State = [];
ElectrodeConfig = [];

AP = [];
ML = [];
Depth = [];

Current = [];
RespChannel = [];
DataPath = [];

% ---------------------- Create GUI Window ----------------------
fig = uifigure( ...
    'Name', 'Respiration Analysis', ...
    'Position', [500 300 650 500], ...
    'Color', [0.96 0.97 0.99]);

% ---------------------- Layout Settings ----------------------
labelX = 40;
fieldX = 220;
labelWidth = 160;
fieldWidth = 340;
rowGap = 48;

% ---------------------- Bird Name ----------------------
y = 430;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'Bird Name:');

birdNameField = uieditfield(fig, 'text', ...
    'Position', [fieldX y fieldWidth 22]);

% ---------------------- Hemisphere ----------------------
y = y - rowGap;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'Hemisphere:');

hemisphereDropDown = uidropdown(fig, ...
    'Items', {'LH', 'RH'}, ...
    'Position', [fieldX y fieldWidth 22]);

% ---------------------- State ----------------------
y = y - rowGap;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'State:');

stateDropDown = uidropdown(fig, ...
    'Items', {'Anesthetized', 'Awake'}, ...
    'Position', [fieldX y fieldWidth 22], ...
    'ValueChangedFcn', @(src,event) updateRespChannel());

% ---------------------- Electrode Configuration ----------------------
y = y - rowGap;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'Electrode Config:');

electrodeDropDown = uidropdown(fig, ...
    'Items', {'E1E2', 'E2E1'}, ...
    'Position', [fieldX y fieldWidth 22]);

% ---------------------- Coordinates (mm) ----------------------
y = y - 70;

uilabel(fig, ...
    'Position', [labelX y+8 labelWidth 22], ...
    'Text', 'Coordinates (mm):');

coordPanel = uipanel(fig, ...
    'Position', [fieldX y fieldWidth 40]);

% AP
uilabel(coordPanel, ...
    'Position', [5 10 20 22], ...
    'Text', 'AP');

apField = uieditfield(coordPanel, 'numeric', ...
    'Position', [25 10 60 22]);

% ML
uilabel(coordPanel, ...
    'Position', [110 10 20 22], ...
    'Text', 'ML');

mlField = uieditfield(coordPanel, 'numeric', ...
    'Position', [130 10 60 22]);

% Depth
uilabel(coordPanel, ...
    'Position', [215 10 40 22], ...
    'Text', 'Depth');

depthField = uieditfield(coordPanel, 'numeric', ...
    'Position', [260 10 60 22]);

% ---------------------- Current ----------------------
y = y - rowGap;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'Current (uA):');

currentField = uieditfield(fig, 'numeric', ...
    'Position', [fieldX y fieldWidth 22]);

% ---------------------- Respiration Channel ----------------------
y = y - rowGap;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'Respiration Channel:');

respChannelField = uieditfield(fig, 'numeric', ...
    'Position', [fieldX y fieldWidth 22], ...
    'Value', 1);

updateRespChannel();

% ---------------------- Path ----------------------
y = y - rowGap;

uilabel(fig, ...
    'Position', [labelX y labelWidth 22], ...
    'Text', 'Path:');

pathField = uieditfield(fig, 'text', ...
    'Position', [fieldX y 250 22]);

% Browse Button
uibutton(fig, 'push', ...
    'Text', 'Browse', ...
    'Position', [fieldX + 260 y 80 22], ...
    'ButtonPushedFcn', @(btn,event) browsePath());

% ---------------------- Plot Button ----------------------
uibutton(fig,'push',...
    'Text','Generate Plot',...
    'FontSize',16,...
    'FontWeight','bold',...
    'BackgroundColor',[0.18 0.55 0.34],...
    'FontColor',[1 1 1],...
    'Position',[270 30 200 35], 'ButtonPushedFcn', @(btn,event) plotData());

% ---------------------- Wait for User ----------------------
uiwait(fig);

if isvalid(fig)
    delete(fig);
end

% ========================================================================
% Helper Function: Browse Path
% ========================================================================
    function browsePath()

        selectedPath = uigetdir;

        if selectedPath ~= 0
            pathField.Value = selectedPath;
        end

    end


% ========================================================================
% Helper Function: Update Respiration Channel
% ========================================================================
    function updateRespChannel()

        if strcmp(stateDropDown.Value, 'Anesthetized')

            respChannelField.Value = 1;

        elseif strcmp(stateDropDown.Value, 'Awake')

            respChannelField.Value = 2;

        end

    end


% ========================================================================
% Callback Function: Plot Data
% ========================================================================
    function plotData()

        % Retrieve values
        BirdName = char(birdNameField.Value);
        Hemisphere = char(hemisphereDropDown.Value);
        State = char(stateDropDown.Value);
        ElectrodeConfig = char(electrodeDropDown.Value);

        AP = apField.Value;
        ML = mlField.Value;
        Depth = depthField.Value;

        Current = currentField.Value;
        RespChannel = respChannelField.Value;
        DataPath = char(pathField.Value);

        % ---------------------- Validation ----------------------

        if isempty(BirdName)
            uialert(fig, 'Please enter Bird Name.', 'Input Error');
            return;
        end

        if isempty(DataPath) || ~isfolder(DataPath)
            uialert(fig, 'Please select a valid folder path.', 'Input Error');
            return;
        end

        % Resume execution
        uiresume(fig);

    end

end