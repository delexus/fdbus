# fdbus
fdbus for ndk

## Build with CMake

This repository now provides a top-level `CMakeLists.txt`. A simple native build can be generated with:

```bash
cmake -S . -B build
cmake --build build
```

An Android NDK configure preset mirroring the provided configuration is available:

```bash
cmake --preset android-arm64
cmake --build build/android-arm64
```

The preset sets `CMAKE_TOOLCHAIN_FILE`, compilers, and ABI to match the example NDK layout under `D:/Android/Sdk/`.
