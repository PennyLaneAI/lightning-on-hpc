#include <algorithm>
#include <iostream>
#include <chrono>
#include <numeric>
#include <string>
#include <vector>
#include "QuEST.h"

namespace{
    using t_scale = std::milli;
}

int main (int argc, char** argv) {
    if(argc != 5){
        std::cout << "Please ensure you specify the following arguments: ctrl tgt qubits gate" << std::endl;
        return 1;
    }

    // Average over 5 runs
    constexpr std::size_t run_avg = 5;

    // Read in ctrl, target indices
    std::string arg_idx0 = argv[1];
    std::string arg_idx1 = argv[2];
    // Read in number of qubits in register
    std::string arg_qubits = argv[3];
    // Read in 2-qubit gate to compare
    std::string arg_gate = argv[4];

    // Convert inputs to size_t
    std::size_t index_tgt = std::stoi( arg_idx0 );
    std::size_t index_ctrl = std::stoi( arg_idx1 );
    int n = std::stoi( arg_qubits );   

    // Create statevector
    QuESTEnv env = createQuESTEnv();
    Qureg qubits = createQureg(n, env);
    initZeroState(qubits);

    // Create vector for run-times to average
    std::vector<double> times;
    times.reserve(run_avg);

    // Apply the gates `run_avg` times on the indicated qubits
    for(std::size_t i = 0; i < run_avg; i++){
        const auto t_start = std::chrono::high_resolution_clock::now();
        controlledPhaseFlip(qubits, index_ctrl, index_tgt); //CZ gate
        const auto t_end = std::chrono::high_resolution_clock::now();
        const double t_duration = std::chrono::duration<double, t_scale>(t_end-t_start).count();
        times.push_back(t_duration);
    }
    auto t_sum = std::accumulate(times.begin(), times.end(), 0.0, std::plus<double>()) / run_avg;
    std::cout << index_tgt << "," << index_ctrl << "," << "CZ" << "," << t_sum << "," << t_scale::num << "/" << t_scale::den << std::endl;

    destroyQureg(qubits, env); 
    destroyQuESTEnv(env);
    return 0;
}
