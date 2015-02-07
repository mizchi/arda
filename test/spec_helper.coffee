require('source-map-support').install()
global.Promise = require 'bluebird'
global.React   = require 'react'
global.assert  = require 'power-assert'
global.sinon   = require 'sinon'

cheerio = require 'cheerio'
global.$$ = (html) -> cheerio.load html

beforeEach -> @sinon = sinon.sandbox.create()
afterEach -> @sinon.restore()
