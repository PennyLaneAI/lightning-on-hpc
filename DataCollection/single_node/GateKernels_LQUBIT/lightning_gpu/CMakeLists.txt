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
set(PL_BACKEND "lightning_gpu")

#############################
## II. Fetch PLL project
#############################

Include(FetchContent)

FetchContent_Declare(
    pennylane_lightning
    GIT_REPOSITORY  https://github.com/PennyLaneAI/pennylane-lightning.git
    GIT_TAG         master
)
FetchContent_MakeAvailable(pennylane_lightning)

#############################
## III. Create project target
#############################

add_executable(LightningGPUBin_CNOT sim_CNOT.cpp)
add_executable(LightningGPUBin_CZ sim_CZ.cpp)
add_executable(LightningGPUBin_RX sim_RX.cpp)
add_executable(LightningGPUBin_H sim_Hadamard.cpp)
add_executable(LightningGPUBin_IsingYY sim_IsingYY.cpp)

target_link_libraries(LightningGPUBin_CNOT pennylane_lightning)
target_link_libraries(LightningGPUBin_CZ pennylane_lightning)
target_link_libraries(LightningGPUBin_RX pennylane_lightning)
target_link_libraries(LightningGPUBin_H pennylane_lightning)
target_link_libraries(LightningGPUBin_IsingYY pennylane_lightning)

set_property(TARGET LightningGPUBin_CNOT PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningGPUBin_CZ PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningGPUBin_RX PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningGPUBin_H PROPERTY CXX_STANDARD 20)
set_property(TARGET LightningGPUBin_IsingYY PROPERTY CXX_STANDARD 20)
