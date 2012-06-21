# Exploring PR 12860

This repo contains code for exploring what's happening with [Racket PR
12860](http://bugs.racket-lang.org/query/?cmd=view&pr=12860).

## Bug description

When `sync`ing on `read-bytes-evt` at the same time as on `alarm-evt`,
it seems that if the `read-bytes-evt` would have come ready but the
`alarm-evt` is the one actually chosen, the input from
`read-bytes-evt` gets corrupted. This only seems to happen if a single
`read-bytes-evt` instance is reused! If a fresh `read-bytes-evt` is
constructed every time, the input stream remains uncorrupted.

To see this, run `racket buggy-server.rkt 0`, which uses a single
`read-bytes-evt` instance but does not use any `alarm-evt`
instances. In another terminal, run `./run-test-osx.sh` (or
`./run-test-linux.sh`, as appropriate). The program
`./run-test-osx.sh` should terminate without producing any output.

Now, kill off the instance of `buggy-server.rkt`, and start another,
this time by running `racket buggy-server.rkt 1`. This instance uses
both a single `read-bytes-evt` instance and an `alarm-evt`
instance. Now, running `./run-test-osx.sh` should still produce no
output, but in fact on most runs, some output (from diffing the input
against the output of the socket) is produced, meaning that the echoed
output differed from the input.
