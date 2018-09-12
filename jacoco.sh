#!/usr/bin/env bash
set -euo pipefail

function convert_file {
  local xccovarchive_file="$1"
  local file_path="$2"
  filename=$(basename -- "$file_path")
  extension="${filename##*.}"
  filename="${filename%.*}"
  echo "<class name=\"$filename\"><sourcefile name=\"$file_path\">"
  xcrun xccov view --file "$file_path" "$xccovarchive_file" | \
    sed -n '
    s/^ *\([0-9][0-9]*\): *\([0-9][0-9]*\).*$/<line nr="\1" mi="0" ci="\2" mb="0" cb="0"\/>/p
    '
  echo '</sourcefile></class>'
}

function xccov_to_generic {
  echo '<report name="jaCoCo">'
  for xccovarchive_file in "$@"; do
    xcrun xccov view --file-list "$xccovarchive_file" | while read -r file_name; do
      convert_file "$xccovarchive_file" "$file_name"
    done
  done
  echo '</report>'
}

xccov_to_generic build/Logs/Test/*.xccovarchive > build/reports/jacoco.xml
cat build/reports/jacoco.xml