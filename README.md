# chem-sieve-external-dependencies

This repository contains the source tarballs for the main dependencies required
to build sieve.	

The file xdrfile-1.1.4.tar.gz was downloaded from
https://github.com/chemfiles/xdrfile

The file CGAL-6.0.1.tar.xz was downloaded from 
https://www.cgal.org/2024/10/22/cgal601/ 

The file nauty2_8_8.tar.gz was downloaded from https://pallini.di.uniroma1.it

The file hdf5-1.14.6.tar.gz was downloaded from https://www.hdfgroup.org/download-hdf5/source-code/ 

The file fftw-3.3.10.tar.gz was downloaded from https://www.fftw.org/download.html  

The file eigen-3.4.0.tar.gz was downloaded from https://eigen.tuxfamily.org/

The file gadgets/ezETAProgressBar.hpp was dowloaded from
https://ezprogressbar.sourceforge.net and slightly adapted

The file tclap-1.2.5.tar.gz was downloaded from https://tclap.sourceforge.net  

Due to the large size of the Boost library, this repository includes a split
version (8 parts) of the original tarball distributed by Boost. The script
create-boost-parts_1.88.0.sh is used to generate the split files.

