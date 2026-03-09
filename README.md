![VASP](vasp-logo.png)

This repository contains the CMake build system files for VASP.

After you downloaded an official VASP source tarball you can clone this repository and follow the steps outlined below to use cmake to build VASP.

Branching follows VASP major releases: for each major release there is a matching
branch named `6.6.x`, etc.

* Clone the repository into the root directory of your VASP distribution:
  ```
  cd /your/vasp/directory
  git clone git@github.com:vasp-dev/cmake.git cmake
  ```

* Run the setup script (creating `CMakeLists.txt` symlinks in the VASP tree):
  ```
  bash cmake/setup.sh
  ```

* Create a build directory and run cmake:
  ```
  mkdir -p your-build-dir
  cd your-build-dir

  # Configure (example): point CMake to the VASP source root and pass options
  cmake /your/vasp/directory \
    -DVASP_OPENMP=ON \
    -DVASP_HDF5=ON

  # Optional: use Ninja instead of Make
  # cmake /your/vasp/directory -G Ninja -DVASP_OPENMP=ON
  ```

* And build VASP (in the ``your-build-dir`` directory):
  ```
  make -j all
  ```

For more information please visit the [VASP wiki](https://www.vasp.at/wiki/cmake).

## Supported Compilers

Compiler handling is implemented in `cmake/sources_and_flags_options.cmake` via CMake's
`CMAKE_Fortran_COMPILER_ID`. The following Fortran compiler IDs are explicitly handled:

- `GNU` (gfortran)
- `Intel` / `IntelLLVM` (ifort / ifx) with GPU support via Inel OneApi for Intel GPUs
- `NVHPC` (nvfortran) with GPU support via OpenACC
- `Flang` (LLVM flang)
- `Cray` (crayftn) with GPU support via ROCm for AMD GPUs
- `Fujitsu` (Fujitsu Fortran compiler)
- `NFORT` (NEC nfort)

## CMake Options (VASP_*)

All options are passed to CMake as `-D<name>=<value>`.

### General build features

- `-DVASP_OPENMP=ON|OFF`: enable OpenMP (default: OFF)
- `-DVASP_FFTLIB=ON|OFF`: enable internal FFTLIB (default: OFF)
- `-DVASP_TESTSUITE=ON|OFF`: enable testsuite in build directory (default: ON)

### Optimization / CPU tuning

- `-DVASP_OFLAG=<flag>`: override the default optimization flag (e.g. `-O3`, `-Ofast`) (default: empty)
- `-DVASP_TARGET_CPU=<arch>`: target CPU architecture (e.g. `native`, `skylake`, `zen3`) (default: empty)

### MPI / runtime-related toggles

- `-DVASP_COLLECTIVE=ON|OFF`: enable MPI collectives (default: ON)
- `-DVASP_MPI_INPLACE=ON|OFF`: use MPI inplace (default: ON)
- `-DVASP_MPI_BLOCK=<n>`: MPI block size (default: `8000`)
- `-DVASP_CACHE_SIZE=<n>`: cache size (default: `4000`)

### Memory / algorithmic toggles

- `-DVASP_AVOIDALLOC=ON|OFF`: avoid automatic allocation (default: ON)
- `-DVASP_SHMEM=ON|OFF`: enable shared memory for reduced memory usage (default: OFF)
- `-DVASP_SHMEM_BCAST=ON|OFF`: enable shared memory MPI bcast (default: OFF)
- `-DVASP_SHMEM_RPROJ=ON|OFF`: enable shared memory for PAW projections (default: OFF)
- `-DVASP_SYSV=ON|OFF`: enable shared-memory for ipcs and System-V (default: OFF)

### VASP feature switches

- `-DVASP_PLUGINS=ON|OFF`: enable VASP plugin support (default: OFF)
- `-DVASP_TBDYN=ON|OFF`: enable advanced molecular dynamics (default: ON)
- `-DVASP_FOCK_DBLBUF=ON|OFF`: enable double buffering for exchange potential (default: ON)
- `-DVASP_QD_EMULATE=ON|OFF`: use QD library for quadruple precision types (default: OFF)
- `-DVASP_PROFILING=ON|OFF`: enable profiling (default: OFF)
- `-DVASP_VASP6=ON|OFF`: enable VASP 6.x features (default: ON)

### External library support

- `-DVASP_SCALAPACK=ON|OFF`: enable ScaLAPACK (default: ON)
- `-DVASP_HDF5=ON|OFF`: enable HDF5 support (default: ON)
- `-DVASP_LIBXC=ON|OFF`: enable Libxc (default: OFF)
- `-DVASP_LIBBEEF=ON|OFF`: enable libbeef (van-der-Waals functionals) (default: OFF)
- `-DVASP_DFTD4=ON|OFF`: enable DFTD4 (default: OFF)
- `-DVASP_WANNIER90=ON|OFF`: enable Wannier90 (default: OFF)

### GPU / offloading

- `-DVASP_CUDA=ON|OFF`: enable CUDA acceleration (default: OFF)
- `-DVASP_CUDA_VERSION=<ver>`: CUDA version passed to NVHPC (example: `-DVASP_CUDA_VERSION=12.6`) (default: `Default`)
- `-DVASP_USE_NCCL=ON|OFF`: enable NCCL support (default: ON)
- `-DVASP_CUSOLVERMP=ON|OFF`: enable cuSOLVERmp/cublasmp (requires ScaLAPACK) (default: ON)
- `-DVASP_OMP_OFFLOAD=ON|OFF`: enable OpenMP device offloading (default: OFF)
- `-DVASP_INTEL_MKL=ON|OFF`: enable Intel MKL offloading (default: OFF)
- `-DVASP_ROCM_HIP=ON|OFF`: enable ROCm/HIP support for offloading (default: OFF)

### Licensing

- `-DVASP_LICENSE=<key>`: VASP license key (default: empty)
- `-DVASP_REVOKED_KEYS_PATH=<path>`: path to revoked license keys file (default: empty)

### Misc

- `-DVASP_PP_EXTRA=<flags>`: extra preprocessor flags not covered by options above (default: empty)
- `-DVASP_HOST_NAME=<name>`: host system name (default: `CMAKE_SYSTEM_NAME`)
- `-DVASP_SOURCES_DEB=<files>`: files to compile with debug flags
