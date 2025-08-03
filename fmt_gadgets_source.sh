#!/bin/bash

set -e

find gadgets \
  \( -name '*.cpp' -o -name '*.hpp' \) \
  -exec clang-format-mp-18 -i --style=Google {} +

echo "Clang-format completed on all source files."

