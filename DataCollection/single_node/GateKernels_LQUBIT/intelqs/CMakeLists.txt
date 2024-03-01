#############################
## I. Set project details
#############################
cmake_minimum_required(VERSION 3.14)

project("Lightning paper executables"
        VERSION 0.1.0
        DESCRIPTION "A sample IntelQS project"
        LANGUAGES CXX
)

# Ensure all performance-oriented flags are provided
add_compile_options(-mfma -mavx -mavx2 -mavx512f -O3)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libstdc++ -lstdc++")

set(IqsMKL ON)
set(IqsPython OFF)
set(IqsUtest OFF)
set(IqsNoise OFF)
set(BuildExamples OFF)
set(BuildInterface OFF)
set(IqsNative ON)
set(IqsBuildAsStatic ON)

#############################
## II. Fetch PLL project
#############################

Include(FetchContent)

FetchContent_Declare(
    iqs
    GIT_REPOSITORY  https://github.com/intel/intel-qs.git
    GIT_TAG         f8673cfee517b1c5c4f4a75e63c5a300259c6552
)
FetchContent_MakeAvailable(iqs)

#############################
## III. Create project target
#############################

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libstdc++ -lstdc++")

add_executable(IQSBin_CZ sim_CZ.cpp)
add_executable(IQSBin_CNOT sim_CNOT.cpp)
add_executable(IQSBin_H sim_Hadamard.cpp)
add_executable(IQSBin_IsingYY sim_IsingYY.cpp)
add_executable(IQSBin_RX sim_RX.cpp)

target_link_libraries(IQSBin_CZ iqs) 
target_link_libraries(IQSBin_CNOT iqs) 
target_link_libraries(IQSBin_H iqs) 
target_link_libraries(IQSBin_IsingYY iqs) 
target_link_libraries(IQSBin_RX iqs) 

set_property(TARGET IQSBin_CZ PROPERTY CXX_STANDARD 20)
set_property(TARGET IQSBin_CNOT PROPERTY CXX_STANDARD 20)
set_property(TARGET IQSBin_H PROPERTY CXX_STANDARD 20)
set_property(TARGET IQSBin_RX PROPERTY CXX_STANDARD 20)
set_property(TARGET IQSBin_IsingYY PROPERTY CXX_STANDARD 20)
