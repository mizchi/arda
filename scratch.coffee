# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

global.React = require 'react'
global.Promise = require 'bluebird'

Ow = require './src'

module.exports = class Context1 extends Ow.Context
  initState: (props) -> props
  expandTemplate: (props, state) -> state
  @component:
    class Test extends Ow.Component
      render: -> React.createElement 'div', {}, @props.name

# # Application
router = new Ow.Router Ow.DefaultLayout, document.body
router.pushContext(Context1, {name: 1}).then ->
  router.activeContext.updateState({name: 2}).then ->
    console.log router.activeContext.state
    console.log document.body.innerHTML
    router.popContext().then ->
      console.log document.body.innerHTML
