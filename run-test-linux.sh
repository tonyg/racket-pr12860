#!/bin/sh
cat test-input | nc -q 5 localhost 5999 > test-output && diff -u test-input test-output
