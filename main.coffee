# setup dom before react
jsdom = require('jsdom').jsdom
global.document  = jsdom('<html><body></body></html>')
global.window    = document.parentWindow
global.navigator = window.navigator

# Libraries
global.React = require 'react'
global.Promise = require 'bluebird'
global.Arda = Arda = require './src'

A = React.createClass
  childContextTypes:
    name: React.PropTypes.any

  getChildContext: ->
    # name: @props.name
    console.log 'update context', @state.name
    name: @state.name

  getInitialState: ->
    {name: 'state name'}

  render: ->
    React.createFactory(B) {}

B = React.createClass
  contextTypes:
    name: React.PropTypes.string.isRequired

  componentDidMount: ->
    console.log document.body.innerHTML
    console.log @context
    setTimeout ->
      c.setProps {name: '3'}
      c.setState {name: '3'}
      console.log document.body.innerHTML

  render: ->
    React.createElement 'div', {}, this.context.name
    # <div>My name is: {this.context.name}</div>;

c = React.render(React.createFactory(A)({name: '1'}), document.body);
# console.log document.body.innerHTML
