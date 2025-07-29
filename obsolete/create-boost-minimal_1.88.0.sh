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

# sivium/include/sivium/mesh.hpp:#include <boost/config.hpp>
# sivium/include/sivium/mesh.hpp:#include <boost/geometry.hpp>
# sivium/include/sivium/utils_io.hpp:#include <boost/foreach.hpp>
# sivium/include/sivium/utils_io.hpp:#include <boost/tokenizer.hpp>
#
# sivium/include/sivium/modular_product.hpp:#include <boost/graph/bron_kerbosch_all_cliques.hpp>
# sivium/include/sivium/modular_product.hpp:#include <boost/graph/undirected_graph.hpp>
# sivium/include/sivium/boostgraph.hpp:#include <boost/graph/adjacency_list.hpp>
# sivium/include/sivium/boostgraph.hpp:#include <boost/graph/connected_components.hpp>
# sivium/include/sivium/boostgraph.hpp:#include <boost/graph/bron_kerbosch_all_cliques.hpp>
# sivium/include/sivium/boostgraph.hpp:#include <boost/graph/undirected_graph.hpp>
# sivium/include/sivium/mesh.hpp:#include <boost/graph/adjacency_list.hpp>
# sivium/include/sivium/mesh.hpp:#include <boost/graph/connected_components.hpp>
#
# sivium/include/sivium/mesh.hpp:#include <boost/geometry/geometries/box.hpp>
# sivium/include/sivium/mesh.hpp:#include <boost/geometry/geometries/point.hpp>
# sivium/include/sivium/mesh.hpp:#include <boost/geometry/index/rtree.hpp>
#
# sivium/src/utils_io.cpp:#include <boost/algorithm/string/trim.hpp>
# sivium/src/utils_geometry.cpp:#include <boost/algorithm/string/trim.hpp>
# sivium/src/dataframe.cpp:#include <boost/algorithm/string.hpp>

# Percorsi Boost da conservare
BOOST_SUBDIRS=(
    boost/config
    boost/graph
    boost/geometry
    boost/algorithm
    boost/unordered
    boost/detail
    boost/core
    boost/mpl
    boost/preprocessor
    boost/exception
    boost/assert
    boost/range
    boost/type_traits
    boost/iterator
    boost/mp11
    boost/container_hash
    boost/describe
    boost/utility
    boost/smart_ptr
    boost/tuple
    boost/pending
    boost/property_map
    boost/concept
    boost/functional
    boost/multi_index
    boost/move
    boost/optional
    boost/typeof
    boost/parameter
    boost/tti
    boost/function_types
    boost/integer
    boost/multiprecision
    boost/math
    boost/numeric
    boost/variant
)

BOOST_ROOT_FILES=(
    boost/version.hpp
    boost/config.hpp
    boost/limits.hpp
    boost/geometry.hpp
    boost/foreach.hpp
    boost/tokenizer.hpp
    boost/unordered_set.hpp
    boost/throw_exception.hpp
    boost/noncopyable.hpp
    boost/cstdint.hpp
    boost/assert.hpp
    boost/static_assert.hpp
    boost/scoped_ptr.hpp
    boost/foreach_fwd.hpp
    boost/token_iterator.hpp
    boost/token_functions.hpp
    boost/type_traits.hpp
    boost/type.hpp
    boost/type_index.hpp
    boost/concept_check.hpp
    boost/concept_archetype.hpp
    boost/call_traits.hpp
    boost/operators.hpp
    boost/multi_index_container_fwd.hpp
    boost/multi_index_container.hpp
    boost/optional.hpp
    boost/none.hpp
    boost/none_t.hpp
    boost/next_prior.hpp
    boost/unordered_map.hpp
    boost/utility.hpp
    boost/preprocessor.hpp
    boost/shared_array.hpp
    boost/ref.hpp
    boost/implicit_cast.hpp
    boost/parameter.hpp
    boost/blank.hpp
    boost/blank_fwd.hpp
    boost/rational.hpp
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

