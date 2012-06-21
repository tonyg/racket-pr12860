#!/bin/sh
cat test-input | nc localhost 5999 > test-output && diff test-input test-output
