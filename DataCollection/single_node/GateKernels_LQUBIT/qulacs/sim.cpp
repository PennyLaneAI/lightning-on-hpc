#include<algorithm>
#include<chrono>
#include<complex>
#include<execution>
#include<iostream>
#include<numeric>
#include<vector>

#include "cppsim/gate_factory.hpp"
#include "cppsim/state.hpp"

int main(int argc, char* argv[]){
    constexpr std::size_t run_avg = 5;
    std::string arg_idx0 = argv[1];
    std::string arg_idx1 = argv[2];
    std::string arg_qubits = argv[3];
    std::size_t index_tgt = std::stoi( arg_idx0 );
    std::size_t index_ctrl = std::stoi( arg_idx1 );
    unsigned int n = std::stoi( arg_qubits );

    QuantumState state(n);
    state.set_zero_state();

    std::vector<double> times;
    times.reserve(run_avg);

    auto x_gate = gate::CZ(index_ctrl, index_tgt);
    for(std::size_t i = 0; i < run_avg; i++){
        const auto t_start = std::chrono::high_resolution_clock::now();
        x_gate->update_quantum_state(&state);
        const auto t_end = std::chrono::high_resolution_clock::now();
        const double t_us = std::chrono::duration<double, std::milli>(t_end-t_start).count();
        times.push_back(t_us);
    }
    auto t_sum = std::accumulate(times.begin(), times.end(), 0.0, std::plus<double>()) / run_avg;
    std::cout << index_tgt << "," << index_ctrl << "," << "CZ" << "," << t_sum << ",1e-3";
    return 0;
}