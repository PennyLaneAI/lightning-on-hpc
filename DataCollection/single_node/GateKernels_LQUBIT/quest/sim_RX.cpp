#include <algorithm>
#include <chrono>
#include <iostream>
#include <numeric>
#include <string>
#include <vector>

#include "QuEST.h"

#include "../output_utils.hpp"

namespace {
using t_scale = std::milli;
using namespace BMUtils;
} // namespace

int main(int argc, char **argv) {
    constexpr std::size_t run_avg = 5;
    auto indices = prep_input_1q<unsigned int>(argc, argv);
    constexpr double angle = 0.1234;

    // Create statevector
    QuESTEnv env = createQuESTEnv();
    Qureg qubits = createQureg(indices.q, env);
    initZeroState(qubits);

    // Create vector for run-times to average
    std::vector<double> times;
    times.reserve(run_avg);

    // Apply the gates `run_avg` times on the indicated qubits
    for (std::size_t i = 0; i < run_avg; i++) {
        TIMING(rotateX(qubits, indices.t, angle));
    }
    auto t_sum = average_times(times);
    CSVOutput<decltype(indices), t_scale> csv(indices, "RX",
                                              average_times(times));
    std::cout << csv << std::endl;

    destroyQureg(qubits, env);
    destroyQuESTEnv(env);
    return 0;
}
