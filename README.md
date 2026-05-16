# FLTR3D

FLTR3D is an R–Fortran toolkit for simulating three-dimensional groundwater flow and contaminant transport. The model uses a Fortran computational core and an R interface for setting up input parameters, running the model, and reviewing output results.

## Overview

This repository includes source code for a 3-D groundwater flow and contaminant transport model. The main Fortran driver calls the geometry setup, physical/transport parameter setup, initial condition setup, and the time-marching flow and transport solver.

The R script provides an interface to load the compiled Fortran shared library, prepare model inputs, call the Fortran subroutine, and summarize the simulated hydraulic head and concentration results.

## Main Files

- `FLTR.f90` — Main Fortran driver for the 3-D groundwater flow and contaminant transport model.
- `run_FLTR.R` — R script used to call the Fortran subroutine and process model outputs.

## Requirements

- R
- gfortran
- Optional R package: `fields`

## How to Compile

On Linux or Mac, compile the Fortran code using:

```bash
gfortran -shared -fPIC -o FLTR.so FLTR.f90
