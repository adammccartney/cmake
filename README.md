* Clone the repository into the root directory of your VASP distro:
  ```
  cd /your/vasp/directory
  git clone ssh://git@gitlab.vasp.co:8022/vasp-dev/cmake.git cmake
  ```

* Run the setup script:
  ```
  . cmake/setup.sh
  ```

* Create a build directory and run cmake:
  ```
  mkdir your-build-dir
  cd your-build-dir
  cmake ..
  ```

* And build VASP (in the ``your-build-dir`` directory):
  ```
  make -j all
  ```
