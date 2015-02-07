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

  describe '#popContext', ->
    it "throws at blank", (done) ->
      router = new Ow.Router Ow.DefaultLayout, null
      router.popContext()
      .then -> done 1
      .catch -> done()

    it "dispose last context", (done) ->
      class Context extends Ow.Context
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {className: 'name'}
      router = new Ow.Router Ow.DefaultLayout, null
      router.pushContext(Context, {}).then ->
        assert router.history.length is 1
        router.popContext().then ->
          assert router.history.length is 0
          assert !router.activeContext?
          done()

  describe '#replaceContext', ->

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
          subscribe 'resumed' , -> spy 'resumed'

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
          router.popContext().then ->
            assert spy.calledWith('resumed')
            assert spy.calledWith('started')
            assert spy.callCount is 5
            done()

    it "fire disposed", (done) ->
      class Context1 extends Ow.Context
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {}, ''

      spy = sinon.spy()
      class Context2 extends Ow.Context
        @component: class Test extends Ow.Component
          render: -> React.createElement 'div', {}, ''

        subscribe: (subscribe) ->
          subscribe 'disposed' , -> spy 'disposed'

      router = new Ow.Router Ow.DefaultLayout, null
      router.pushContext(Context1, {}).then ->
        router.pushContext(Context2, {}).then ->
          router.popContext().then ->
            assert spy.calledWith('disposed')
            assert spy.callCount is 1
            done()
