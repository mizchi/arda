#!/usr/bin/env

browserify -t coffeeify --extension=".coffee" -o bundle.js index.coffee
