#!/bin/bash

. /opt/intel/oneapi/setvars.sh
function run_2q_ext {
    for gate in CNOT CZ IsingYY;do
        for bin in IQSBin QuESTBin QulacsBin; do
            for qubits in 10 20 30; do
                for q0 in `seq 0 1 $((${qubits}-1))`;do
                    for q1 in `seq 0 1 $((${qubits}-1))`;do
                        if [[ "$q0" == "$q1" ]]; then
                            continue
                        fi

                        for omp in 1 4 16 32;do
                            export OMP_NUM_THREADS=$omp
                            echo "sim=${bin},gate=${gate},omp=${omp},$(./${bin}_${gate} ${q0} ${q1} ${qubits}),kernel=None" | tee -a output_${gate}.csv
                        done
                    done
                done
            done
        done
    done
}
function run_1q_ext {
    for gate in H RX;do
        for bin in IQSBin QuESTBin QulacsBin; do
            for qubits in 10 20 30; do
                for q0 in `seq 0 1 $((${qubits}-1))`;do
                    for omp in 1 4 16 32;do
                        export OMP_NUM_THREADS=$omp
                        echo "sim=${bin},gate=${gate},omp=${omp},$(./${bin}_${gate} ${q0} ${qubits}),kernel=None" | tee -a output_${gate}.csv
                    done
                done
            done
        done
    done
}

function run_2q_lightning {
    for gate in CNOT CZ IsingYY;do
        for kernel in LM AVX2 AVX512; do
            for qubits in 10 20 30; do
                for q0 in `seq 0 1 $((${qubits}-1))`;do
                    for q1 in `seq 0 1 $((${qubits}-1))`;do
                        if [[ "$q0" == "$q1" ]]; then
                            continue
                        fi

                        for omp in 1 4 16 32;do
                            export OMP_NUM_THREADS=$omp
                            echo "name=LightningOMPBin,gate=${gate},omp=${omp},$(./LightningOMPBin_${gate} ${q0} ${q1} ${qubits} ${kernel}),kernel=${kernel}" | tee -a output_${gate}_lqomp.csv
                        done
                    done
                done
            done
        done
    done
}

function run_1q_lightning {
    for gate in H RX;do
        for kernel in LM AVX2 AVX512; do
            for qubits in 10 20 30; do
                for q0 in `seq 0 1 $((${qubits}-1))`;do
                    for omp in 1 4 16 32;do
                        export OMP_NUM_THREADS=$omp
                        echo "sim=LightningOMPBin,gate=${gate},omp=${omp},$(./LightningOMPBin_${gate} ${q0} ${qubits} ${kernel}),${kernel}" | tee -a output_${gate}_lqomp.csv
                    done
                done
            done
        done
    done
}

run_1q_ext
run_2q_ext

run_1q_lightning
run_2q_lightning
