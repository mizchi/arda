require './spec_helper'
Arda = require '../src'

React = require 'react'
ReactDOM = require 'react-dom'

describe "src/component", ->
  describe '#dispatch', ->
    it 'use shared context emitter', (done) ->
      HelloComponent = React.createClass
        mixins: [Arda.mixin]
        componentDidMount: ->
          @dispatch 'foo'

        render: ->
          React.createElement 'div'

      class HelloContext extends Arda.Context
        subscribers: [
          (context, subscribe) ->
            assert context instanceof Arda.Context
            subscribe 'foo', (prop) =>
              subscribe 'bar', =>
                done()
        ]
        component: HelloComponent

      router = new Arda.Router(Arda.DefaultLayout, document.body)
      router.pushContext(HelloContext, {}).then (context) =>
        assert context instanceof Arda.Context
        context.emit 'bar'

    context 'without Rx', ->
      beforeEach  -> delete global.Rx
      it '`subscribe` throw with 1 argument', (done) ->
        HelloComponent = React.createClass
          mixins: [Arda.mixin]
          componentDidMount: -> @dispatch 'foo'
          render: -> React.createElement 'div'

        class HelloContext extends Arda.Context
          subscribers: [
            (context, subscribe) ->
              try
                fooStream = subscribe 'foo'
                done 1
              catch e
                done()
          ]
          component: HelloComponent

        router = new Arda.Router(Arda.DefaultLayout, document.body)
        router.pushContext(HelloContext, {})

  describe '#createChildRouter', ->
    it 'create router', (done)->
      TestComponent = React.createClass
        mixins: [Arda.mixin]
        componentDidMount: ->
          subRouter = @createChildRouter @refs.container
          assert subRouter instanceof Arda.Router
          done()

        render: ->
          React.createElement 'div', {}, [
            React.createElement 'div', {key: 1, ref:'container'}
          ]

      c = React.createFactory(TestComponent)
      ReactDOM.render c(), document.body

  describe '#createContextOnNode', ->
    it 'create context', (done) ->
      class Context extends Arda.Context
        component: React.createClass
          mixins: [Arda.mixin]
          componentDidMount: ->
            done()
          render: ->
            React.createElement 'div'

      TestComponent = React.createClass
        mixins: [Arda.mixin]
        componentDidMount: ->
          @createContextOnNode(@refs.container, Context, {})

        render: ->
          React.createElement 'div', {}, [
            React.createElement 'div', {key: 1, ref:'container'}
          ]

      c = React.createFactory(TestComponent)
      ReactDOM.render c(), document.body
