# Description

This collection of Matlab and LS-DYNA files will run a series of benchmark simulations on three different muscle models in LS-DYNA: MAT_156 [2], EHTM [3], and the VEXAT [4]. The benchmarks include simulations of the active and passive force-length relation [5], the (isokinetic) force-velocity relation [6], active-lengthening on the descending limb of the force-length relation [7], and the response of active muscle to vibration [8].


## System Configurations Tested

To date this benchmark has been run on Ubuntu 22.04.4 LTS and 20.04.6 LTS. While I have taken care to use system-independent functions for file paths, you may encounter difficulty running these scripts on Windows. For example, on another project, I found the Matlab function pinv behaved differently on Windows and Ubuntu. While this was easy to fix, since I haven't run the benchmark code on a Windows machine I cannot yet guarantee that it will run without error.


## Running the Benchmark in Millard et al.

1. Clone and build the LS-DYNA implementations of the VEXAT and EHTM muscle models by following the instructions in the README.md file of https://github.com/mjhmilla/Millard2023VexatMuscle/

2. Clone this repository to your computer.

3. Open main_simulateExperiments.m and modify the following variables:

    1. *lsdynaBin_MPP_931* (near line 24): update the path to point to the mppdyna executable built in step 1.

    2. *lsdynaBin_SMP_931* (near line 27): (optional) update this path to point to the lsdyna executable if you have built it.

    3. The script is configured to run all three models: MAT_156, EHTM, and the VEXAT. If you do not want to run all of these models you will have to make the following edits:

        1.  Go to the line <code>models(3) = struct('id',0,'name','');</code> (near line 55) and change the 3 to the number of models that you want to run.

        2. Comment out the block of entries for each model that you do not want to run. For example, if you do not want to run EHTM then add a '%' in front of these lines (linear 67-70) to comment them out: <code> 
% indexUmat41              = 2;
% models(indexUmat41).id   = 2;
% models(indexUmat41).name ='umat41';
% models(indexUmat41).colors= [cs.yellow;cs.yellow]; </code>

        3. Update the index variables and id of the entries that you do want to simulate. Assuming that you do not want to run EHTM you'll need to ensure that the remaining two models have contiguous id's starting from 1: <code>
indexMat56                = 1;
models(indexMat56).id     = 1; </code> and <code>
indexUmat43              = 2;
models(indexUmat43).id   = 2; </code>       




4. Open main_fitMusclesToHL2002Simulation.m and modify the following variable:
    1. *lsdynaBin_MPP_931* (near line 40): set this path to the location where your mppdyna executable is built in step 1.

5. Open main_fitAndRun.m and ensure that the following variables are set:

    1. <code>simMode = 'run';</code> (near line 11)

    2. <code>fitFlags = [1;1;1];</code> (near line 15)

    3. <code>runAndPlotFlags = [1;1;1;1];</code> (near line 21)

6. Make sure that <code>flag_outerLoopMode=1;</code> at the top of these files (near line 7): 

    - main_fitMuscles.m

    - main_fitMusclesToHL2002Simulation.m

    - main_simulateExperiments.m

7. Start Matlab in the SingleMuscleSimulationsLSDYNA directory and run main_fitAndRun.m. After a few minutes you should see LS-DYNA start up and print informationt to the screen for each integration step. It may take 20-40 minutes to run all of the benchmarks on a 4 core machine.

8. After the simulations have completed you can generate the plots that appear in the paper by doing the following:

    1. Open main_fitAndRun.m

    2. Set <code>simMode = 'plot';</code> (near line 11)

    3. Run main_fitAndRun. It will take 5-10 minutes to generate all of the plots.

    4. You can find the plots (in pdf and fig formats) in these locations:
        
        - Figure 1: *SingleMuscleSimulationsLSDYNA/output/fig_MuscleFitting_HL2002_HL1997_Publication.pdf*

        - Figure 3: *SingleMuscleSimulationsLSDYNA/output/MPP_R931/fig_MPP_R931_active_passive_force_length_Publication.pdf*

        - Figure 4: *SingleMuscleSimulationsLSDYNA/output/MPP_R931/fig_MPP_R931_force_velocity_Publication.pdf*

        - Figures 5,6,10,11: *SingleMuscleSimulationsLSDYNA/output/MPP_R931/fig_MPP_R931_eccentric_HerzogLeonard2002_Publication*

        - Figures 8,9,12:  *SingleMuscleSimulationsLSDYNA/output/MPP_R931/fig_MPP_R931_impedance_Kirsch1994_Publication.pdf*


## Folder Layout

- *SingleMuscleSimulationsLSDYNA* all of the files that begin with *main_* in this folder can be run directly. Unless you are digging into the details, you will only ever need to run *main_fitAndRun.m*.
    
    - *main_fitAndRun.m*: 
        - The file used to fit, run, and plot the results of all models and benchmark simulations.
    
    - *main_fitMuscles.m*: 
        - The file used to fit the force-length-velocity properties of the MAT_156, EHTMM, and VEXAT models
    
    - *main_fitMusclesToHL2002Simulation.m*: 
        - The file used to fit the active titin properties of the VEXAT model
    
    - *main_simulateExperiments.m*: 
        - The file used to simulate and plot the results of an individual type of simulation

    - *main_createLSDYNASinusoid.m*: 
        - used to generate a discretized sinusoid file in *output/curves/sinusoid_curve.k*. This file is used in the reflex benchmark which is not included in the paper [1].

    - *main_generateActivePassiveForceLengthTrials.m* (advanced): 
        - used to generate all the LS-DYNA files that appear in the individual active-passive-force-length simulation folders, for example, *SingleMuscleSimulationsLSDYNA/MPP_R931/umat43/active_passive_force_length/active_force_length_00/active_force_length_00.k*.

    - *main_generateForceVelocityTrialsFitToData.m* (advanced): 
        - (advanced) used to generate the maximum and sub-maximum activation isokinetic force-velocity trials that appear in, for example, *SingleMuscleSimulationsLSDYNA/MPP_R931/umat43/force_velocity/force_velocity_00/force_velocity_00.k*. Here the 'FitToData' refers to the fact that the isokinetic ramps have been extracted from the digitized figures from Herzog and Leonard 1997 [9].

    - *main_generateForceVelocityTrials.m* (advanced + not used): 
        - used to generate the maximum activation isokinetic force-velocity trials with normalized ramp velocities extracted from Herzog and Leonard 1997 [9] and Siebert et al. [10].

    - *main_generateImpedanceTrials.m* (advanced): 
        - used to generate the length perturbation files and individual simulation files needed to simulate Kirsch et al. [8]. You can see an example of these files here
        - Pseudorandom perturbation: *SingleMuscleSimulationsLSDYNA/MPP_R931/umat43/impedance_Kirsch1994/impedance_0p8mm_35Hz_01_first/perturbation_curve_lcid4.k*
        - Simulation file: *SingleMuscleSimulationsLSDYNA/MPP_R931/umat43/impedance_Kirsch1994/impedance_0p8mm_35Hz_01_first/impedance_0p8mm_35Hz_01_first.k*

    - *getSimulationInformation.m*: (Do not run) A function that retrieves the meta data needed to run and plot the simulations of each combination of model and simulation.

- Folders that hold simulation results and plots

    - *MPP_R931*: has all of the files needed to run the simulations for each model. Note that all of the models make use of a set of common muscle parameters in *MPP_R931/common*. 

    - *SMP_R931*: (not used at the moment) where simulation files would be held for the SMP build

    - *output*: contains the fitting specific plots (common to all models)

    - *output/MPP_R931*: contains the plots specific to the MPP_R931 build

- Folders that hold the reference data that is used to fit the models and also to generate the final plots:

    - ReferenceExperiments: holds the manually digitized data from the literature
    - ReferenceCurves: (deprecated) holds the data for the curves that define the force-length-velocity curves used in the model. This data is no longer used.

- Folders that contain the numerous custom made functions to fit, run, and post-process the simulation results. There is quite a lot of code in these folders because I've written a Matlab implementation of the models that are used during fitting. While the LS-DYNA implementations can also be used for fitting, I have not done this because it would have required a lot more development time on my part because I do not have access to LS-DYNA on my local machine. All of these are advanced functions and should not be carelessly edited.
    - curves  
        - contains libraries of functions needed to construct the curves for several models (EHTM and VEXAT) and also from literature data (Siebert2015) as well as generic parametric curve libraries (BezierCurveLibrary and the experimental TangentCurveLibrary).
    - fitting
        - contains the library of functions needed to fit the models
    - models
        - contains code for the pennation model.
    - numeric
        - contains code for generic numeric functions, which is limited to calcCentralDifferenceDataSeries.m for now.
    - parameters
        - contains code to generate the parameters for default models of the feline soleus, the human soleus, and the rabbit psoas (fibril).
    - pergatory
        - where code is put that isn't being used, but isn't yet ready to be really thrown out.
    - postprocessing
        - a huge number of functions that are used to add individual experimental data series to a subplot (e.g. addBrownScottLoeb1996ActiveForceLength.m) and to generate publication quality plots (e.g. plotActivePassiveForceLengthSimulationDataForPublication).
    - preprocessing
        - Functions that are primarily used to write specific LS-DYNA files prior to simulation    
    - LICENSES
        - Contains the license files employed in this project


## Licensing

All of the code and files in this repository are covered by the license mentioned in the SPDX file header which makes it possible to audit the licenses in this code base using the ```reuse lint``` command from https://api.reuse.software/. A full copy of the license can be found in the LICENSES folder. To keep the reuse tool happy even this file has a license:

 SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>

 SPDX-License-Identifier: MIT

## References

1.  A benchmark of muscle models to length changes great and small
Matthew Millard, Norman Stutzig, Jorg Fehr, Tobias Siebert
bioRxiv 2024.07.26.605117; doi: https://doi.org/10.1101/2024.07.26.605117 (submitted to Journal of the Mechanical Behavior of Biomedical Materials)

2. LS-DYNA keyword user’s manual volume II material models: LS-DYNA R9.0, see MAT 156 on pg. 2-792, Livermore Software Technology Corporation, Livermore, California, Aug. 2016.


3. Martynenko OV, Kempter F, Kleinbach C, Nölle LV, Lerge P, Schmitt S, Fehr J. Development and verification of a physiologically motivated internal controller for the open-source extended Hill-type muscle model in LS-DYNA. Biomechanics and Modeling in Mechanobiology. 2023 Dec;22(6):2003-32. https://doi.org/10.1007/s10237-023-01748-9

4. Millard M, Franklin DW, Herzog W. A three filament mechanistic model of musculotendon force and impedance. eLife 12:RP88344, https://doi.org/10.7554/eLife.88344.3, 2024 (accepted)

5. Gordon AM, Huxley AF, Julian FJ. The variation in isometric tension with sarcomere length in vertebrate muscle fibres. The Journal of physiology. 1966 May 1;184(1):170-92. https://doi.org/10.1113/jphysiol.1966.sp007909

6. Hill AV. The heat of shortening and the dynamic constants of muscle. Proceedings of the Royal Society of London. Series B-Biological Sciences. 1938 Oct 10;126(843):136-95. https://doi.org/10.1098/rspb.1938.0050

7. Herzog W, Leonard TR. Force enhancement following stretching of skeletal muscle: a new mechanism. Journal of Experimental Biology. 2002 May 1;205(9):1275-83. 
https://doi.org/10.1242/jeb.205.9.1275

8. Kirsch RF, Boskov D, Rymer WZ. Muscle stiffness during transient and continuous movements of cat muscle: perturbation characteristics and physiological relevance. IEEE Transactions on Biomedical Engineering. 1994 Aug;41(8):758-70. https://doi.org/10.1109/10.310091

9. Herzog W, Leonard TR. Depression of cat soleus forces following isokinetic shortening. Journal of biomechanics. 1997 Sep 1;30(9):865-72. https://doi.org/10.1016/S0021-9290(97)00046-8

10. Siebert T, Leichsenring K, Rode C, Wick C, Stutzig N, Schubert H, Blickhan R, Böl M. Three-dimensional muscle architecture and comprehensive dynamic properties of rabbit gastrocnemius, plantaris and soleus: input for simulation studies. PLoS one. 2015 Jun 26;10(6):e0130985. https://doi.org/10.1371/journal.pone.0130985