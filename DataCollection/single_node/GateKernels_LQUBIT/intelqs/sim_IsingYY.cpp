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
    constexpr double angle = 0.1234;

    iqs::QubitRegister<ComplexDP> psi(indices.q);
    psi.Initialize("base", 0);

    std::vector<double> times;
    times.reserve(run_avg);

    iqs::TinyMatrix<std::complex<double>, 4, 4, 32> gate;
    gate[0][0] = {0.99809716, 0};
    gate[1][1] = {0.99809716, 0};
    gate[2][2] = {0.99809716, 0};
    gate[3][3] = {0.99809716, 0};
    gate[3][0] = {0, 0.06166086};
    gate[2][1] = {0, 0.06166086};
    gate[1][2] = {0, 0.06166086};
    gate[0][3] = {0, 0.06166086};

    for (std::size_t i = 0; i < run_avg; i++) {
        TIMING(psi.Apply2QubitGate(indices.c, indices.t, gate));
    }
    auto t_sum = average_times(times);
    CSVOutput<decltype(indices), t_scale> csv(indices, "RX",
                                              average_times(times));
    std::cout << csv << std::endl;
    return 0;
}