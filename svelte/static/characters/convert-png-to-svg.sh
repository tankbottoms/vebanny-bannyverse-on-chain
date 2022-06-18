#!/usr/bin/env bash

for p in  *.png; do
      echo "converting $p => .svg"
      convert -alpha remove $f pgm: | mkbitmap -f 32 -t 0.4 - -o - | potrace --svg -o $f.svg
done
