#!/bin/bash

ruby_files=("country-yard/country_yard.rb")

for file in "${ruby_files[@]}"; do
  echo "Running $file..."
  ruby "$file"
  echo "Finished running $file."
done

echo "All Ruby files have been executed."