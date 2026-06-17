function PlotStimTriggeredRespiration()

% ========================================================================
% Function: PlotStimTriggeredRespiration
%
% Description:
% This function analyzes stimulation-triggered respiration responses from
% Intan recordings. Respiration traces are aligned to stimulation onset,
% classified according to respiratory phase (inspiration or expiration),
% and visualized as both individual traces and population averages.
%
% The function:
% - Loads respiration and digital trigger signals from Intan .rhd files
% - Detects stimulation pulse trains from digital inputs
% - Generates matched baseline trigger points
% - Separates events into inspiratory and expiratory phases
% - Randomly samples respiration traces around trigger points
% - Plots:
%       • Individual aligned respiration traces
%       • Mean ± standard error traces
%
% Inputs:
%   None
%
% User Inputs:
%   Experimental metadata and recording directory are obtained through:
%
%       getRespirationPlotInputs()
%
%   The GUI collects:
%   - Bird name
%   - Hemisphere
%   - Experimental state
%   - Electrode configuration
%   - Electrode coordinates:
%         • AP
%         • ML
%         • Depth
%   - Stimulation current
%   - Data directory path
%
% Workflow:
% 1. Launch metadata input GUI
% 2. Load Intan respiration and trigger recordings
% 3. Filter respiration signal
% 4. Detect stimulation pulse trains
% 5. Generate matched baseline trigger indices
% 6. Classify events into:
%       • Inspiration
%       • Expiration
% 7. Randomly sample respiration epochs
% 8. Plot:
%       • Individual traces
%       • Mean ± standard error
%
% Requirements:
%   - getRespirationPlotInputs function
%   - read_Intan_RHD2000_file_M function
%   - StimulusForRespPlot function/script
%
% Usage:
%   PlotStimTriggeredRespiration()
%
% Example:
%   PlotStimTriggeredRespiration()
%
% Notes:
% - Respiration signal is assumed to be board_adc_data(1,:)
% - Trigger detection is based on pulse-train timing structure
% - Positive respiration values are classified as expiration
% - Negative respiration values are classified as inspiration
% - Y-axis limits are automatically matched across subplot rows
% - If fewer trials are available than requested, sample count is
%   automatically reduced
%
% Outputs:
%   - Figure containing:
%         • Individual respiration traces
%         • Mean ± standard error traces
%
% Written by Anand C Krishnan (2026)
% For use in the Rajan Lab, IISER Pune
%
%
% Disclaimer:
% This MATLAB script was written entirely by the author (Anand C Krishnan).
% Generative AI tools were used solely to formalize the code comments for 
% improved readability and documentation. AI use was limited to enhancing 
% the accompanying comments and documentation.
%
% This code is intended for research use within the lab.
% Please acknowledge the author if this code contributes to your work.
% ========================================================================


% ---------------------- Display Authorship ----------------------

fprintf('\n=============================================\n');
fprintf(' Function: PlotStimTriggeredRespiration\n');
fprintf(' Author  : Anand C Krishnan\n');
fprintf(' Lab     : Rajan Lab, IISER Pune\n');
fprintf(' Year    : 2026\n');
fprintf('=============================================\n\n');


%% =======================================================================
%  Get Experiment Metadata and Recording Directory
%  =======================================================================

% Launch GUI and retrieve experiment parameters
[BirdName, Hemisphere, State, ElectrodeConfig, ...
          AP, ML, Depth, Current, RespChannel, DataPath] = ...
          getRespirationPlotInputs();

% Create coordinate string for figure title
Coordinates = ['AP: ' num2str(AP) ...
               ' mm, ML: ' num2str(ML) ...
               ' mm, D: ' num2str(Depth) ' mm'];

% Recording directory
IntanPath = DataPath;

% Move into recording directory
cd(IntanPath)


%% =======================================================================
%  Initialize Variables
%  =======================================================================

% Respiration signal
Resp_data = [];

% Time vector
Time_data = [];

% Digital trigger signal
Dig_data = [];


%% =======================================================================
%  Load Intan Recording Files
%  =======================================================================

% Find all .rhd files in selected directory
IntanFiles = dir(fullfile(IntanPath, '*.rhd'));

% Convert filenames into string array
IntanFileNames = string({IntanFiles.name});


%% =======================================================================
%  Read and Concatenate Intan Data
%  =======================================================================

for i = 1:length(IntanFiles)

    % Read Intan recording
    [t_board_adc, amplifier_data, board_adc_data, ...
        frequency_parameters, board_dig_in_data] = ...
        read_Intan_RHD2000_file_M(IntanFileNames(i));

    % Respiration signal is assumed to be ADC channel 1
    Data = board_adc_data(RespChannel,:);

    % Concatenate recordings across files
    Resp_data = [Resp_data, Data];

    Time_data = [Time_data, t_board_adc];

    Dig_data = [Dig_data, board_dig_in_data];

end


%% =======================================================================
%  Filter Respiration Signal
%  =======================================================================

% Sampling frequency (Hz)
Fs = frequency_parameters.board_adc_sample_rate;

% Low-pass cutoff frequency (Hz)
Fc = 25;

% Moving average filter length
N = round(Fs / Fc);

% FIR moving-average filter coefficients
b = ones(1, N) / N;

% Filter respiration signal
Filtered_Resp_data = filter(b, 1, Resp_data);


%% =======================================================================
%  Detect Stimulation Trigger Trains
%  =======================================================================

% Trigger indices
Index = [];

% Number of pulses expected in train
NOP = 7;

for j = 2:length(Dig_data)

    % Detect rising edge
    if Dig_data(j) - Dig_data(j-1) == 1

        flag = true;

        % Verify expected pulse train structure
        for k = 1:NOP-1

            Diff = Dig_data(j+(k*(74:78))) - ...
                   Dig_data(j-1+(k*(74:78)));

            % Reject incomplete pulse trains
            if ~any(Diff == 1)

                flag = false;
                break

            end
        end

        % Store valid trigger index
        if flag

            Index = [Index; j];

        end
    end
end

% Display number of detected trigger points
disp([num2str(length(Index)) ' trigger points detected.'])


%% =======================================================================
%  Generate Baseline Trigger Indices
%  =======================================================================

BaselineIndex = [];

for i = 1:length(Index)

    % Generate pseudo-trigger baseline points
    if Index(i) - Index(1) < Index(1)

        Temp = Index(i) - Index(1);

        BaselineIndex = [BaselineIndex, Temp];

    end
end

% Remove edge points
BaselineIndex(1) = [];
BaselineIndex(end-1:end) = [];


%% =======================================================================
%  Baseline Safety Check
%  =======================================================================

% Ensure baseline window does not overlap stimulation period
if BaselineIndex(end) + (1*Fs) > Index(1)

    error('Error in baseline index!!!');

end


%% =======================================================================
%  Baseline Normalize Respiration Signal
%  =======================================================================

% Compute baseline respiration mean
MeanResp = mean(Filtered_Resp_data(1:BaselineIndex(end)));

% Remove DC offset from respiration signal
Filtered_Resp_data = Filtered_Resp_data - MeanResp;


%% =======================================================================
%  Separate Baseline Events into Inspiration / Expiration
%  =======================================================================

Indices = struct;

Indices.BaselineIndex_Ins = [];
Indices.BaselineIndex_Ex = [];

for i = 1:length(BaselineIndex)

    % Positive respiration values = expiration
    if Filtered_Resp_data(BaselineIndex(i)) >= 0

        Indices.BaselineIndex_Ex = ...
            [Indices.BaselineIndex_Ex, BaselineIndex(i)];

    % Negative respiration values = inspiration
    else

        Indices.BaselineIndex_Ins = ...
            [Indices.BaselineIndex_Ins, BaselineIndex(i)];

    end
end


%% =======================================================================
%  Separate Stimulus Events into Inspiration / Expiration
%  =======================================================================

Indices.Index_Ins = [];
Indices.Index_Ex = [];

for i = 1:length(Index)

    if Filtered_Resp_data(Index(i)) >= 0

        Indices.Index_Ex = [Indices.Index_Ex, Index(i)];

    else

        Indices.Index_Ins = [Indices.Index_Ins, Index(i)];

    end
end


%% =======================================================================
%  Display Event Statistics
%  =======================================================================

disp([num2str(length(Indices.BaselineIndex_Ins)) ...
    ' baseline inhalation points detected.'])

disp([num2str(length(Indices.BaselineIndex_Ex)) ...
    ' baseline exhalation points detected.'])

disp([num2str(length(Indices.Index_Ins)) ...
    ' inhalation points detected.'])

disp([num2str(length(Indices.Index_Ex)) ...
    ' exhalation points detected.'])


%% =======================================================================
%  Determine Available Sample Count
%  =======================================================================

% Determine smallest available dataset across all conditions
MinDataLength = min([ ...
    length(Indices.BaselineIndex_Ins), ...
    length(Indices.BaselineIndex_Ex), ...
    length(Indices.Index_Ins), ...
    length(Indices.Index_Ex)]);


%% =======================================================================
%  Define Plotting Parameters
%  =======================================================================

% Structure field names
IndexNames = fieldnames(Indices);

% Subplot assignment for raw traces
SubPlotNo = [1 2 1 2];

% Plot colors
Color = {'#000000', '#000000', '#FF6666', '#FF6666'};


%% =======================================================================
%  Initialize Storage Variables
%  =======================================================================

% Store aligned respiration traces
AllData = [];

% Store aligned time vectors
AllTime = [];

% Number of trials to randomly sample
Samples = 30;


%% =======================================================================
%  Ensure Valid Sample Count
%  =======================================================================

if MinDataLength < Samples

    warning(['Minimum available data length (%d) is smaller ' ...
        'than requested Samples (%d). Using %d samples instead.'], ...
        MinDataLength, Samples, MinDataLength);

    Samples = MinDataLength;

end


%% =======================================================================
%  Plot Individual Respiration Traces
%  =======================================================================

for i = 1:length(IndexNames)

    % Randomly sample trials without replacement
    TempIndex = datasample(Indices.(IndexNames{i}), ...
        Samples, 'Replace', false);

    for j = 1:length(TempIndex)

        % Extract respiration window around trigger
        TempData = Filtered_Resp_data( ...
            round(TempIndex(j)-(0.05*Fs)) : ...
            round(TempIndex(j)+(0.2*Fs)));

        % Extract corresponding time vector
        TempTime = Time_data( ...
            round(TempIndex(j)-(0.05*Fs)) : ...
            round(TempIndex(j)+(0.2*Fs)));

        % Align time to trigger onset
        TempTime = TempTime - Time_data(TempIndex(j));

        % Store traces
        AllData = [AllData; TempData];

        AllTime = [AllTime; TempTime];

        % Plot respiration trace
        subplot(2,2,SubPlotNo(i))

        plot(TempTime, TempData, ...
            'Color', Color{i}, ...
            'LineWidth', 1.5)

        hold on

    end
end


%% =======================================================================
%  Plot Mean ± Standard Error Traces
%  =======================================================================

PatchColor = {'k', 'k', 'r', 'r'};

% Subplot assignment for averaged traces
SubPlotNo = [3 4 3 4];

for i = 1:length(IndexNames)

    subplot(2,2,SubPlotNo(i))

    % Extract traces for current condition
    TempAllTime = AllTime((Samples*(i-1))+1:Samples*(i),:);

    TempAllData = AllData((Samples*(i-1))+1:Samples*(i),:);

    % Compute mean trace
    MeanTime = mean(TempAllTime);

    MeanData = mean(TempAllData);

    % Plot mean respiration trace
    plot(MeanTime, MeanData, ...
        'Color', Color{i}, ...
        'LineWidth', 2);

    hold on;

    % Compute standard error
    StdErr = std(TempAllData) ./ ...
        sqrt(size(TempAllData, 1));

    % Upper and lower bounds
    y1 = MeanData + StdErr;

    y2 = MeanData - StdErr;

    % Plot shaded error region
    patch([MeanTime fliplr(MeanTime)], ...
          [y1 fliplr(y2)], ...
          PatchColor{i}, ...
          'FaceAlpha', 0.25, ...
          'EdgeColor', 'none')

end


%% =======================================================================
%  Determine Common Symmetric Y-axis Limits
%  =======================================================================

% First row: individual traces
RawAxes = [subplot(2,2,1), subplot(2,2,2)];

RawYLimits = cell2mat(get(RawAxes, 'YLim'));

% Find largest absolute value
RawAbsMax = max(abs(RawYLimits(:)));

% Make limits symmetric around zero
RawYMin = -RawAbsMax;
RawYMax =  RawAbsMax;


% Second row: mean traces
MeanAxes = [subplot(2,2,3), subplot(2,2,4)];

MeanYLimits = cell2mat(get(MeanAxes, 'YLim'));

% Find largest absolute value
MeanAbsMax = max(abs(MeanYLimits(:)));

% Make limits symmetric around zero
MeanYMin = -MeanAbsMax;
MeanYMax =  MeanAbsMax;


%% =======================================================================
%  Format Figure
%  =======================================================================

Title = { ...
    'Inspiration', ...
    'Expiration', ...
    'Inspiration (mean ± std err)', ...
    'Expiration (mean ± std err)'};

for i = 1:4

    subplot(2,2,i)

    % Add trigger onset marker
    xline(0, 'k:', 'LineWidth',1);

    % Add stimulus overlay
    [stim, t] = StimulusForRespPlot;

    % X-axis formatting
    xlim([-0.05 0.15])

    xticks(-0.05:0.05:0.15)

    % Apply common Y-axis limits within rows
    if i <= 2

        ylim([RawYMin RawYMax])

    else

        ylim([MeanYMin MeanYMax])

    end

    % Add condition labels
    text(0.75,0.90,'Control', ...
        'Color','k', ...
        'Units','normalized', ...
        'FontSize',12, ...
        'Fontname','Arial')

    text(0.75,0.82,'Stimulated', ...
        'Color','r', ...
        'Units','normalized', ...
        'FontSize',12, ...
        'Fontname','Arial')

    text(0.75,0.74,'Stimulus', ...
        'Color','b', ...
        'Units','normalized', ...
        'FontSize',12, ...
        'Fontname','Arial')

    % Axis labels and title
    xlabel('Time (sec)')

    ylabel('Voltage (\muV)')

    title(Title{i})

    % Axis formatting
    set(gca,'FontSize',12,'Fontname','Arial')

    box on

end


%% =======================================================================
%  Add Figure Title
%  =======================================================================

sgtitle({ ...
    ['BirdName: ' BirdName ...
    ' (' Hemisphere ') ' ...
    State ' (' ElectrodeConfig ')'], ...
    [Coordinates ', I = ' num2str(Current) ' \muA']}, ...
    'FontSize',15, ...
    'Fontname','Arial')

% Set figure background color
set(gcf, 'Color', 'White');


%% =======================================================================
%  Clear Workspace
%  =======================================================================

clear

end