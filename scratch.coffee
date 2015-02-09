# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

# supress warnings
console.warn = ->

# Libraries
global.React = require 'react'
global.Promise = require 'bluebird'
Arda = require './src'

window.React = require 'react'
window.Promise = require 'bluebird'
Arda = require '../../src/'

class HelloComponent extends Arda.Component
  render: ->
    React.createElement 'h1', {}, 'Hello Arda'

class HelloContext extends Arda.Context
  @component: HelloComponent

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(HelloContext, {})
  .then =>
    console.log document.body.innerHTML
