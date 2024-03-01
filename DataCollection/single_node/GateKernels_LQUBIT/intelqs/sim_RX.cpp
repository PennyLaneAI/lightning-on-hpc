#include "../include/qureg.hpp"
#include <chrono>

#include "../output_utils.hpp"

namespace {
using t_scale = std::milli;
using namespace BMUtils;
} // namespace

int main(int argc, char **argv) {
    constexpr std::size_t run_avg = 5;
    auto indices = prep_input_1q<unsigned int>(argc, argv);
    constexpr double angle = 0.1234;

    iqs::QubitRegister<ComplexDP> psi(indices.q);
    psi.Initialize("base", 0);

    std::vector<double> times;
    times.reserve(run_avg);

    for (std::size_t i = 0; i < run_avg; i++) {
        TIMING(psi.ApplyRotationX(indices.t, angle));
    }
    auto t_sum = average_times(times);
    CSVOutput<decltype(indices), t_scale> csv(indices, "RX",
                                              average_times(times));
    std::cout << csv << std::endl;
    return 0;
}