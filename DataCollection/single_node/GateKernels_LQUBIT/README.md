This directory holds the CPP examples for comparing Lightning's kernels against other packages.
The following gates are tested: Hadamard, RX, CNOT, CZ, IsingXX

Each framework may require explicit dependencies (e.g. Qulacs requires Boost, IntelQS has oneAPI+icpx), but should be standalone compilable.
The `build_script.sh` file in each directory can be used to compile the examples, making use of the included `CMakeLists.txt` and `env_setup.sh` files.

The subproject root directory's `run.sh` sweeps the frameworks, the number of OpenMP threads, the gates, and the list of explored indices, where an average of 5 runs is taken for each index selection.

The included `data/GatePerformanceSR.ipynb` was used to generate the figures on the processed output data.
