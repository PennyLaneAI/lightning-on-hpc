#############################
## I. Set project details
#############################
cmake_minimum_required(VERSION 3.14)

project("Lightning paper executables"
        VERSION 0.1.0
        DESCRIPTION "A sample QuEST project"
        LANGUAGES CXX
)

# Ensure all performance-oriented flags are provided
add_compile_options(-mfma -mavx -mavx2 -mavx512f -O3)

#############################
## II. Fetch PLL project
#############################

Include(FetchContent)

FetchContent_Declare(
    QuEST
    GIT_REPOSITORY  https://github.com/QuEST-Kit/QuEST.git
    GIT_TAG         v3.7.0
)
FetchContent_MakeAvailable(QuEST)
include_directories(${QuEST_SOURCE_DIR}/include)


#############################
## III. Create project target
#############################

# Uncomment if building with clang/icx
#set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libstdc++ -lstdc++")

add_executable(QuESTBin_CZ sim_CZ.cpp)
add_executable(QuESTBin_CNOT sim_CNOT.cpp)
add_executable(QuESTBin_H sim_Hadamard.cpp)
add_executable(QuESTBin_IsingYY sim_IsingYY.cpp)
add_executable(QuESTBin_RX sim_RX.cpp)

target_link_libraries(QuESTBin_CZ QuEST) 
target_link_libraries(QuESTBin_CNOT QuEST) 
target_link_libraries(QuESTBin_H QuEST) 
target_link_libraries(QuESTBin_IsingYY QuEST) 
target_link_libraries(QuESTBin_RX QuEST) 

set_property(TARGET QuESTBin_CZ PROPERTY CXX_STANDARD 20)
set_property(TARGET QuESTBin_CNOT PROPERTY CXX_STANDARD 20)
set_property(TARGET QuESTBin_H PROPERTY CXX_STANDARD 20)
set_property(TARGET QuESTBin_RX PROPERTY CXX_STANDARD 20)
set_property(TARGET QuESTBin_IsingYY PROPERTY CXX_STANDARD 20)
