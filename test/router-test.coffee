require './spec_helper'
Ow = require '../src/index'

describe "src/router", ->
  describe '#pushContext', ->
    it "will mount target by pushContext", (done) ->
      class TestContext extends Ow.Context
        @component: class Test extends Ow.Component
          componentWillMount: -> done()
          render: -> React.createElement 'div', {}, 'test'
      router = new Ow.Router Ow.DefaultLayout, null
      router.pushContext(TestContext, {})

    it "will render template by default", ->
      class TestContext extends Ow.Context
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name

      router = new Ow.Router Ow.DefaultLayout, null
      router.pushContext(TestContext, {name: 'john doe'}).then ->
        assert $$(router.renderedHtml)('.name').text() is 'my name is john doe'

    it "will render template with initState and expandTemplate", ->
      class TestContext extends Ow.Context
        initState: (props) -> name: props.name + ' foo'
        expandTemplate: (props, state) -> name: state.name + ' bar'
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name
      router = new Ow.Router Ow.DefaultLayout, null
      router.pushContext(TestContext, {name: 'john'}).then ->
        assert $$(router.renderedHtml)('.name').text() is 'my name is john foo bar'

    it "will render template with initState and expandTemplate with Promise", ->
      class TestContext extends Ow.Context
        initState: (props) -> new Promise (done) ->
          done name: props.name + ' foo'
        expandTemplate: (props, state) -> new Promise (done) ->
          done name: state.name + ' bar'
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name

      router = new Ow.Router Ow.DefaultLayout, null
      router.pushContext(TestContext, {name: 'john'}).then ->
        assert $$(router.renderedHtml)('.name').text() is 'my name is john foo bar'

  describe 'Lifecycle', ->
    it "fires created | started | resumed | disposed", (done) ->
      spy = sinon.spy()
      class Context1 extends Ow.Context
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {}, ''
        subscribe: (subscribe) ->
          subscribe 'created', -> spy 'created'
          subscribe 'started', -> spy 'started'
          subscribe 'paused' , -> spy 'paused'

      class Context2 extends Ow.Context
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {}, ''

      router = new Ow.Router Ow.DefaultLayout, null
      assert !router.activeContext
      router.pushContext(Context1, {}).then ->
        assert spy.calledWith('created')
        assert spy.calledWith('started')
        assert spy.callCount is 2
        router.pushContext(Context2, {}).then ->
          assert spy.calledWith('paused')
          assert spy.callCount is 3
          done()
