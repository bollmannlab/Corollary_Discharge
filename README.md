# Code for _A Synaptic Corollary Discharge Signal Suppresses Midbrain Visual Processing During Saccade-Like Locomotion_ by Ali, Lischka, Preuss, Trivedi, Bollmann 2023

This repository contains calcium signal detection code used for Ali, Lischka et al. 2023. The corresponding author is [Johann H. Bollmann](http://bollmannlab.org/contact/).

The MATLAB file `SigFit.m` is a standalone file that loads example traces from `roisExample.mat` and outputs results in the form of graph plots.

### System requirements

The script was written and tested on MATLAB 2021a with dependencies including Parallel Computing Toolbox and Mapping Toolbox on Windows10 64 bit. System requirements and supported compilers for MATLAB versions can be found on [System Requirements for Windows](https://uk.mathworks.com/support/requirements/previous-releases.html).

### Installation guide

A detailed installation guide for MATLAB is available on [Installation and Licensing](https://uk.mathworks.com/help/install/?s_tid=hp_ff_s_install).
Typical install time is 20-30 minutes.

### Demo

Open `SigFit.m` and press Run(F5) on MATLAB Editor tab. Change Current Folder, if prompted, to the folder where `SigFit.m` is saved. This script will load `roisExample.mat` demo dataset and output results in the form of graph plots.
Expected time to run the script is <10 seconds.

### Instructions for use

Load your Ca2+ imaging data as a .mat file named `roisExample.mat`, such that it contains:
| Name | Description |
|------|-------------|
| ``sdata_rois`` | a two-dimensional double matrix (frames x rois) with time series data points in rows and each coloumn representing a time series (e.g. 88 frames x 14 rois) |
| ``frame_time`` | a 1x1 double for acquisition frame time in seconds |
| ``swim_time`` | a 1x1 double for time of swim onset in seconds |
