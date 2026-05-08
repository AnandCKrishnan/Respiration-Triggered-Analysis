
# Respiration Triggered Analysis

<br>

## Overview
This repository contains MATLAB tools for analyzing stimulation-triggered respiration responses from Intan recordings, including trigger detection, respiratory phase classification, and population averaging.

<br>

## Scripts

### 1. getRespirationPlotInputs

**Description:**
This function launches a graphical user interface (GUI) to collect
metadata and directory information required for respiration plotting
experiments involving electrical stimulation.

The GUI allows the user to input:
- Bird name
- Hemisphere (LH or RH)
- Experimental state (Anesthetized or Awake)
- Electrode configuration (E1E2 or E2E1)
- Electrode coordinates:
      • AP (Anterior-Posterior)
      • ML (Medial-Lateral)
      • Depth
- Stimulation current (µA)
- Path to the experiment/data directory

Outputs:
  BirdName         : Name/identifier of the subject
  Hemisphere       : Hemisphere used (LH or RH)
  State            : Experimental condition (Anesthetized or Awake)
  ElectrodeConfig  : Electrode polarity configuration
  AP               : AP coordinate (mm)
  ML               : ML coordinate (mm)
  Depth            : Electrode depth (mm)
  Current          : Stimulation current (µA)
  DataPath         : Selected experiment/data directory

Workflow:
1. GUI window is launched
2. User enters experiment metadata
3. User optionally browses for experiment directory
4. Pressing "Plot" validates and returns all parameters

Usage:<br>
  [BirdName, Hemisphere, State, ElectrodeConfig, ...
   AP, ML, Depth, Current, DataPath] = getRespirationPlotInputs();

Example:<br>
  [BirdName, Hemisphere, State, ElectrodeConfig, ...
   AP, ML, Depth, Current, DataPath] = getRespirationPlotInputs();


---
<br>

### 2. StimulusForRespPlot

**Description:**
Generates and plots a biphasic electrical stimulation pulse train used
as a visual overlay in respiration-triggered stimulation plots.

The stimulus consists of:
  - 7 biphasic pulses
  - 400 Hz pulse repetition frequency
  - 0.4 ms positive phase
  - 0.4 ms negative phase

The waveform is aligned such that stimulation onset occurs at t = 0,
allowing direct comparison with respiration traces aligned to trigger
onset.

Inputs:
  None

Outputs:
  stim    : Biphasic stimulus waveform vector
  t       : Time vector corresponding to stimulus waveform

Workflow:
1. Define sampling parameters
2. Generate time vector
3. Shift time axis to align stimulation at t = 0
4. Define pulse-train parameters
5. Generate biphasic pulse train
6. Plot stimulus waveform

Notes:
- Time window spans:
      • -50 ms pre-stimulus
      • +150 ms post-stimulus

- The generated waveform is intended primarily for visualization
  purposes in respiration-aligned plots.

- Positive and negative phases are charge-balanced.

Usage:<br>
  [stim, t] = StimulusForRespPlot;

Example:<br>
  [stim, t] = StimulusForRespPlot;

---
<br>

### 3. PlotStimTriggeredRespiration

**Description:**
This function analyzes stimulation-triggered respiration responses from
Intan recordings. Respiration traces are aligned to stimulation onset,
classified according to respiratory phase (inspiration or expiration),
and visualized as both individual traces and population averages.

The function:
- Loads respiration and digital trigger signals from Intan .rhd files
- Detects stimulation pulse trains from digital inputs
- Generates matched baseline trigger points
- Separates events into inspiratory and expiratory phases
- Randomly samples respiration traces around trigger points
- Plots:
      • Individual aligned respiration traces
      • Mean ± standard error traces

Inputs:
  None

User Inputs:
  Experimental metadata and recording directory are obtained through:

      getRespirationPlotInputs()

  The GUI collects:
  - Bird name
  - Hemisphere
  - Experimental state
  - Electrode configuration
  - Electrode coordinates:
        • AP
        • ML
        • Depth
  - Stimulation current
  - Data directory path

Workflow:
1. Launch metadata input GUI
2. Load Intan respiration and trigger recordings
3. Filter respiration signal
4. Detect stimulation pulse trains
5. Generate matched baseline trigger indices
6. Classify events into:
      • Inspiration
      • Expiration
7. Randomly sample respiration epochs
8. Plot:
      • Individual traces
      • Mean ± standard error

Requirements:
  - getRespirationPlotInputs function
  - read_Intan_RHD2000_file_M function
  - StimulusForRespPlot function/script

Usage:<br>
  PlotStimTriggeredRespiration()

Example:<br>
  PlotStimTriggeredRespiration()


---
<br>

### Written by Anand C Krishnan (2026)


These MATLAB scripts are intended for research use within Rajan Lab, IISER Pune.<br>
Please acknowledge the author if this code contributes to your work.
