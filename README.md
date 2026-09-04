# MREG Recon Toolbox

This repository contains an updated version of the MREG Recon Toolbox, which is used for reconstructing MREG data. The updated version includes several improvements and bug fixes over the original version.

### Updates

* Modify the repository to include the MIRT toolbox as a submodule, which is required for the reconstruction process.
* Added support for Matlab R2026a (under testing)
* Added support for parallelization using HTCondor


## Installation

1. Clone this repository including it's submodules

```
git clone --recurse-submodules https://github.com/fraimondo/mreg_recon_tool.git
```

2. Build the required mex from the MIRT toolbox.

Open Matlab and run the following commands:

```
cd mreg_recon_tool/external/mirt

setup

ir_mex_build

cd mex/src
irt_mex_make
cd ../../../../
```


## Usage

On every matlab session, run the following commands to set up the environment:

```
setup
```

Then you can simply run the GUI by calling:

```
mreg_recon_tool
```

## Compiling the mreg_recon_tool to run in a distributed environment

In order to benefit from the HTCondor or other distributed computing environment, you can compile the mreg_recon_tool_recon file to a standalone application so you can run it on a cluster without the need of having Matlab installed.

### Requirements

You will need to have the Matlab Compiler installed and licensed. You can check if you have it by running the following command in Matlab:

```
license('test', 'compiler)
```

You will also need to have the Matlab Runtime installed: https://www.mathworks.com/help/compiler/install-the-matlab-runtime.html

Once you have everything set up, you can compile the mreg_recon_tool_recon file by running the following command in Matlab, asuming you are in the root of the repository:

```
cd mreg_recon_tool
compile
```

### Configuring for HTCondor

The HTCondor/GNU-Parallel configuration is manipulated using environmental variables.

Variables can be set in matlab, before starting the GUI, using `setenv`

* `MR_ROOT`: Path to the Matlab Runtime installation. This is required for the standalone application to run on the cluster. This is the path you use to install the MR in the requirements step.
* `MREG_RECON_SA_PATH`g: Path to the compiled mreg_recon_tool_recon standalone application. This is required for the standalone application to run on the cluster. This is the path you use to install the MR in the requirements step.


Example that runs in my current setup:

```
setenv('MR_ROOT', '/data/project/coolproject/matlab_runtime/R2023a');
setenv('MREG_RECON_SA_PATH', '/data/project/coolproject/mreg_recon_tool/mreg_recon_tool/mreg_recon_tool_reconstandaloneApplication/run_mreg_recon_tool_recon.sh');

mreg_recon_tool
```



# Original README.txt from the MREG Recon Toolbox

Toolbox for reconstructing MREG data. Call mreg_recon_tool for starting the GUI.



Dependencies: 
You need the MIRT toolbox which you can download from 
http://web.eecs.umich.edu/~fessler/code/ 
Adhere to its readme and use the MIRT toolbox's setup.m for installation.

Nice to have: You don't really need the FSL Toolbox, but it's used to create nicer B0-maps that can be used for off-resonance correction. You can download it here:
http://fsl.fmr

Files that contain the remark "% Needs the toolbox of Benni Zahneisen" refer to the contents of the folder trajectories/common



For more details see manual_mreg_recon_tool.pdf

The folder 'psf' contains a sample of trajectory creation, and point spread function calculation, reproducing results from Riemenschneider et al., MRM, 2021.
The command mreg_recon_tool_noise_simulation opens a GUI that is identical to the mreg_recon_tool, but replaces every frame with kspace noise - to be used for the calculation of a g-factor simulation.



This toolbox works with Siemens data and uses the (included) mapVBVD tool from Philipp Ehses.
For the spirals in the creation of a spherical stack of spirals, modified code from Brian Hargreaves (mrsrl.stanford.edu/~brian/vdspiral/) is used.



Contributions to this toolbox have been made by:
Thimo Hugger
Benjamin Zahneisen
Jakob Assländer
Bruno Riemenschneider



