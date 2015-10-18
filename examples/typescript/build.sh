#!/usr/bin/env
tsc
browserify -t babelify index.js -o bundle.js
