# Description

The purpose of this small library is to simulate single-muscle experiments using mathematical muscle models that have been implemented in LS-DYNA. 

# Quick Start

- Read Kleinbach et al.
- Download the source code for Kleinbach et al. from: https://zenodo.org/
record/826209
- Add in the ZEROIN method from Forsythe et al.
- Compile a verson of LS-DYNA that includes the user material from Kleinbach et al. (this requires a special LS-DYNA license.
- Open `main_comparisonUmat.m` and update the `lsdynaBin_SMP_931` and `matlabScriptPath`
- Set both `flag_runSimulations`, and `flag_postProcessSimulationData` to 1.
- Choose which benchmark simulations you would like to run by setting the flags `flag_runIsometricSimulations`, `flag_runConcentricSimulations`, `flag_runQuickReleaseSimulations`, `flag_runEccentricSimulations`.
- Run `main_comparisonUmat.m`
- The output plots will appear in the `output` folder.

# Simulations of experiments

Numerical simulations of experiments appear in the folders SMP_931, which refers to a Single core Multiple Processor version of LS-DYNA version 9.31. The list of experiments currently includes:

- isometric (Gunther et al)
- concentric (Gunther et al)
- quickrelease (Gunther et al)
- eccentric (Herzog and Leonard)
- impedance (Kirsch et al.)

The LS-DYNA scripts necessary to run the experiments appear in SMP_931/ while the data from the experiments appears in ReferenceExperiments/. 


## References

- Forsythe, G.E.; Malcolm, M.A.; Moler, C.B.: Computer Methods for Mathematical Computations. Prentice Hall Professional Technical Reference, 1977
- Günther M, Schmitt S, Wank V. High-frequency oscillations as a consequence of neglected serial damping in Hill-type muscle models. Biological cybernetics. 2007 Jul;97(1):63-79.
- Herzog W, Leonard TR. Force enhancement following stretching of skeletal muscle: a new mechanism. Journal of Experimental Biology. 2002 May 1;205(9):1275-83.
- Kirsch RF, Boskov D, Rymer WZ. Muscle stiffness during transient and continuous movements of cat muscle: perturbation characteristics and physiological relevance. IEEE Transactions on Biomedical Engineering. 1994 Aug;41(8):758-70.
- Kleinbach C, Martynenko O, Promies J, Haeufle DF, Fehr J, Schmitt S. Implementation and validation of the extended Hill-type muscle model with robust routing capabilities in LS-DYNA for active human body models. Biomedical engineering online. 2017 Dec;16(1):1-28.


