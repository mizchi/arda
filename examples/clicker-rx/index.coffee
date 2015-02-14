window.React = require 'react'
window.Promise = require 'bluebird'
window.Rx = require 'rx'
Arda = require '../../src/'

class Clicker extends Arda.Component
  render: ->
    React.createElement 'button', {onClick: @onClick.bind(@)}, 'double click me'

  onClick: ->
    @dispatch 'clicker:click'

class ClickerContext extends Arda.Context
  @component: Clicker
  delegate: (subscribe) ->
    super
    subscribe 'context:created', -> console.log 'created'
    clicks = Rx.Node.fromEvent @, 'clicker:click'
    clicks
      # .buffer clicks.throttle 250
      # .map (xs) -> xs.length
      # .filter (n) -> n is 2
      .subscribe (n) -> console.log "double click"

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(ClickerContext, {})
