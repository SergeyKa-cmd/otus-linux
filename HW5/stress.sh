#!/bin/bash

# Stress test

dd if=/dev/urandom count=2000000| bzip2 -9 > /dev/null
