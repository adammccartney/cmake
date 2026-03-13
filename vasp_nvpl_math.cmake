# Optional NVPL BLAS/LAPACK (aarch64)
#
# Implements VASP_USE_NVPL={AUTO|ON|OFF} selection for NVPL BLAS/LAPACK.
#
# On success, this module:
# - Creates BLAS::BLAS and LAPACK::LAPACK INTERFACE IMPORTED targets
# - Appends them to VASP_EXTERNAL_LIBS
# - Appends their library directories to VASP_EXTERNAL_LIB_DIRS
# - Sets the output variable passed to vasp_try_enable_nvpl_math() to TRUE

function(vasp_try_enable_nvpl_math out_enabled)
  set(${out_enabled} FALSE PARENT_SCOPE)

  if(NOT DEFINED VASP_USE_NVPL)
    return()
  endif()

  set(_mode "${VASP_USE_NVPL}")
  string(TOUPPER "${_mode}" _mode)
  if(NOT _mode STREQUAL "AUTO" AND NOT _mode STREQUAL "ON" AND NOT _mode STREQUAL "OFF")
    message(FATAL_ERROR "VASP_USE_NVPL must be one of AUTO, ON, OFF (got: '${VASP_USE_NVPL}')")
  endif()

  set(_is_aarch64 FALSE)
  if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
    set(_is_aarch64 TRUE)
  endif()

  if(_mode STREQUAL "OFF")
    return()
  endif()

  if(_mode STREQUAL "ON" AND NOT _is_aarch64)
    message(FATAL_ERROR "VASP_USE_NVPL=ON requested, but target architecture is not aarch64/arm64 (CMAKE_SYSTEM_PROCESSOR='${CMAKE_SYSTEM_PROCESSOR}').")
  endif()

  set(_try_nvpl FALSE)
  if(_mode STREQUAL "ON")
    set(_try_nvpl TRUE)
  elseif(_mode STREQUAL "AUTO" AND _is_aarch64)
    set(_try_nvpl TRUE)
  endif()
  if(NOT _try_nvpl)
    return()
  endif()

  set(_nvpl_hints)
  if(DEFINED ENV{NVPL_ROOT} AND NOT "$ENV{NVPL_ROOT}" STREQUAL "")
    list(APPEND _nvpl_hints "$ENV{NVPL_ROOT}")
  endif()
  foreach(_var NVHPC NVHPC_ROOT)
    if(DEFINED ENV{${_var}} AND NOT "$ENV{${_var}}" STREQUAL "")
      list(APPEND _nvpl_hints "$ENV{${_var}}/math_libs/nvpl")
    endif()
  endforeach()
  if(EXISTS "/opt/nvidia/hpc_sdk")
    file(GLOB _nvpl_glob LIST_DIRECTORIES true "/opt/nvidia/hpc_sdk/Linux_*/*/math_libs/nvpl")
    list(APPEND _nvpl_hints ${_nvpl_glob})
  endif()
  list(REMOVE_DUPLICATES _nvpl_hints)

  if(VASP_OPENMP)
    set(_omp_suffix "gomp")
  else()
    set(_omp_suffix "seq")
  endif()

  find_library(_nvpl_blas
    NAMES "nvpl_blas_lp64_${_omp_suffix}"
    HINTS ${_nvpl_hints}
    PATH_SUFFIXES "lib" "lib64"
  )
  find_library(_nvpl_lapack
    NAMES "nvpl_lapack_lp64_${_omp_suffix}"
    HINTS ${_nvpl_hints}
    PATH_SUFFIXES "lib" "lib64"
  )
  find_library(_nvpl_blas_core
    NAMES nvpl_blas_core
    HINTS ${_nvpl_hints}
    PATH_SUFFIXES "lib" "lib64"
  )
  find_library(_nvpl_lapack_core
    NAMES nvpl_lapack_core
    HINTS ${_nvpl_hints}
    PATH_SUFFIXES "lib" "lib64"
  )

  if(NOT _nvpl_blas OR NOT _nvpl_lapack)
    if(_mode STREQUAL "ON")
      message(FATAL_ERROR "VASP_USE_NVPL=ON but NVPL BLAS/LAPACK not found. Set NVPL_ROOT or disable NVPL (VASP_USE_NVPL=OFF).")
    else()
      message(STATUS "VASP_USE_NVPL=AUTO but NVPL BLAS/LAPACK not found; falling back to default BLAS/LAPACK")
    endif()
    return()
  endif()

  message(STATUS "Using NVIDIA NVPL BLAS/LAPACK: disable with -DVASP_USE_NVPL=OFF if undesired)")

  if(NOT TARGET BLAS::BLAS)
    add_library(BLAS::BLAS INTERFACE IMPORTED)
  endif()
  if(_nvpl_blas_core)
    set_property(TARGET BLAS::BLAS PROPERTY INTERFACE_LINK_LIBRARIES "${_nvpl_blas};${_nvpl_blas_core}")
  else()
    set_property(TARGET BLAS::BLAS PROPERTY INTERFACE_LINK_LIBRARIES "${_nvpl_blas}")
  endif()

  if(NOT TARGET LAPACK::LAPACK)
    add_library(LAPACK::LAPACK INTERFACE IMPORTED)
  endif()
  if(_nvpl_lapack_core)
    set_property(TARGET LAPACK::LAPACK PROPERTY INTERFACE_LINK_LIBRARIES "${_nvpl_lapack};${_nvpl_lapack_core};BLAS::BLAS")
  else()
    set_property(TARGET LAPACK::LAPACK PROPERTY INTERFACE_LINK_LIBRARIES "${_nvpl_lapack};BLAS::BLAS")
  endif()

  # Append to VASP link lists (parent scope variables)
  set(_ext_libs "${VASP_EXTERNAL_LIBS}")
  list(APPEND _ext_libs BLAS::BLAS LAPACK::LAPACK)
  set(VASP_EXTERNAL_LIBS "${_ext_libs}" PARENT_SCOPE)

  set(_ext_dirs "${VASP_EXTERNAL_LIB_DIRS}")
  foreach(_lib IN ITEMS "${_nvpl_blas}" "${_nvpl_lapack}" "${_nvpl_blas_core}" "${_nvpl_lapack_core}")
    if(_lib)
      get_filename_component(_dir "${_lib}" DIRECTORY)
      list(APPEND _ext_dirs "${_dir}")
    endif()
  endforeach()
  set(VASP_EXTERNAL_LIB_DIRS "${_ext_dirs}" PARENT_SCOPE)

  set(${out_enabled} TRUE PARENT_SCOPE)
endfunction()
