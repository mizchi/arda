# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

# Libraries
global.React = require 'react'
global.Promise = require 'bluebird'
Orca = require './src'

# class Edit extends Orca.Component
#   render: ->
#     React.createElement 'div', {}, [
#       React.createElement 'h1', {}, 'Edit'
#     ]
#
# class EditContext extends Orca.Context
#   @component: Edit
#
# class Main extends Orca.Component
#   childContexts:
#     edit: EditContext
#
#   render: ->
#     React.createElement 'div', {}, [
#       React.createElement 'h1', {}, 'Main'
#       @createElementByContextKey('edit', {})
#     ]
#
# class MainContext extends Orca.Context
#   @component: Main
#
# # Application
# router = new Orca.Router Orca.DefaultLayout, document.body
# router.pushContext(EditContext, {}).then ->
#   console.log '------'
#   console.log document.body.innerHTML
#   console.log '------'
#   router.pushContext(MainContext, {}).then ->
#     console.log '------'
#     console.log document.body.innerHTML
#     console.log '------'

class ChildContext extends Orca.Context
  expandTemplate: (__, state) -> state
  @component:
    class Child extends Orca.Component
      render: ->
        console.log 'child renderer', @props, @state
        React.createElement 'div', {}, @props?.a ? 'nothing'

class Parent extends Orca.Component
  childContexts:
    child: ChildContext

  componentDidMount: ->
    childContext = @getChildContextByKey('child')
    childContext.updateState({a: 1}).then =>
      # assert.deepEqual childContext.state, {a: 1}
      console.log '~~~~~~~~~', childContext
      console.log document.body.innerHTML
      # done()

  render: ->
    # assert @getChildContextByKey('child')

    React.createElement 'div', {}, [
      React.createElement 'h1', {}, 'Parent'
      @createElementByContextKey('child', {})
    ]

React.render React.createFactory(Parent)({}), document.body
