#!/usr/bin/env
dtsm install
tsc -t es6 index.ts
browserify -o bundle.js index.js
