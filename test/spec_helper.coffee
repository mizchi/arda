require('source-map-support').install()
global.Promise = require 'bluebird'
global.React   = require 'react'
global.assert  = require 'power-assert'

cheerio = require 'cheerio'
global.$$ = (html) -> cheerio.load html
