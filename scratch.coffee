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

class ChildContext extends Arda.Context
  expandTemplate: (props, state) ->
    {foo: state.foo}

  constructor: ->
    super
    @on 'disposed', ->
      console.log '+++++++++ child disposed ++++++++++'

  @component:
    class Child extends Arda.Component
      render: ->
        React.createElement 'div', {}, 'Child:'+@props.foo

class Parent extends Arda.Component
  childContexts:
    child: ChildContext

  componentDidMount: ->
    childContext  = @getChildContextByKey('child')

    # childContext.updateState((state) => {foo: 2})
    # .then =>
    #   childContext.updateState((state) => {foo: 4})
    # .then =>
    #   @context.shared.updateState((s) => {name: 'changed'})
    # .then (s) =>
    #   console.log 'updated', document.body.innerHTML

  render: ->
    React.createElement 'div', {}, [
      React.createElement 'h1', {}, name: @props.name
      @createChildElement('child', {})
    ]

class ParentContext extends Arda.Context
  initState: (props) -> props
  expandTemplate: (__, state) -> state
  @component: Parent

global.router = new Arda.Router(Arda.DefaultLayout, document.body)
router.pushContext(ParentContext, {name: 'initial'})
.then =>
  router.pushContext(ParentContext, {name: 'initial'})
.then (willDisposeContext) =>
  willDisposeContext.on 'disposed', ->
    console.log 'parent disposed!'

  router.popContext()
# .then =>
