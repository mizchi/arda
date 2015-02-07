React = require 'react'
{EventEmitter} = require 'events'

# DEBUG = true

Ow = {}
Ow.root = (component, context, state, el = null) ->
  rendered =
    React.withContext {shared: context}, ->
      React.createFactory(Component)(state)
  if el?
    React.render rendered, el
  else
    React.renderToString rendered

class Ow.Component extends React.Component
  @contextTypes:
    shared: React.PropTypes.object

  emit: ->
    @context.shared.emit arguments...

  on  : -> @context.shared.on arguments...
  off : -> @context.shared.off arguments...

class Ow.DefaultLayout extends Ow.Component
  render: ->
    React.createElement 'div', {className: 'Ow-container'}, [
      @props.activeComponent
    ]

class Ow.Context extends EventEmitter
  root: (component, state, el = null) ->
    Ow.root(component, @, state, el)

class Ow.Router
  constructor: (@layoutComponent, @el)->
    @_layout = React.createFactory(@layoutComponent)
    @history = []
    @mounted = null

  _updateActiveComponent: ->

  # typeof Ow.Component => Thenable<Boolean>
  pushContext: (contextClass, initialProps = {}) ->
    context = new contextClass
    activeComponent =
      React.withContext {shared: context}, ->
        React.createFactory(contextClass.component)(initialProps)

    rendered = @_layout {activeComponent}
    # initialize
    if @mounted?
      @mounted.setDefaultProps {activeComponent}
    else
      if @el
        @mounted = React.render rendered, @el
      else
        console.log 'rendered', React.renderToString rendered

  popContext: ->
  replaceContext: ->

# Application
## Components
class Header extends Ow.Component
  render: ->
    React.createElement 'div', {}, 'header'

class Main extends Ow.Component
  componentWillMount: -> @emit 'main will mount', {}
  render: ->
    React.createElement 'div',  {}, [
      React.createElement Header, {}, [
      ]
      React.createElement 'div', {}, 'hello'
    ]

class Edit extends Ow.Component
  componentWillMount: ->
    @emit 'edit will mount', {}
  render: ->
    React.createElement 'div', {}, 'edit'

## Context Selector
class MainContext extends Ow.Context
  @component: Main
  @childContexts: ->
    edit: EditContext

  initState: -> {}
  aggregate: -> {}

  subscribe: (subscribe) ->
    subscribe 'created', ->
    subscribe 'paused', ->

editSubscriber = (edit, subscribe) ->
class EditContext extends Ow.Context
  component: Edit
  initState: -> {}
  aggregate: -> {}
  subscribe: (subscribe) ->
    editSubscriber @, subscribe

router = new Ow.Router Ow.DefaultLayout, null
router.pushContext(MainContext, {})
