#!/bin/bash
ssh_itm="mmillard@scholze.itm.uni-stuttgart.de"
sim_dir_itm="/scratch/tmp/mmillard/muscleModeling/SingleMuscleSimulationsLSDYNA/MPP_R931"
sim_dir_local=$PWD/"MPP_R931"



#rsync -r ${ssh_itm}:${sim_dir_itm}/mat156/active_passive_force_length/ ${sim_dir_local}/mat156/active_passive_force_length/
rsync -r ${ssh_itm}:${sim_dir_itm}/mat156/force_velocity/ ${sim_dir_local}/mat156/force_velocity/
#rsync -r ${ssh_itm}:${sim_dir_itm}/mat156/eccentric_HerzogLeonard2002/ ${sim_dir_local}/mat156/eccentric_HerzogLeonard2002/
#rsync -r ${ssh_itm}:${sim_dir_itm}/mat156/impedance_Kirsch1994/ ${sim_dir_local}/mat156/impedance_Kirsch1994/

#rsync -r ${ssh_itm}:${sim_dir_itm}/umat41/active_passive_force_length/ ${sim_dir_local}/umat41/active_passive_force_length/
rsync -r ${ssh_itm}:${sim_dir_itm}/umat41/force_velocity/ ${sim_dir_local}/umat41/force_velocity/
#rsync -r ${ssh_itm}:${sim_dir_itm}/umat41/eccentric_HerzogLeonard2002/ ${sim_dir_local}/umat41/eccentric_HerzogLeonard2002/
#rsync -r ${ssh_itm}:${sim_dir_itm}/umat41/impedance_Kirsch1994/ ${sim_dir_local}/umat41/impedance_Kirsch1994/

#rsync -r ${ssh_itm}:${sim_dir_itm}/umat43/active_passive_force_length/ ${sim_dir_local}/umat43/active_passive_force_length/
rsync -r ${ssh_itm}:${sim_dir_itm}/umat43/force_velocity/ ${sim_dir_local}/umat43/force_velocity/
#rsync -r ${ssh_itm}:${sim_dir_itm}/umat43/eccentric_HerzogLeonard2002/ ${sim_dir_local}/umat43/eccentric_HerzogLeonard2002/
#rsync -r ${ssh_itm}:${sim_dir_itm}/umat43/impedance_Kirsch1994/ ${sim_dir_local}/umat43/impedance_Kirsch1994/

