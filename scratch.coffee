# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

# Libraries
global.React = require 'react'
global.Promise = require 'bluebird'
global.Arda = Arda = require './src'

# Application
class SubContext extends Arda.Context
  @component:
    class SubComponent extends Arda.Component
      render: ->
        React.createElement 'h1', {}, 'Sub'

class HelloComponent extends Arda.Component
  componentDidMount: ->
    subRouter = @createChildRouter @refs.container.getDOMNode()
    subRouter.on 'blank', -> console.log 'became blank'
    subRouter.pushContext(SubContext, {})
    .then (context) =>
      subRouter.popContext()
    # @createContextOnNode(@refs.container.getDOMNode(), SubContext, {})

  render: ->
    React.createElement 'div', {}, [
      React.createElement 'div', {key: 1, ref:'container'}
    ]
class HelloContext extends Arda.Context
  @component: HelloComponent

router = new Arda.Router(Arda.DefaultLayout, document.body)
router.pushContext(HelloContext, {})
