#include<chrono>
#include "../include/qureg.hpp"

int main(int argc, char **argv){
    constexpr std::size_t run_avg = 5;
    std::string arg_idx0 = argv[1];
    std::string arg_idx1 = argv[2];
    std::string arg_qubits = argv[3];
    std::size_t index_tgt = std::stoi( arg_idx0 );
    std::size_t index_ctrl = std::stoi( arg_idx1 );
    std::size_t num_qubits = std::stoi( arg_qubits );

    iqs::QubitRegister<ComplexDP> psi(num_qubits);
    psi.Initialize("base", 0);

    std::vector<double> times;
    times.reserve(run_avg);

    for(std::size_t i = 0; i < run_avg; i++){
        const auto t_start = std::chrono::high_resolution_clock::now();
        psi.ApplyCPauliZ(index_ctrl, index_tgt);
        const auto t_end = std::chrono::high_resolution_clock::now();
        const double t_us = std::chrono::duration<double, std::milli>(t_end-t_start).count();
        times.push_back(t_us);
    }
    auto t_sum = std::accumulate(times.begin(), times.end(), 0.0, std::plus<double>()) / run_avg;
    std::cout << index_tgt << "," << index_ctrl << "," << "CZ" << "," << t_sum << ",1e-3";
    return 0;
}