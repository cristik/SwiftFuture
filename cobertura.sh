#!/usr/bin/env bash
set -euo pipefail

function convert_file {
  local xccovarchive_file="$1"
  local file_path="$2"
  filename=$(basename -- "$file_path")
  extension="${filename##*.}"
  basename="${filename%.*}"
  echo "<class name=\"$basename\" filename=\"$file_path\" line-rate=\"1.0\" branch-rate=\"1.0\" complexity=\"1.0\"><methods></methods><lines>"
  xcrun xccov view --file "$file_path" "$xccovarchive_file" | \
    sed -n '
    s/^ *\([0-9][0-9]*\): *\([0-9][0-9]*\).*$/<line number="\1" hits="\2"\/>/p
    '
  echo '</lines></class>'
}

function xccov_to_generic {
  echo '<?xml version="1.0" ?>'
  echo '<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">'
  echo '<coverage line-rate="0.0" branch-rate="0.0" lines-covered="0" lines-valid="0" branches-covered="0" branches-valid="0" complexity="0" version="4.0" timestamp="123">'
  echo '<sources><source>'`pwd`'</source></sources>'
  echo '<packages><package name="" line-rate="1.0" branch-rate="1.0" complexity="1.0"><classes>'
  for xccovarchive_file in "$@"; do
    xcrun xccov view --file-list "$xccovarchive_file" | while read -r file_name; do
      convert_file "$xccovarchive_file" "$file_name"
    done
  done
  echo '</classes></package></packages></coverage>'
}

xccov_to_generic build/Logs/Test/*.xccovarchive > build/reports/cobertura.xml
cat build/reports/cobertura.xml