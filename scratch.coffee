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
global.Arda = Arda = require './src'

# Application
class HelloComponent extends Arda.Component
  render: ->
    React.createElement 'h1', {}, 'Hello Arda'

class HelloContext extends Arda.Context
  @component: HelloComponent

router = new Arda.Router(Arda.DefaultLayout, document.body)
router.pushContext(HelloContext, {})
.then =>
  console.log document.body.innerHTML
