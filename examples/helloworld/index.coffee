global.React = require 'react'
global.Promise = require 'bluebird'
Arda = require '../../src/'

class HelloComponent extends Arda.Component
  render: ->
    React.createElement 'h1', {}, name: 'Hello Arda'

class HelloContext extends Arda.Context
  @component: HelloComponent

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(HelloContext, {})
