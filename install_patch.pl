#!/usr/bin/perl

use warnings;
use strict;
use Cwd;
use File::Copy;
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);

# check to ensure that we are at the top of the FLASH directory
if (-d "source") {

  # initialize operation flags
  my $op1 = 'true';
  my $op2 = 'true';
  my $op3 = 'true';

  # get current directory
  my $mycwd = getcwd;

  # add new multiresolution directory in GridSolvers + paramesh-modified files
  my $newdir1 = "$mycwd/source/Grid/GridSolvers/Multiresolution";
  my $newdir2 = "$mycwd/source/Grid/GridMain/paramesh/multiresolution";

  # add the directories
  mkdir($newdir1) or $op1 = 'false';
  mkdir($newdir2) or $op1 = 'false';

  # grid files to copy to new paramesh-modified directory
  my @copies = ("gr_expandDomain.F90",
                  "Grid_data.F90",
                  "Grid_init.F90",
                  "Grid_finalize.F90",
                  "Grid_markRefineDerefine.F90",
                  "Grid_updateRefinement.F90");

  # perform copy operation
  my $toparamesh = "$mycwd/source/Grid/GridMain/paramesh";
  foreach (@copies)
  {
    copy("$toparamesh/$_", "$newdir2/$_") or $op2 = 'false';
  }

  # create new mrPPMKernel directory
  my $toppm = "$mycwd/source/physics/Hydro/HydroMain/split/PPM";
  mkdir("$toppm/mrPPMKernel") or $op3 = 'false';

  # files to copy over
  @copies = ("avisco.F90",
                  "cma_flatten.F90",
                  "detect.F90",
                  "flaten.F90",
                  "grdvel.F90",
                  "Makefile",
                  "riemann_hlle.F90");

  # perform copy operation
  foreach (@copies)
  {
    copy("$toppm/PPMKernel/$_", "$toppm/mrPPMKernel/$_") or $op3 = 'false';
  }

  # core ppm files
  copy("$toppm/PPMKernel/hydro_1d.F90", "$toppm/mrPPMKernel/ppm_hydro.F90") or $op3 = 'false';
  copy("$toppm/PPMKernel/intrfc.F90", "$toppm/mrPPMKernel/ppm_intrfc.F90") or $op3 = 'false';
  copy("$toppm/PPMKernel/interp.F90", "$toppm/mrPPMKernel/ppm_interp.F90") or $op3 = 'false';
  copy("$toppm/PPMKernel/monot.F90", "$toppm/mrPPMKernel/ppm_profile.F90") or $op3 = 'false';
  copy("$toppm/PPMKernel/states.F90", "$toppm/mrPPMKernel/ppm_states.F90") or $op3 = 'false';
  copy("$toppm/PPMKernel/rieman.F90", "$toppm/mrPPMKernel/ppm_riemann.F90") or $op3 = 'false';

  # apply patch
  `patch -p0 < hamr.patch`;

  # print update
  if ($op1 and $op2 and $op3) {
    print("\nSuccessfully applied patch. Multiresolution-driven AMR is enabled by including +amr_wvlt on the setup line. See README for more details. \n\n");
  } else {
    print("\nPatch not applied successfully...\n\n");
  }

} else {

  # print error message
  print("\nThe current working directory may not be properly set. 
          Expecting source/ to be in the current working directory.\n");
  print("\n");

}

