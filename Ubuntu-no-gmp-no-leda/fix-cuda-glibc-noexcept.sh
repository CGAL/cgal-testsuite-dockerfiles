#!/bin/sh
# Make CUDA 12.x math headers compatible with glibc >= 2.41.
#
# glibc 2.41 added sinpi/cospi/sinpif/cospif and glibc 2.42 added rsqrt/rsqrtf
# (C23) to <math.h>, declared noexcept(true) in C++. CUDA's crt/math_functions.h
# declares the same functions without an exception specification, so nvcc fails:
#   error: exception specification is incompatible with that of previous function "cospi"
#
# This script appends noexcept(true) to those declarations (math_functions.h)
# and to their host definitions (math_functions.hpp). It is idempotent.
#
# Usage: fix-cuda-glibc-noexcept.sh [CUDA_ROOT]   (default: /usr/local/cuda)
set -eu

CUDA_ROOT="${1:-/usr/local/cuda}"
CRT="$(readlink -f "$CUDA_ROOT")/targets/x86_64-linux/include/crt"
H="$CRT/math_functions.h"
HPP="$CRT/math_functions.hpp"
FUNCS='sinpi|sinpif|cospi|cospif|rsqrt|rsqrtf'

for f in "$H" "$HPP"; do
  [ -f "$f" ] || { echo "error: $f not found" >&2; exit 1; }
  [ -f "$f.orig" ] || cp "$f" "$f.orig"
done

# Declarations, e.g.
#   extern __DEVICE_FUNCTIONS_DECL__ __device_builtin__ double   cospi(double x);
perl -0pi -e '
  s/(extern\s+__DEVICE_FUNCTIONS_DECL__\s+__device_builtin__\s+(?:double|float)\s+(?:'"$FUNCS"')\s*\([^()]*\))\s*;/$1 noexcept(true);/g
' "$H"

# Host definitions, e.g.
#   __func__(double sinpi(double a))   ->   __func__(double sinpi(double a)) noexcept(true)
perl -0pi -e '
  s/(__func__\(\s*(?:double|float)\s+(?:'"$FUNCS"')\s*\([^()]*\)\s*\))(?!\s*noexcept)/$1 noexcept(true)/g
' "$HPP"

echo "Patched declarations in $H:"
grep -nE "($FUNCS)\s*\([^()]*\)\s*noexcept" "$H" || true
echo "Patched definitions in $HPP:"
grep -nE "($FUNCS)\s*\([^()]*\)\)\s*noexcept" "$HPP" || true

# sinpi/cospi must have been found, otherwise the header layout changed.
for fn in sinpi cospi sinpif cospif; do
  grep -qE "\b$fn\s*\([^()]*\)\s*noexcept" "$H" || {
    echo "error: declaration of $fn not patched in $H" >&2; exit 1; }
done
