#include <algorithm>
#include <chrono>
#include <complex>
#include <iostream>
#include <numeric>
#include <vector>

#include "StateVectorCudaManaged.hpp"

#include "../output_utils.hpp"

namespace {
using namespace Pennylane;
using namespace Pennylane::LightningGPU;

using t_scale = std::milli;
using namespace BMUtils;
} // namespace

int main(int argc, char *argv[]) {
    auto indices = prep_input_2q<unsigned int>(argc, argv);
    constexpr std::size_t run_avg = 5;
    const std::vector<double> angle = {0.1234};

    // Create PennyLane Lightning statevector
    StateVectorCudaManaged<double> sv(indices.q);

    // Create vector for run-times to average
    std::vector<double> times;
    times.reserve(run_avg);
    std::vector<std::size_t> qubits{indices.c, indices.t};
    std::string gate = "IsingYY";

    // Apply the gates `run_avg` times on the indicated qubits
    for (std::size_t i = 0; i < run_avg; i++) {
        TIMING(sv.applyOperation(kernel, gate, qubits, false, angle));
    }

    CSVOutput<decltype(indices), t_scale> csv(indices, gate,
                                              average_times(times));
    std::cout << csv << std::endl;
    return 0;
}
