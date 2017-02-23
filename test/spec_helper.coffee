jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.defaultView
global.navigator = window.navigator

global.React   = require 'react'
global.assert  = require 'power-assert'
global.sinon   = require 'sinon'

cheerio = require 'cheerio'
global.$$ = (html) -> cheerio.load html
# console.warn = ->

beforeEach -> @sinon = sinon.sandbox.create()
afterEach ->
  @sinon.restore()
  document.body.innerHTML = ''
