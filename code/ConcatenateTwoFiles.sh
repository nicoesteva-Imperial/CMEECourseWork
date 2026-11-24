#!/bin/bash

# TODO 1: exactly THREE arguments (input1 input2 output).
#   Same block as CountLines.sh, but test  $# -ne 3
#   message:  Usage: %s <input1> <input2> <output>

# TODO 2: BOTH inputs must be readable files.
#   Copy your CountLines.sh file check TWICE: once for "$1", once for "$2".

# TODO 3: the output must not be one of the inputs (the notes warn that
#   cat "$1" > "$3" empties the file BEFORE reading it, destroying data).
#   test:  [[ "$3" == "$1" || "$3" == "$2" ]]
#   message idea:  Error: output '%s' must differ from both inputs
#   exit 1

cat "$1" > "$3"
cat "$2" >> "$3"
echo "Merged File is"
cat "$3"
