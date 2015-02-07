# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

global.React = require 'react'
global.Promise = require 'bluebird'

Ow = require './src'

module.exports = class Context1 extends Ow.Context
  @component: class Test extends Ow.Component
    render: -> React.createElement 'div', {}, @props.name

# # Application
# router = new Ow.Router Ow.DefaultLayout, document.body
# router.pushContext(Context1, {name: 1}).then ->
#   console.log router.renderedHtml
#   router.pushContext(Context1, {name: 2}).then ->
#     console.log router.renderedHtml
element = React.createFactory(Context1.component)({name: 1})
app = React.render element, document.body
# console.log document.body.innerHTML
# console.log app.props = {name: 1}
# app = React.render element, document.body
app.props = {name: 2}
app.forceUpdate()
module.exports = app
# app.updateForce()
# # app.setProps({name: 2})
console.log document.body.innerHTML
