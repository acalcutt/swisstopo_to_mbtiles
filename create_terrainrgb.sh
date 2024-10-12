#!/bin/bash

#Requires custom version of rio rgbify which adds terrarium encoding support ( https://github.com/acalcutt/rio-rgbify/ )

INPUT_DIR=./download
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/swissalti3d_terrainrgb_z0-Z16.vrt
mbtiles=${OUTPUT_DIR}/swissalti3d_terrainrgb_z0-Z16.mbtiles
vrtfile2=${OUTPUT_DIR}/swissalti3d_terrainrgb_z0-Z16_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
ulimit -s 65536
gdalbuildvrt -overwrite ${vrtfile} ${INPUT_DIR}/*.tif
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}
rio rgbify -b -10000 -i 0.1 --min-z 0 --max-z 16 -j 24 --format webp ${vrtfile2} ${mbtiles}

#sqlite3 ${mbtiles} 'CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "swissalti3d_terrainrgb_z0-Z16_webp" WHERE name = "name" AND value = "";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "swissALTI3D 2024 converted with rio rgbify" WHERE name = "description";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "webp" WHERE name = "format";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "1" WHERE name = "version";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "baselayer" WHERE name = "type";'
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('attribution','<a href=https://www.swisstopo.admin.ch/en/height-model-swissalti3d>swissALTI3D</a>');"
#sqlite3 ${mbtiles} 'PRAGMA journal_mode=DELETE;'

