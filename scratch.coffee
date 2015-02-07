# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

# Libraries
global.React = require 'react'
global.Promise = require 'bluebird'
Ow = require './src'

class Main extends Ow.Component
  constructor: ->
    super
    @state = edit: @createChildContext('edit', EditContext)

  render: ->
    React.createElement 'div', {}, [
      React.createElement 'h1', {}, 'Main'
      @createElementByContextKey('edit', {})
    ]

class Edit extends Ow.Component
  render: ->
    React.createElement 'div', {}, [
      React.createElement 'h1', {}, 'Edit'
    ]

class MainContext extends Ow.Context
  @component: Main

class EditContext extends Ow.Context
  @component: Edit

# # Application
router = new Ow.Router Ow.DefaultLayout, document.body
router.pushContext(EditContext, {}).then ->
  console.log '------'
  console.log document.body.innerHTML
  console.log '------'
  router.pushContext(MainContext, {}).then ->
    console.log '------'
    console.log document.body.innerHTML
    console.log '------'
