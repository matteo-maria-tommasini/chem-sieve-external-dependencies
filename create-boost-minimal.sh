#!/bin/bash

# Versione di Boost da usare
BOOST_VERSION=1.88.0
BOOST_DIRNAME=boost_1_88_0
BOOST_TARBALL=${BOOST_DIRNAME}.tar.gz

# URL ufficiale
BOOST_URL="https://archives.boost.io/release/1.88.0/source/${BOOST_TARBALL}"

# Directory temporanea
WORKDIR=boost-minimal
OUT_TARBALL=boost_minimal_$BOOST_VERSION.tar.gz

# Percorsi Boost da conservare
BOOST_SUBDIRS=(
    boost/concept
    boost/functional
    boost/graph
    boost/pending
    boost/property_map
    boost/tuple
)

BOOST_ROOT_FILES=(
    boost/concept_check.hpp
    boost/throw_exception.hpp
)

# 1. Scarica se non presente
if [ ! -f "${BOOST_TARBALL}" ]; then
    echo "Scarico ${BOOST_TARBALL}..."
    curl -LO "${BOOST_URL}"
fi

# 2. Pulisce
rm -rf "${WORKDIR}" "${OUT_TARBALL}"
mkdir -p "${WORKDIR}"

# 3. Estrai solo i file richiesti
echo "Estrazione selettiva da ${BOOST_TARBALL}..."

for dir in "${BOOST_SUBDIRS[@]}"; do
    tar --strip-components=1 -xzf "${BOOST_TARBALL}" -C "${WORKDIR}" "${BOOST_DIRNAME}/${dir}"
done

for file in "${BOOST_ROOT_FILES[@]}"; do
    tar --strip-components=1 -xzf "${BOOST_TARBALL}" -C "${WORKDIR}" "${BOOST_DIRNAME}/${file}"
done

# 4. Crea il nuovo tarball minimale
echo "Creazione tarball ${OUT_TARBALL}..."
tar -czf "${OUT_TARBALL}" -C "${WORKDIR}" boost

# 5. Cleanup
rm -rf "${WORKDIR}"
rm -rf "${BOOST_TARBALL}"

echo "Fatto: ${OUT_TARBALL}"

