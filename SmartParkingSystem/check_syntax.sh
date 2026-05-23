#!/bin/bash

echo "Checking Verilog syntax..."

for file in rtl/*.v; do
    echo "Checking $file..."
    iverilog -t null "$file" 2>&1 | grep -i "error\|syntax"
done

echo "Done!"