#!/bin/bash
pgrep nginx >/dev/null 2>&1
exit $?

