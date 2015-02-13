require './spec_helper'
Arda = require '../src/index'

describe "src/router", ->
  describe '#pushContextAndWaitForBack', ->
    it "will mount target by pushContext", (done) ->
      router = new Arda.Router Arda.DefaultLayout, document.body
      class AutoEndContext extends Arda.Context
        @component: class AutoEnd extends Arda.Component
          componentWillMount: ->
            # It cause back to here
            setTimeout => router.popContext()
          render: -> React.createElement 'div', {}, 'test'

      class TestContext extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, 'test'
      router.pushContext(TestContext, {})
      .then =>
        assert router.pushContextAndWaitForBack instanceof Function
        router.pushContextAndWaitForBack(AutoEndContext, {})
      .then =>
        done()

  describe '#pushContext', ->
    it "will mount target by pushContext", (done) ->
      class TestContext extends Arda.Context
        @component: class Test extends Arda.Component
          componentWillMount: -> done()
          render: -> React.createElement 'div', {}, 'test'
      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(TestContext, {})

    it "will render template by default", ->
      class TestContext extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name

      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(TestContext, {name: 'john doe'})
      .then ->
        assert $$(router.innerHTML)('.name').text() is 'my name is john doe'

    it "will render template with initState and expandTemplate", ->
      class TestContext extends Arda.Context
        initState: (props) -> name: props.name + ' foo'
        expandTemplate: (props, state) -> name: state.name + ' bar'
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name
      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(TestContext, {name: 'john'}).then ->
        assert $$(router.innerHTML)('.name').text() is 'my name is john foo bar'

    it "will render template with initState and expandTemplate with Promise", ->
      class TestContext extends Arda.Context
        initState: (props) -> new Promise (done) ->
          done name: props.name + ' foo'
        expandTemplate: (props, state) -> new Promise (done) ->
          done name: state.name + ' bar'
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name

      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(TestContext, {name: 'john'}).then ->
        assert $$(router.innerHTML)('.name').text() is 'my name is john foo bar'

  describe '#popContext', ->
    it "throws at blank", (done) ->
      router = new Arda.Router Arda.DefaultLayout, null
      try
        router.popContext()
        done 1
      catch
        done()

    it "dispose last context", ->
      class Context extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'name'}
      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(Context, {})
      .then ->
        assert router.history.length is 1
        router.popContext()
      .then ->
        assert router.history.length is 0
        assert !router.activeContext?

  describe '#replaceContext', ->
    it "throws at blank", (done) ->
      class Context1 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, 'context1'
      router = new Arda.Router Arda.DefaultLayout, null
      try
        router.replaceContext(Context1, {})
        done 1
      catch
        done()

    it "replace active context", ->
      class Context1 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, 'context1'

      class Context2 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, 'context2'

      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(Context1, {})
      .then ->
        assert router.history.length is 1
        router.replaceContext(Context2, {})
      .then ->
        assert router.history.length is 1

    it "fire disposed", (done) ->
      class Context1 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, ''

      spy = sinon.spy()
      class Context2 extends Arda.Context
        @subscribers: [
          (context, subscribe) ->
            subscribe 'context:disposed' , -> spy 'disposed'
        ]
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, ''

        # subscribe: (subscribe) ->
        #   subscribe 'disposed' , -> spy 'disposed'

      router = new Arda.Router Arda.DefaultLayout, null
      router.pushContext(Context1, {})
      .then -> router.pushContext(Context2, {})
      .then -> router.popContext()
      .then ->
        assert spy.calledWith('disposed')
        assert spy.callCount is 1
        done()

  describe '#isLocked', ->
    it "return true if on pushContext or popContext", ->
      class TestContext extends Arda.Context
        expandTemplate: (props, state) -> new Promise (_done) ->
          setTimeout -> _done {}

        dispose: -> new Promise (_done) =>
          super
          setTimeout -> _done {}

        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'name'}

      router = new Arda.Router Arda.DefaultLayout, null
      pushing = router.pushContext(TestContext, {})
      assert router.isLocked() is true
      pushing.then ->
        assert router.isLocked() is false
        replacing = router.replaceContext(TestContext, {})
        assert router.isLocked() is true
        replacing
      .then ->
        assert router.isLocked() is false
        popping = router.popContext()
        assert router.isLocked() is true
        popping
      .then ->
        assert router.isLocked() is false

  context 'withDOM', ->
    it 'render', ->
      class Context1 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'content'}, @props.name
      router = new Arda.Router Arda.DefaultLayout, document.body
      router.pushContext(Context1, {name: 1})
      .then ->
        assert $$(document.body.innerHTML)('.content').text() is '1'
        router.pushContext(Context1, {name: 2})
      .then ->
        assert $$(document.body.innerHTML)('.content').text() is '2'

    it 'update' , ->
      class Context1 extends Arda.Context
        initState: (props) -> props
        expandTemplate: (props, state) -> state
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {className: 'content'}, @props.name

      router = new Arda.Router Arda.DefaultLayout, document.body
      router.pushContext(Context1, {name: 1})
      .then -> router.activeContext.update((state) => {name: 2})
      .then ->
        assert $$(document.body.innerHTML)('.content').text() is '2'

  describe 'Lifecycle', ->
    it "fires created | started | resumed | disposed", ->
      spy = sinon.spy()
      class Context1 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, ''
        @subscribers: [
          (component, subscribe) ->
            subscribe 'context:created', -> spy 'created'
            subscribe 'context:started', -> spy 'started'
            subscribe 'context:paused' , -> spy 'paused'
            subscribe 'context:resumed' , -> spy 'resumed'
        ]
      class Context2 extends Arda.Context
        @component: class Test extends Arda.Component
          render: -> React.createElement 'div', {}, ''

      router = new Arda.Router Arda.DefaultLayout, null
      assert !router.activeContext
      router.pushContext(Context1, {}).then ->
        assert spy.calledWith('created')
        assert spy.calledWith('started')
        assert spy.callCount is 2

        router.pushContext(Context2, {})
      .then ->
        assert spy.calledWith('paused')
        assert spy.callCount is 3
        router.popContext()
      .then ->
        assert spy.calledWith('resumed')
        assert spy.calledWith('started')
        assert spy.callCount is 5

  describe 'blank', ->
    it 'create child context and dispose', (done) ->
      class SubContext extends Arda.Context
        @component:
          class SubComponent extends Arda.Component
            render: ->
              React.createElement 'h1', {}, 'Sub'

      class HelloComponent extends Arda.Component
        createChildRouter: (node) ->
          childRouter = new Arda.Router(Arda.DefaultLayout, node)
          # @context.shared.on 'disposed', => childRouter.dispose?()
          childRouter

        createContextOnNode: (node, contextClass, props) ->
          childRouter = @createChildRouter(node)
          childRouter.pushContext(contextClass, props)
          .then (context) => Promise.resolve(context)

        componentDidMount: ->
          subRouter = @createChildRouter @refs.container.getDOMNode()
          subRouter.on 'router:blank', -> done()
          subRouter.pushContext(SubContext, {})
          .then (context) =>
            subRouter.popContext()

        render: ->
          React.createElement 'div', {}, [
            React.createElement 'h1', {}, 'Hello Arda'
            React.createElement 'div', {ref:'container'}
          ]

      class HelloContext extends Arda.Context
        @component: HelloComponent

      router = new Arda.Router(Arda.DefaultLayout, document.body)
      router.pushContext(HelloContext, {})
