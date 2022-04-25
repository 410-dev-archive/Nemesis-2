#!/bin/bash
echo "$(cat $1 | grep $2)" > "$3"