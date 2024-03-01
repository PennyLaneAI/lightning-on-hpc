#############################
## I. Set project details
#############################
cmake_minimum_required(VERSION 3.14)

project("Lightning paper executable"
        VERSION 0.1.0
        DESCRIPTION "A sample PennyLane Lightning project"
        LANGUAGES CXX
)

set(ENABLE_PYTHON off)

#############################
## II. Fetch PLL project
#############################

Include(FetchContent)

FetchContent_Declare(
    pennylane_lightning
    GIT_REPOSITORY  https://github.com/PennyLaneAI/pennylane-lightning.git
    GIT_TAG         kernel_omp
)
FetchContent_MakeAvailable(pennylane_lightning)

#############################
## III. Create project target
#############################

add_executable(LightningOMPBin_CNOT sim_CNOT.cpp)
add_executable(LightningOMPBin_CZ sim_CZ.cpp)
add_executable(LightningOMPBin_RX sim_RX.cpp)
add_executable(LightningOMPBin_H sim_Hadamard.cpp)
add_executable(LightningOMPBin_IsingYY sim_IsingYY.cpp)

target_link_libraries(LightningOMPBin_CNOT pennylane_lightning)
target_link_libraries(LightningOMPBin_CZ pennylane_lightning)
target_link_libraries(LightningOMPBin_RX pennylane_lightning)
target_link_libraries(LightningOMPBin_H pennylane_lightning)
target_link_libraries(LightningOMPBin_IsingYY pennylane_lightning)

set_property(TARGET LightningOMPBin_CNOT PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningOMPBin_CZ PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningOMPBin_RX PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningOMPBin_H PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningOMPBin_IsingYY PROPERTY CXX_STANDARD 20)
