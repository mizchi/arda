window.React = require 'react'
Arda = require '../../src/'

T = React.PropTypes
Layout = React.createClass
  childContextTypes:
    ctx: T.object

  contextTypes:
    ctx: T.object

  getChildContext: ->
    ctx: @getCtx()

  getCtx: -> @props.ctx ? @context.ctx

  dispatch: ->
    @getCtx().emit arguments...

  getInitialState: ->
    activeContext: null
    templateProps: {}

  # componentDidMount: ->
  #   @popupRouter = new Arda.Router(Arda.DefaultLayout, @refs.popup.getDOMNode())
  #   @popupRouter.pushContext(require('../../contexts/popup'), {}).then (context) =>
  #     app.popup = context
  #     @popupRouter.emit 'popup:ready'

  render: ->
    $ = React.createElement
    $ 'div', id: 'layout',  [
      $ 'div', ref: 'popup', className: 'popupContainer', style: {width: '100%'}
      if @state.activeContext?
        @state.templateProps.ref = 'root'
        @state.templateProps.ctx = @state.activeContext
        React.createElement @state.activeContext?.component, @state.templateProps
      else
        null
    ]


Clicker = React.createClass
  mixins: [Arda.mixin]
  render: ->
    React.createElement 'button', {onClick: @onClick}, @props.cnt

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
  router = new Arda.Router(Layout, document.body)
  router.pushContext(ClickerContext, {})
