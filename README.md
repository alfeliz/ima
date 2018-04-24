# ima
Octave script to obtain the edges from an streak image and obtain the pressure and velocity of the plasma expansion.


## Operation

It asks for the file, that should be a *.dat format, and binarize the matrix and finds:
* Radial plasma expansion,
* Velocity of the plasma,
* Presure, based on the Hugoniot curves.

It saves two text files, one with the radial expansion of each side and other with the radial expansion, velocity, and pressure. 
Also, a *.jpg file is created that show the binarized matrix.

