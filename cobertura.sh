#!/usr/bin/env bash
set -euo pipefail

function convert_file {
  local xccovarchive_file="$1"
  local file_path="$2"
  filename=$(basename -- "$file_path")
  extension="${filename##*.}"
  basename="${filename%.*}"
  echo "<class name=\"$basename\" filename=\"$file_path\" line-rate=\"1.0\" branch-rate=\"1.0\" complexity=\"1.0\"><lines>"
  xcrun xccov view --file "$file_path" "$xccovarchive_file" | \
    sed -n '
    s/^ *\([0-9][0-9]*\): *\([0-9][0-9]*\).*$/<line number="\1" hits="\2"\/>/p
    '
  echo '</lines></class>'
}

function xccov_to_generic {
  echo '<coverage line-rate="0.9" branch-rate="0.75"><packages><package name="" line-rate="1.0" branch-rate="1.0" complexity="1.0"><classes>'
  for xccovarchive_file in "$@"; do
    xcrun xccov view --file-list "$xccovarchive_file" | while read -r file_name; do
      convert_file "$xccovarchive_file" "$file_name"
    done
  done
  echo '</classes></package></packages></coverage>'
}

xccov_to_generic build/Logs/Test/*.xccovarchive > build/reports/cobertura.xml
cat build/reports/cobertura.xml