# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

# Libraries
global.React = require 'react'
global.Promise = require 'bluebird'
global.Arda = Arda = require './src'

# Application

class SubComponent extends Arda.Component
  render: ->
    React.createElement 'h1', {}, 'Sub'

class SubContext extends Arda.Context
  @component: SubComponent

class HelloComponent extends Arda.Component
  componentDidMount: ->
    subContainer = @refs.container.getDOMNode()
    new Arda.Router(Arda.DefaultLayout, subContainer)
    .pushContext(SubContext, {})
    .then =>
      console.log 'with SubContext', document.body.innerHTML

  render: ->
    React.createElement 'div', {}, [
      React.createElement 'h1', {}, 'Hello Arda'
      React.createElement 'div', {ref:'container'}
    ]
class HelloContext extends Arda.Context
  @component: HelloComponent

router = new Arda.Router(Arda.DefaultLayout, document.body)
router.pushContext(HelloContext, {})
# .then =>
