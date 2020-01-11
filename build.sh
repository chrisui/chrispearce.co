#!/bin/bash

echo "Building from ./src/ into ./docs/"

# setup containing directories
rm -rf ./docs/
mkdir docs

# copy all base files
cp -rf ./src/. ./docs/

# minify html
html-minifier --input-dir ./src/ --output-dir ./docs/ --file-ext html --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css

# autoprefix + minify css
autoprefixer-cli -o ./docs/assets/style.css ./src/assets/style.css
cssnano ./docs/assets/style.css ./docs/assets/style.css

# Optimise Images
tinypng ./docs/assets/ -k 4HExNBRdPwVEH7TxluFrfv9UrVeNt8fp

echo "Build complete!"