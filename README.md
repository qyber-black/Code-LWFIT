# LWFIT

LWFIT code for GABA quantification from MEGA-PRESS magnetic resonance spectra. It is
based on a peak integration approach in the frequency domain to estimate the
concentration of the metabolites.

The code requires matlab to run.  It was originally developed using matlab 2017b and
has also been tested with Matlab R2021a (9.10.0.1602886) under Linux. To use the code,
start with the Matlab live scripts Notebook-XX.mlx which show how to use the individual
functions. Further details are in the comments of the relevant functions.

LWFIT aligns the edit-off and difference spectra so that the main NAA peak is
precisely at 2.01 ppm and then calculates the areas for
  * NAA: 1.91 - 2.11 ppm, difference,
  * Cr: 2.90 - 3.10 ppm, edit-off,
  * GABA: 2.90 - 3.12 ppm, difference,
  * Glu and Gln, GLX1: 2.25 - 2.45 ppm, difference,
  * and GLX2: 3.65 - 3.85 ppm, difference.

It uses the real frequency-domain spectra and numerically integrates the peaks
using piecewise-linear functions over the indicated fixed ppm ranges, selected to
minimise contamination from other signals. Lorentzian, Gaussian and spline fitting
and several baseline fitting and filtering methods were explored but initial testing
indicated that numerical integration with minimal pre-processing yielded the most
accurate estimation results of the methods considered. While more aggressive noise
filters aesthetically improve the quality of the spectra, their application tends to
exacerbate underestimation of GABA, especially for weak signals, suggesting that
filtering eliminates some of the GABA signal present in the data. So we only
perform zero-filling (4096 points) and a frequency shift to align the NAA peak.

The code has been used in the following paper and more details are available there:

CW Jenkins, M Chandler, FC Langbein, SM Shermer. **Benchmarking GABA Quantification:
A Ground Truth Data Set and Comparative Analysis of TARQUIN, LCModel, jMRUI and
Gannet.** [[arxiv:1909.02163]](https://arxiv.org/abs/1909.02163).

The analysis results of LWFIT used in that paper for a specific dataset, using
the Matlab live scripts above are in the wiki, with all results computed and also
converted to PDF.

## Locations

The code is developed and maintained on [qyber\\black](https://qyber.black)
at https://qyber.black/pca/code-lwfit

This code is mirrored at
* https://github.com/xis10z/Code-LWFIT

The mirrors are only for convenience, accessibility and backup.

## People

* [Sophie M Shermer](https://qyber.black/lw1660), [Physics](https://www.swansea.ac.uk/physics), [Swansea University](https://www.swansea.ac.uk/)
* [Christopher W Jenkins](https://qyber.black/chris), [Physics](https://www.swansea.ac.uk/physics) and [Centre for Nanohealth](https://www.swansea.ac.uk/nanohealth/facilities/) and [Clinical Imaging Unit](https://www.swansea.ac.uk/medicine/research/researchfacilities/jointclinicalresearchfacility/clinicalimagingfacility/), [Swansea University](https://www.swansea.ac.uk/); [Cardiff University Brain Research Imaging Centre (CUBRIC)](https://www.cardiff.ac.uk/cardiff-university-brain-research-imaging-centre)
* [Frank C Langbein](https://qyber.black/xis10z), [School of Computer Science and Informatics](https://www.cardiff.ac.uk/computer-science), [Cardiff University](https://www.cardiff.ac.uk/); [langbein.org](https://langbein.org/)
* [Max Chandler](https://qyber.black/max), [School of Computer Science and Informatics](https://www.cardiff.ac.uk/computer-science), [Cardiff University](https://www.cardiff.ac.uk/)

## License

Copyright (C) 2019-2021, Sophie M Shermer, Swansea University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
