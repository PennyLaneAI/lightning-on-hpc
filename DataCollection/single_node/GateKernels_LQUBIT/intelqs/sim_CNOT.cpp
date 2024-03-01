#include "../include/qureg.hpp"
#include <chrono>

#include "../output_utils.hpp"

namespace {
using t_scale = std::milli;
using namespace BMUtils;
} // namespace

int main(int argc, char **argv) {
    constexpr std::size_t run_avg = 5;
    auto indices = prep_input_2q<unsigned int>(argc, argv);

    iqs::QubitRegister<ComplexDP> psi(indices.q);
    psi.Initialize("base", 0);

    std::vector<double> times;
    times.reserve(run_avg);

    for (std::size_t i = 0; i < run_avg; i++) {
        TIMING(psi.ApplyCPauliX(indices.c, indices.t));
    }
    auto t_sum = average_times(times);
    CSVOutput<decltype(indices), t_scale> csv(indices, "CNOT",
                                              average_times(times));
    std::cout << csv << std::endl;
    return 0;
}