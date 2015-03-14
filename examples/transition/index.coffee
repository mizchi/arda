window.React = require 'react'
window.Promise = require 'bluebird'
Arda = require '../../src/'

class MainContext extends Arda.Context
  component:
    class Main extends Arda.Component
      render: ->
        React.createElement 'h1', {}, 'Main'

class SubContext extends Arda.Context
  component:
    class Sub extends Arda.Component
      render: ->
        React.createElement 'h1', {}, 'Sub'

window.addEventListener 'DOMContentLoaded', ->
  window.router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(MainContext, {})             # Main
  .then => router.pushContext(SubContext, {})     # Main, Sub
  .then => router.pushContext(MainContext, {})    # Main, Sub, Main
  .then => router.popContext()                    # Main, Sub
  .then => router.replaceContext(MainContext, {}) # Main, Main
  .then => router.replaceContext(SubContext, {})  # Main, Sub
  .then => console.log router.history
