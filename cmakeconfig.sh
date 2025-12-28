cmake -S . -B build \
  -G "MinGW Makefiles" \
  -DPROTOBUF_ROOT=D:/Android/protobuf-android-install \
  -DCMAKE_INSTALL_PREFIX=./fdbus-install