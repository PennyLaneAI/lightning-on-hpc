#include <algorithm>
#include <chrono>
#include <complex>
#include <execution>
#include <iostream>
#include <numeric>
#include <vector>

#include "cppsim/gate_factory.hpp"
#include "cppsim/state.hpp"

#include "../output_utils.hpp"

namespace {
using t_scale = std::milli;
using namespace BMUtils;
} // namespace

int main(int argc, char *argv[]) {
    constexpr std::size_t run_avg = 5;
    auto indices = prep_input_2q<unsigned int>(argc, argv);

    QuantumState state(indices.q);
    state.set_zero_state();

    std::vector<double> times;
    times.reserve(run_avg);

    auto q_gate = gate::CZ(indices.c, indices.t);
    for (std::size_t i = 0; i < run_avg; i++) {
        TIMING(q_gate->update_quantum_state(&state));
    }
    auto t_sum = average_times(times);
    CSVOutput<decltype(indices), t_scale> csv(indices, "CZ",
                                              average_times(times));
    std::cout << csv << std::endl;
    return 0;
}