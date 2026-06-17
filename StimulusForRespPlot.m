function [stim, t] = StimulusForRespPlot

% ========================================================================
% Function: StimulusForRespPlot
%
% Description:
% Generates and plots a biphasic electrical stimulation pulse train used
% as a visual overlay in respiration-triggered stimulation plots.
%
% The stimulus consists of:
%   - 7 biphasic pulses
%   - 400 Hz pulse repetition frequency
%   - 0.4 ms positive phase
%   - 0.4 ms negative phase
%
% The waveform is aligned such that stimulation onset occurs at t = 0,
% allowing direct comparison with respiration traces aligned to trigger
% onset.
%
% Inputs:
%   None
%
% Outputs:
%   stim    : Biphasic stimulus waveform vector
%   t       : Time vector corresponding to stimulus waveform
%
% Workflow:
% 1. Define sampling parameters
% 2. Generate time vector
% 3. Shift time axis to align stimulation at t = 0
% 4. Define pulse-train parameters
% 5. Generate biphasic pulse train
% 6. Plot stimulus waveform
%
% Notes:
% - Time window spans:
%       • -50 ms pre-stimulus
%       • +150 ms post-stimulus
%
% - The generated waveform is intended primarily for visualization
%   purposes in respiration-aligned plots.
%
% - Positive and negative phases are charge-balanced.
%
% Usage:
%   [stim, t] = StimulusForRespPlot;
%
% Example:
%   [stim, t] = StimulusForRespPlot;
%
% Written by Anand C Krishnan (2025)
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


%% =======================================================================
%  Define Sampling Parameters
%  =======================================================================

Fs = 30e3;
% Sampling frequency in Hz (30 kHz)

T_total = 200e-3;
% Total duration of waveform window (200 ms)

t = 0:1/Fs:T_total;
% Time vector from 0 to 200 ms


%% =======================================================================
%  Align Time Vector to Stimulus Onset
%  =======================================================================

t = t - 50e-3;
% Shift time axis so stimulation begins at t = 0
%
% Final time range:
%   -0.05 s to +0.15 s


%% =======================================================================
%  Define Pulse Train Parameters
%  =======================================================================

Vs = 0.01;
% Pulse amplitude

f = 400;
% Pulse repetition frequency (Hz)

T = 1/f;
% Inter-pulse interval / pulse period

N = 7;
% Number of biphasic pulses in train


%% =======================================================================
%  Define Biphasic Pulse Shape
%  =======================================================================

t_start = 0;
% Time of first pulse onset

t_pos = 0.4e-3;
% Duration of positive phase (0.4 ms)

t_neg = 0.4e-3;
% Duration of negative phase (0.4 ms)


%% =======================================================================
%  Initialize Stimulus Waveform
%  =======================================================================

stim = zeros(size(t));
% Preallocate waveform vector


%% =======================================================================
%  Generate Biphasic Pulse Train
%  =======================================================================

for k = 0:N-1

    % Compute pulse onset time
    t0 = t_start + k*T;

    % Generate positive phase
    stim(t >= t0 & t < t0 + t_pos) = Vs;

    % Generate negative phase
    stim(t >= t0 + t_pos & ...
         t < t0 + t_pos + t_neg) = -Vs;

end


%% =======================================================================
%  Plot Stimulus Waveform
%  =======================================================================

plot(t, stim, ...
    'b', ...
    'LineWidth', 1);

% Plot formatting:
%   Blue trace
%   Line width = 1


%% =======================================================================
%  Format Axes
%  =======================================================================

xlabel('Time (sec)')

ylabel('Amplitude')

title('Biphasic Stimulation Pulse Train')

set(gca, ...
    'FontSize', 12, ...
    'FontName', 'Arial')

box on


%% =======================================================================
%  Set Figure Background
%  =======================================================================

set(gcf, 'Color', 'White');


end