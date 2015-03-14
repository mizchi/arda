window.React = require 'react'
window.Promise = require 'bluebird'
Arda = require '../../src/'

HelloComponent = React.createClass
  mixin: [Arda.mixin]
  render: ->
    React.createElement 'h1', {}, 'Hello Arda'

class HelloContext extends Arda.Context
  component: HelloComponent

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(HelloContext, {})
