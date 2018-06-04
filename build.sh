#!/bin/bash

echo "Building from ./src/ into ./docs/"

# setup containing directories
rm -rf docs/
mkdir docs
mkdir docs/assets
mkdir docs/blog

# copy all base files
cp -rf ./src/ ./docs/

# minify html
html-minifier --input-dir ./src/ --output-dir ./docs/ --file-ext html --collapse-whitespace --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css

# minify css
cssnano ./src/assets/style.css ./docs/assets/style.css

echo "Build complete!"