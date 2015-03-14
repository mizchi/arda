window.React = require 'react'
window.Promise = require 'bluebird'
Arda = require '../../src/'

Clicker = React.createClass
  mixin: [Arda.mixin]
  render: ->
    React.createElement 'button', {onClick: @onClick.bind(@)}, @props.cnt

  onClick: ->
    @dispatch 'hello:++'

class ClickerContext extends Arda.Context
  component: Clicker

  initState: -> cnt: 0
  expandComponentProps: ->
    cnt: @state.cnt

  delegate: (subscribe) ->
    super
    subscribe 'context:created', -> console.log 'created'
    subscribe 'hello:++', ->
      @update (s) => cnt: s.cnt+1

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(ClickerContext, {})
