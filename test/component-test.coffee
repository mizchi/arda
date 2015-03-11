require './spec_helper'
Component = require '../src/component'
Arda = require '../src'

describe "src/component", ->
  describe '#dispatch', ->
    it 'use shared context emitter', (done) ->
      class HelloComponent extends Arda.Component
        componentDidMount: ->
          @dispatch 'foo'

        render: ->
          React.createElement 'div'

      class HelloContext extends Arda.Context
        @subscribers: [
          (context, subscribe) ->
            assert context instanceof Arda.Context
            subscribe 'foo', (prop) =>
              subscribe 'bar', =>
                done()
        ]
        @component: HelloComponent

      router = new Arda.Router(Arda.DefaultLayout, document.body)
      router.pushContext(HelloContext, {}).then (context) =>
        assert context instanceof Arda.Context
        context.emit 'bar'

    context 'without Rx', ->
      beforeEach  -> delete global.Rx
      it '`subscribe` throw with 1 argument', (done) ->
        class HelloComponent extends Arda.Component
          componentDidMount: -> @dispatch 'foo'
          render: -> React.createElement 'div'

        class HelloContext extends Arda.Context
          @subscribers: [
            (context, subscribe) ->
              try
                fooStream = subscribe 'foo'
                done 1
              catch e
                done()
          ]
          @component: HelloComponent

        router = new Arda.Router(Arda.DefaultLayout, document.body)
        router.pushContext(HelloContext, {})

  describe '#createChildRouter', ->
    it 'create router', (done)->
      class TestComponent extends Component
        componentDidMount: ->
          subRouter = @createChildRouter @refs.container.getDOMNode()
          assert subRouter instanceof Arda.Router
          done()

        render: ->
          React.createElement 'div', {}, [
            React.createElement 'div', {key: 1, ref:'container'}
          ]

      c = React.createFactory(TestComponent)
      React.render c(), document.body

  describe '#createContextOnNode', ->
    it 'create context', (done) ->
      class Context extends Arda.Context
        @component: class Component extends Arda.Component
          componentDidMount: ->
            done()
          render: ->
            React.createElement 'div'

      class TestComponent extends Component
        componentDidMount: ->
          @createContextOnNode(@refs.container.getDOMNode(), Context, {})

        render: ->
          React.createElement 'div', {}, [
            React.createElement 'div', {key: 1, ref:'container'}
          ]

      c = React.createFactory(TestComponent)
      React.render c(), document.body
