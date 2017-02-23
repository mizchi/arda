React = require 'react'
DispatcherButton = require './dispatcher-button'
module.exports =
  contextTypes:
    shared: React.PropTypes.any

  dispatch: ->
    @context.shared.emit arguments...

  DispatcherButton: DispatcherButton

  createChildRouter: (node) ->
    Router = require './router'
    DefaultLayout = require './default-layout'

    childRouter = new Router(DefaultLayout, node)
    childRouter

  createContextOnNode: (node, contextClass, props) ->
    childRouter = @createChildRouter(node)
    childRouter.pushContext(contextClass, props)
    .then (context) => Promise.resolve(context)
