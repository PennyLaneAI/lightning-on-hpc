#!/bin/bash

. /opt/intel/oneapi/setvars.sh
function run_2q_lightning {
    for gate in CNOT;do
        for kernel in AVX512; do
            for qubits in 30; do
                for q0 in `seq 0 1 $((${qubits}-1))`;do
                    for q1 in `seq 0 1 $((${qubits}-1))`;do
                        if [[ "$q0" == "$q1" ]]; then
                            continue
                        fi

                        for omp in 1 4 16 32;do
                            export OMP_NUM_THREADS=$omp
                            echo "name=LightningOMPBinStream,gate=${gate},omp=${omp},$(./LightningOMPBin_${gate} ${q0} ${q1} ${qubits} ${kernel}),kernel=${kernel}" | tee -a output_${gate}_lqomp.csv
                        done
                    done
                done
            done
        done
    done
}

function run_1q_lightning {
    for gate in H RX;do
        for kernel in AVX512; do
            for qubits in 30; do
                for q0 in `seq 0 1 $((${qubits}-1))`;do
                    for omp in 1 4 16 32;do
                        export OMP_NUM_THREADS=$omp
                        echo "sim=LightningOMPBinStream,gate=${gate},omp=${omp},$(./LightningOMPBin_${gate} ${q0} ${qubits} ${kernel}),${kernel}" | tee -a output_${gate}_lqomp.csv
                    done
                done
            done
        done
    done
}

run_1q_lightning
run_2q_lightning
