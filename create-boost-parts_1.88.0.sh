#!/bin/bash

set -euo pipefail

# Versione di Boost da usare
BOOST_VERSION=1.88.0
BOOST_DIRNAME=boost_1_88_0
BOOST_TARBALL=${BOOST_DIRNAME}.tar.gz

# URL ufficiale
BOOST_URL="https://archives.boost.io/release/1.88.0/source/${BOOST_TARBALL}"

SPLIT_PREFIX="${BOOST_TARBALL}.part_"

# Download Boost tarball if not already present
if [ ! -f "${BOOST_TARBALL}" ]; then
  echo "Downloading Boost ${BOOST_VERSION}..."
  curl -L -o "${BOOST_TARBALL}" "${BOOST_URL}"
else
  echo "Boost tarball already exists: ${BOOST_TARBALL}"
fi

# Determine tarball size using system-specific stat command
if stat --format=%s "${BOOST_TARBALL}" &>/dev/null; then
  FILESIZE=$(stat --format=%s "${BOOST_TARBALL}")
elif stat -f%z "${BOOST_TARBALL}" &>/dev/null; then
  FILESIZE=$(stat -f%z "${BOOST_TARBALL}")
else
  echo "Error: Unable to determine file size of ${BOOST_TARBALL}" >&2
  exit 1
fi

echo "Tarball size: ${FILESIZE} bytes"

# Number of parts
NPARTS=8
PARTSIZE=$(( (FILESIZE + NPARTS - 1) / NPARTS ))

echo "Splitting tarball into ${NPARTS} parts of approximately ${PARTSIZE} bytes each..."
split -b "${PARTSIZE}" "${BOOST_TARBALL}" "${SPLIT_PREFIX}"

echo "Split completed. Verifying integrity..."

# Reassemble and verify checksum
cat ${SPLIT_PREFIX}* > rejoined.tar.gz
ORIGINAL_HASH=$(sha256sum "${BOOST_TARBALL}" | awk '{print $1}')
REJOINED_HASH=$(sha256sum rejoined.tar.gz | awk '{print $1}')

if [ "${ORIGINAL_HASH}" = "${REJOINED_HASH}" ]; then
  echo "Split verification successful: checksums match."
  echo "Cleaning up temporary verification file..."
  rm -f rejoined.tar.gz
  echo "Cleaning up boost tarball..."
  rm -f "${BOOST_TARBALL}"
  echo "Cleanup completed."
else
  echo "Split verification failed: checksums do not match." >&2
  echo "Keeping split files and verification tarball for inspection." >&2
  exit 1
fi
