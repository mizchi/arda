#!/usr/bin/env
dtsm install
tsc index.ts
browserify -o bundle.js index.js
