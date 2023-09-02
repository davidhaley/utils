#!/bin/bash

find . -type f -print0 | xargs -0 stat --format='%Z :%z %n' | sort -n | tail -30
