#!/bin/bash

#Requires custom version of rio rgbify which adds terrarium encoding support ( https://github.com/acalcutt/rio-rgbify/ )

INPUT_DIR=./download
OUTPUT_DIR=./output
vrtfile=${OUTPUT_DIR}/swissalti3d_terrarium0-17.vrt
mbtiles=${OUTPUT_DIR}/swissalti3d_terrarium0-17.mbtiles
vrtfile2=${OUTPUT_DIR}/swissalti3d_terrarium0-17_warp.vrt

[ -d "$OUTPUT_DIR" ] || mkdir -p $OUTPUT_DIR || { echo "error: $OUTPUT_DIR " 1>&2; exit 1; }

#rm rio/*
ulimit -s 65536
gdalbuildvrt -overwrite ${vrtfile} ${INPUT_DIR}/*.tif
gdalwarp -r cubicspline -t_srs EPSG:3857 -dstnodata 0 -co COMPRESS=DEFLATE ${vrtfile} ${vrtfile2}
rio rgbify -e terrarium --min-z 0 --max-z 17 -j 24 --format png ${vrtfile2} ${mbtiles}

#sqlite3 ${mbtiles} 'CREATE UNIQUE INDEX tile_index on tiles (zoom_level, tile_column, tile_row);'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "swissalti3d_terrarium_Z12-15" WHERE name = "name" AND value = "";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "JAXA ALOS World 3D 30m (AW3D30) converted with rio rgbify" WHERE name = "description";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "png" WHERE name = "format";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "1" WHERE name = "version";'
sqlite3 ${mbtiles} 'UPDATE metadata SET value = "baselayer" WHERE name = "type";'
sqlite3 ${mbtiles} "INSERT INTO metadata (name,value) VALUES('attribution','<a href=""https://earth.jaxa.jp/en/data/policy/"">AW3D30 (JAXA)</a>');"
#sqlite3 ${mbtiles} 'PRAGMA journal_mode=DELETE;'

