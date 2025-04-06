# Groot
Groot: Graph-Centric Row Reordering with Tree for Sparse Matrix Multiplication on Tensor Cores

## Prerequisites
- CMake 3.28
- CUDA Toolkit 12.3
- KGraph (https://github.com/aaalgo/kgraph) 
- Boost 1.83 (required by KGraph)

It is advisable to use vcpkg for managing C++ libraries, such as Boost. However, KGraph requires manual installation.


## Build using CMake
Note: You may need to modify the CMakeLists.txt file to match your GPU architecture and library paths.

```
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
cd ..
```

## Data format
The supported format is `mtx` and binary `csr`. 

`csr` is encoded as `nrow nnz row_ptr[] col_idx[]` in binary.

## Running the example

```bash
./build/apps/groot -i ./toydata/cora.csr -o ./toydata/cora_groot.csr
```