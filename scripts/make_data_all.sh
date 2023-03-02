#!/bin/bash

set -x -e # stop if fail

ICUROOT="$(dirname "$0")/.."

function config_data {
  if [ $# -lt 1 ];
  then
    echo "config target missing." >&2
    echo "Should be (android|cast|chromeos|common|flutter|ios)" >&2
    exit 1
  fi

  ICU_DATA_FILTER_FILE="${ICUROOT}/filters/$1.json" \
  "${ICUROOT}/source/runConfigureICU" --enable-debug --disable-release \
    Linux/gcc --disable-tests  --disable-layoutex --enable-rpath \
    --prefix="$(pwd)" || \
    { echo "failed to configure data for $1" >&2; exit 1; }
}

echo "Build the necessary tools"
"${ICUROOT}/source/runConfigureICU" --enable-debug --disable-release \
    Linux/gcc  --disable-tests --disable-layoutex --enable-rpath \
    --prefix="$(pwd)"
make -j 120

echo "Build the filtered data for Flutter"
(cd data && make clean)
config_data flutter
#$ICUROOT/flutter/patch_brkitr.sh && 
make -j 120
rm ../stubdata/libicudata.so
rm ../stubdata/libicudata.so.72
rm ../stubdata/libicudata.so.72.1
$ICUROOT/scripts/copy_data.sh flutter

echo "Clean up the git"
$ICUROOT/scripts/clean_up_data_source.sh
