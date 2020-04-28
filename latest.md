---
layout: page
title: Latest
hide_title: true
hide_main_links: true
order: 4
permalink: /latest/
---

The following guide provides the latest instruction for using `automacs` from April 2020. This guide is the best way to start generating data quickly. Future development will be posted here and to the main documentation site.

## Overview

There are two ways to deploy this code.

1. In the ["standard" method](#standard) we clone automacs once per simulation. This is the fast and easy method.
2. In the ["tether" method](#tether) we maintain a single copy of automacs which can be easily version controlled. This is suitable for large projects.

## Requirements

This code should run on a standard linux box with very minimal dependencies. We use [Anaconda](https://www.anaconda.com/distribution/) to supply many of the basic dependencies. 

The primary requirement is [GROMACS](http://www.gromacs.org/). It is best to compile GROMACS yourself. If you are using an HPC resource, you should carefully select the right version of GROMACS and load the corresponding module. We provide an option for compiling GROMACS automatically via [Spack](https://spack.io/) for interested users. See below (["automatically compiling GROMACS"](#autogmx))for further instruction.

## A. Standard method {#standard}

The standard method uses the "factory" to manage a small set of dependencies along with a precompiled copy of GROMACS to run automacs. In this method, we clone one copy of automacs for each new simulation. This method is the simplest way to get started quickly, and works best for classes. The [tether method](#tether) requires slightly more work but allows you to manage a large project. We have summarized the procedure below.

> Note that we use a `makefile` in a very unorthodox way, as a simple interface to Python. All of the following `make` commands are not designed to compile an executable from source. Instead they just make it easy to call Python commands without installing lots of code.

~~~
# step 1: confirm gromacs
which gmx || which gmx_mpi || echo "cannot find gromacs"
# step 2: setup the factory
# location does not matter
git clone http://github.com/bradleyrp/factory -b streamline
cd factory
# save the location for later and for your notes
export FACTORY_ROOT=$PWD
echo $FACTORY_ROOT
make use specs/cli_replicator.yaml
# step 3: set up a conda environment
# this step automatically installs Miniconda and builds an environment
# the stdout explains how we set up the conda environment
cd $FACTORY_ROOT
make conda specs/env_std_md_extra.yaml
# step 4: source the environment
# make sure to run this before using automacs
source $FACTORY_ROOT/env.sh std
# your prompt should say "(std)" now
# step 5: configure modeller
# note that you need a modeller license key
make do specs/config_modeller_license.yaml
# the tether method diverges here. remain in the factory
# step 6: choose a new simulation for automacs simulations
# location does not matter. you can put new simulations anywhere
cd ~/path/to/save/simulations
# step 7: clone automacs once per simulation
git clone http://github.com/biophyscode/automacs -b ortho_clean v001
# go to the new simulation
cd v001
# clone extra codes
make setup all
# place a single PDB in the inputs folder
cp path/to/alk.wt.active.pdb ./inputs/
# edit the experiment: set the `start_structure` to the 
#   relative path to your PDB file under the `protein` experiment
#   each expts.yaml file contains several root level experiment names
#   and can be customized to select the right simulation settings
#   the start structure should be `./inputs/alk.wt.active.pdb`
#   without the backticks
vim ./inputs/proteins/protein_expts.yaml
# confirm that the `protein` experiment is on the sources list
make prep
# note that if you want to reset all the simulation data 
#   then you can clean everything with `make clean`
# step 8: un the simulation with a single command
make go protein
~~~

After installing this, there are fewer steps to make a simulation.

~~~
export FACTORY_ROOT=path/to/factory
source $FACTORY_ROOT/env.sh std
git clone http://github.com/biophyscode/automacs -b ortho_clean <simulation-name>
cd <simulation-name>
make setup all
# configure experiments files here
make go <experiment-name>
~~~

[//]: # tested above on heartland on 2020.04.22 with: source ~/factory/env.sh spack && source $(spack location -i gromacs@2019.3)/bin/GMXRC.bash

[//]: # note that you cannot use the 


The procedure above will generate log files and a summary of the commands it ran found in the `s01-protein/s01-protein.log`. We recommend running the simulation in a screen or on a scheduler if you are using a shared machine. 

This short guide does not cover the customizations available in the "experiments" file (`protein_expts.yaml`) which we used above. The code will search all files with the suffix `_expts.yaml` and make their root level objects e.g. `protein` available as targets for the `make go` command. 

To use automacs, you should add new experiments to these files and execute them with `make go`. The names must be unique, and ideally you should select more meaningful names than `protein` to indicate exactly what you are doing. The existing experiments files should serve as a useful template. 

New users can use a 4-character PDB code for the `start_structure` setting to automatically download a PDB file from the protein data bank (as long as the file is complete and includes only a single structure). Alternately, you can set `start_structure: null` to automatically detect a single PDB file in the `./inputs` folder. The best option is to explicitly include a path to the file, for example `./inputs/alk.wt.active.pdb`.

## B. Tether method {#tether}

The [standard method](#standard) is useful for quickly starting to use automacs. If you create many similar simulations, each with a single PDB file in the corresponding `inputs` folder, then it can be a simple way to scale your work. 

What if you want to keep all of your PDB files and experiments files (e.g. `protein_expts.yaml`) in a single place under version control? In that case, you should use the tether method.

The tether method will set up a single copy of automacs which can generate many different simulations. This centralizes your inputs and experiment files, and also allows you to maintain a single copy of automacs in case you would like to contribute to the code base, or get new changes to the code which can apply to all new simulations.

Instead of cloning a new copy of automacs for each simulation, we will set up a single copy with the factory and then point all new simulations to that copy. 

~~~
# step 1: confirm gromacs
which gmx || which gmx_mpi || echo "cannot find gromacs"
# step 2: setup the factory
# location does not matter
git clone http://github.com/bradleyrp/factory -b streamline
cd factory
# save the location for later and for your notes
export FACTORY_ROOT=$PWD
echo $FACTORY_ROOT
make use specs/cli_replicator.yaml
# step 3: set up a conda environment
# this step automatically installs Miniconda and builds an environment
# the stdout explains how we set up the conda environment
cd $FACTORY_ROOT
make conda specs/env_std_md_extra.yaml
# step 4: source the environment
# make sure to run this before using automacs
source $FACTORY_ROOT/env.sh std
# your prompt should say "(std)" now
# step 5: configure modeller
# note that you need a modeller license key
make do specs/config_modeller_license.yaml
# the tether method diverges here. remain in the factory
# step 6: clone a centralized copy of automacs
git clone http://github.com/biophyscode/automacs -b ortho_clean automacs
cd automacs
# save this path for later, and for your notes
export AMX_ROOT=$PWD
echo $AMX_ROOT
# clone extra codes
# note that you can add your own codes to the inputs folder
make setup all
# step 7: make a new simulation elsewhere
# go somwhere else
cd path/to/many/simulations
# make a new simulation in a subfolder
make -C $AMX_ROOT tether $PWD/v002
# the new simulation is stored in a new folder
cd v002
# inspect the links, which point back to automacs (see example below)
ls -all
# confirm that we can see the experiments
make prep
# edit an experiments file to set up the simulation
vim inputs/protein_expts.yaml
# step 7: run the simulation by name
make go protein
~~~

Note that each simulation will include links, via `ls -all`, back to the central automacs location.

~~~
amx -> /home/user/factory/automacs/amx
config.json -> /home/user/factory/automacs/config.json
inputs -> /home/user/factory/automacs/inputs
makefile -> /home/user/factory/automacs/makefile
ortho -> /home/user/factory/automacs/ortho
~~~

[//]: # tested above on heartland on 2020.04.22 with: source ~/work/factory/env.sh spack && source $(spack location -i gromacs@2019.3)/bin/GMXRC.bash

[//]: # !!! the `make setup all` step above fails silently without gromacs

See the overview below for more details on how to set up your experiments files.

To run a new simulation there are now fewer steps.

~~~
export FACTORY_ROOT=path/to/factory
source $FACTORY_ROOT/env.sh std
make -C $AMX_ROOT tether $PWD/<simulation-name>
cd <simulation-name>
# configure experiments files here
make go <experiment-name>
~~~

### Workflow overview

As with the standard method, the basic workflow for making new simulations requires that you edit an experiment file.

1. Edit or create a new file with the suffix `_expts.yaml`. You can start with `./inputs/protein_expts.yaml`. The file can be located anywhere in the `inputs` folder.
2. Inside this file, you create experiments which tell automacs how to run the simulation
3. Run `make go (name)` where the name is a unique root-level key inside an experiment file.

The `protein_expts.yaml` provides an experiment which combines two *other* experiments in a sequence called a "metarun". This experiment is called `alk_sim` and it performs a mutation followed by a simulation. The experiment looks like this:

~~~
alk_sim:
  notes: |
    This experiment does homology modeling followed by simulation.
    It is set to use the ALK mutation example above.
  metarun:
    - extends: mutation_basic_alk
      settings:
        step: mutate
    - extends: protein
      settings:
        start_structure: s01-mutate/structure-out.pdb
        step: simulate
~~~

The `extends` keywords all point to other root-level experiments. Hence the `alk_sim` experiment will execute the `mutation_basic_alk` experiment followed by the `protein` experiment. The `settings` below each will override the default settings for the experiment you are extending. This provides an extensible, modular syntax for running simulations.

Note that each irreducible unit of a metarun is another experiment, which itself is really just a Python script found under the `script` key. Some scripts will produce a different result depending on the inputs. For example, the `mutation_basic_mek` experiment provides some extra settings under `sequence_check` to fill in gaps in an incomplete PDB file. Compared to the `mutation_basic_alk` experiment, it has more settings, however both use the `modeller_mutation_script.py` to build homology models.

The process of configuring your experiments is partly a matter of taste. The experiments files are designed to be a useful record of each simulation.

## C. Automatically compiling GROMACS {#autogmx}

We strongly recommend that all users compile their own GROMACS (which is easy and illuminating) or use the modules system on an HPC resource. For users who need a fast way to deploy to a new system, the following commands are offered as a simple solution. 

~~~
# start from a preexisting factory at $FACTORY_ROOT
cd $FACTORY)_ROOT
# run the `make use` commands once to set up some other commands
make use specs/cli_spack.yaml
make use specs/cli_replicator.yaml
# edit the spack_tree.yaml file to set your GROMACS versions
# use: vim specs/spack_tree.yaml
# make sure you edit a specific recipe i.e. gromacs_minimal_cpu
# different recipes will compile different versions/features
# use the following command to run the build in a screen
# do not run `make screen` if you are already in a screen
# there are multiple recipes. we are using gromacs_centos8_gpu
make screen spack specs/spack_tree.yaml gromacs_centos8_gpu
# when it is finished, screen-screen_anon.tmp will disappear
~~~

The commands above will build MPI and FFTW from source using [Spack](https://spack.io).
