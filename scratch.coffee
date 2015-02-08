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
Orca = require './src'

class ChildContext extends Orca.Context
  expandTemplate: (props, state) ->
    {foo: state.foo}

  @component:
    class Child extends Orca.Component
      render: ->
        console.log @props
        React.createElement 'div', {}, 'Child:'+@props.foo

class Parent extends Orca.Component
  childContexts:
    child: ChildContext

  componentDidMount: ->
    childContext  = @getChildContextByKey('child')
    childContext.updateState((state) => {foo: 2})
    .then =>
      console.log 'update {foo:2}', document.body.innerHTML

      childContext.updateState((state) => {foo: 4})
      .then =>
        console.log 'update {foo:4}', document.body.innerHTML

  render: ->
    React.createElement 'div', {}, [
      @createElementByContextKey('child', {fromParent: "aaa"})
    ]

class ParentContext extends Orca.Context
  @component: Parent

global.router = new Orca.Router(Orca.DefaultLayout, document.body)
router.pushContext(ParentContext, {})
