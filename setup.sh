HERE=${PWD}

VASPROOT=${PWD}/$1

cd ${VASPROOT}
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_root.txt CMakeLists.txt

cd ${VASPROOT}/src
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_src.txt CMakeLists.txt

cd ${VASPROOT}/src/fftlib
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_fftlib.txt CMakeLists.txt

cd ${VASPROOT}/src/HIP
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_HIP.txt CMakeLists.txt

cd ${VASPROOT}/src/lib
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_lib.txt CMakeLists.txt

cd ${VASPROOT}/src/oneapi
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_oneapi.txt CMakeLists.txt

cd ${VASPROOT}/src/parser
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_parser.txt CMakeLists.txt

cd ${VASPROOT}/src/vaspml
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_vaspml.txt CMakeLists.txt

cd ${VASPROOT}/testsuite
ln -fs ${VASPROOT}/cmake/CMakeLists/CMakeLists_testsuite.txt CMakeLists.txt

cd ${HERE}
