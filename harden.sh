#!/bin/bash

rm -rf runs/wokwi
mkdir -p runs/wokwi
librelane --pdk-root $PDK_ROOT --pdk sky130A --run-tag wokwi --force-run-dir runs/wokwi src/config_merged.json
