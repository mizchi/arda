module.exports =
class Component extends React.Component
  @contextTypes:
    shared: React.PropTypes.any

  dispatch: ->
    # debugger
    @context.shared.emit arguments...

  createChildRouter: (node) ->
    Router = require './router'
    DefaultLayout = require './default-layout'

    childRouter = new Router(DefaultLayout, node)
    childRouter

  createContextOnNode: (node, contextClass, props) ->
    childRouter = @createChildRouter(node)
    childRouter.pushContext(contextClass, props)
    .then (context) => Promise.resolve(context)
