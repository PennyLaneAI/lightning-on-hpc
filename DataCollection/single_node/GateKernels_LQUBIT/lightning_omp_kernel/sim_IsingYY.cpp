#include <algorithm>
#include <chrono>
#include <complex>
#include <iostream>
#include <numeric>
#include <vector>

#include "KernelType.hpp"
#include "StateVectorLQubitManaged.hpp"

#include "../output_utils.hpp"

namespace {
using namespace Pennylane;
using namespace Pennylane::LightningQubit;
using namespace Pennylane::Gates;

using t_scale = std::milli;
using namespace BMUtils;

static const std::unordered_map<std::string, KernelType> kernel_map{
    {"LM", KernelType::LM},
    {"AVX2", KernelType::AVX2},
    {"AVX512", KernelType::AVX512}};
} // namespace

int main(int argc, char *argv[]) {
    auto indices = prep_input_2q<unsigned int>(argc, argv);
    constexpr std::size_t run_avg = 5;
    const std::vector<double> angle = {0.1234};

    // Read in kernel to use (LM, AVX2, AVX512)
    std::string arg_kernel;
    if (argc >= 5) {
        arg_kernel = argv[4];
    } else {
        arg_kernel = "LM";
    }

    // Create PennyLane Lightning statevector
    StateVectorLQubitManaged<double> sv(indices.q);

    // Create vector for run-times to average
    std::vector<double> times;
    times.reserve(run_avg);
    const auto kernel = kernel_map.at(arg_kernel);
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
