#!/bin/bash
# Invoke with
# find . -name "*.md" -print0 | xargs -0 -I file ./prepend.sh file

# Given a file path as an argument
# 1. get the file name
# 2. prepend template string to the top of the source file
# 3. resave original source file

filepath="$1"
file_name=$(basename $filepath)

# Getting the file name (title)
md='.md'
title=${file_name%$md}

# Prepend front-matter to files
TEMPLATE="---
outputFileName: index.html
---
"

echo "$TEMPLATE" | cat - "$filepath" > temp && mv temp "$filepath"