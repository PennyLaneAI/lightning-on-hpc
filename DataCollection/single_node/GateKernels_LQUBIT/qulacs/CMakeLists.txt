#############################
## I. Set project details
#############################
cmake_minimum_required(VERSION 3.14)

project("Lightning paper executables"
        VERSION 0.1.0
        DESCRIPTION "A sample Qulacs project"
        LANGUAGES CXX
)

# Ensure all performance-oriented flags are provided
add_compile_options(-mfma -mavx -mavx2 -mavx512f -O3)

set(USE_OMP 1)
set(USE_MPI 0)
set(USE_GPU 0)
set(USE_PYTHON 0)
set(USE_TEST 0)
set(COVERAGE 0)
set(USE_SIMD 1)

#############################
## II. Fetch PLL project
#############################

Include(FetchContent)

FetchContent_Declare(
    qulacs
    GIT_REPOSITORY  https://github.com/qulacs/qulacs.git
    GIT_TAG         v0.6.2
)
FetchContent_MakeAvailable(qulacs)

include_directories(${qulacs_SOURCE_DIR}/include)
find_package(Boost REQUIRED)
find_package(OpenMP REQUIRED)

include_directories(${Boost_INCLUDE_DIRS})

#############################
## III. Create project target
#############################

add_executable(QulacsBin_CZ sim_CZ.cpp)
add_executable(QulacsBin_CNOT sim_CNOT.cpp)
add_executable(QulacsBin_H sim_Hadamard.cpp)
add_executable(QulacsBin_RX sim_RX.cpp)
add_executable(QulacsBin_IsingYY sim_IsingYY.cpp)

target_link_libraries(QulacsBin_CZ cppsim_static vqcsim_static OpenMP::OpenMP_CXX) 
target_link_libraries(QulacsBin_CNOT cppsim_static vqcsim_static OpenMP::OpenMP_CXX) 
target_link_libraries(QulacsBin_H cppsim_static vqcsim_static OpenMP::OpenMP_CXX) 
target_link_libraries(QulacsBin_RX cppsim_static vqcsim_static OpenMP::OpenMP_CXX) 
target_link_libraries(QulacsBin_IsingYY cppsim_static vqcsim_static OpenMP::OpenMP_CXX) 

set_property(TARGET QulacsBin_CZ PROPERTY CXX_STANDARD 20)
set_property(TARGET QulacsBin_CNOT PROPERTY CXX_STANDARD 20)
set_property(TARGET QulacsBin_H PROPERTY CXX_STANDARD 20)
set_property(TARGET QulacsBin_RX PROPERTY CXX_STANDARD 20)
set_property(TARGET QulacsBin_IsingYY PROPERTY CXX_STANDARD 20)
