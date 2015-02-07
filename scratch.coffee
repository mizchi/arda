global.React = require 'react'
Ow = require './src'

# Application
## Components
class Main extends Ow.Component
  componentWillMount: ->
    @dispatch 'main will mount', {}

  render: ->
    React.createElement 'div', {}, 'main'

class Edit extends Ow.Component
  componentWillMount: ->
    @dispatch 'edit will mount', {}
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
