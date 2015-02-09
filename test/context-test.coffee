require './spec_helper'
Arda = require '../src'
Context = require '../src/context'

describe "src/context", ->
  describe '#update', ->
    it "call initState if props is null", ->
      initStateSpy = sinon.spy()
      updateSpy = sinon.spy()

      class C extends Context
        initState: (props) ->
          initStateSpy()
          {a: 1}
        expandTemplate: (props, state) ->
          updateSpy(state.a)
          state

      context = new C setState: (templateProps) ->
      context.props = {}

      assert !initStateSpy.called
      context.updateState((state) => {a: state.a+1})
      .then =>
        assert initStateSpy.calledOnce
        assert updateSpy.calledWith(2)
        context.updateState((state) => {a: state.a+1})
      .then =>
        assert initStateSpy.calledOnce
        assert updateSpy.calledWith(3)
        assert updateSpy.calledTwice

  describe '#render', ->
    it "should render child context", ->
      class ChildContext extends Arda.Context
        @component: class Child extends Arda.Component
          render: -> React.createElement 'h1', {}, 'Child'

      class Parent extends Arda.Component
        render: ->
          child = new ChildContext
          React.createElement 'div', {}, [
            React.createElement 'h1', {}, 'Parent'
            child.render({})
          ]
      React.render React.createFactory(Parent)({}), document.body
      assert document.body.innerHTML.indexOf('Parent') > -1
      assert document.body.innerHTML.indexOf('Child') > -1

    it "should update render on child", ->
      class ChildContext extends Arda.Context
        @component: class Child extends Arda.Component
          render: -> React.createElement 'h1', {}, 'Child'

      class Parent extends Arda.Component
        render: ->
          child = new ChildContext
          React.createElement 'div', {}, [
            React.createElement 'h1', {}, 'Parent'
            child.render({})
          ]
      React.render React.createFactory(Parent)({}), document.body
      assert document.body.innerHTML.indexOf('Parent') > -1
      assert document.body.innerHTML.indexOf('Child') > -1

    it "can update inner child" , (done) ->
      class ChildContext extends Arda.Context
        expandTemplate: (__, state) -> state
        @component: class Child extends Arda.Component
          componentDidMount: ->
            done()
          render: ->
            React.createElement 'div', {}, @props?.a ? 'nothing'

      class ParentContext extends Arda.Context
        initState: -> child: new ChildContext(@)
        expandTemplate: (__, state) -> state

        @component: class Parent extends Arda.Component
          componentDidMount: ->
            done()
          render: ->
            React.createElement 'div', [
              @props.child #.render({})
            ]

      new Arda.Router(Arda.DefaultLayout, document.body)
      .pushContext(ParentContext, {})

    it "can update inner child with router" #, (done) ->
      # class ChildContext extends Arda.Context
      #   expandTemplate: (props, state) ->
      #     {foo: state?.foo ? 1}
      #
      #   @component:
      #     class Child extends Arda.Component
      #       render: ->
      #         React.createElement 'div', {className: 'foo'}, 'Child:'+@props.foo
      #
      # class Parent extends Arda.Component
      #   childContexts:
      #     child: ChildContext
      #
      #   componentDidMount: ->
      #     # TODO: Fix first render
      #     assert $$(document.body.innerHTML)('.foo').text() is 'Child:undefined'
      #
      #     childContext  = @getChildContextByKey('child')
      #     childContext.updateState((state) => {foo: 'first-render'})
      #     .then =>
      #       assert $$(document.body.innerHTML)('.foo').text() is 'Child:first-render'
      #       childContext.updateState((state) => {foo: 'second-render'})
      #     .then =>
      #       assert $$(document.body.innerHTML)('.foo').text() is 'Child:second-render'
      #       @context.shared.updateState(=> name: 'aaa')
      #     .then =>
      #       # not refresh
      #       assert $$(document.body.innerHTML)('.foo').text() is 'Child:second-render'
      #       assert $$(document.body.innerHTML)('.name').text() is 'aaa'
      #       done()
      #
      #   render: ->
      #     React.createElement 'div', {}, [
      #       React.createElement 'h1', {className: "name"}, name: @props.name
      #       @createChildElement('child', {fromParent: "aaa"})
      #     ]
      #
      # class ParentContext extends Arda.Context
      #   @component: Parent
      #   initState: (props) -> props
      #   expandTemplate: (__, state) -> state
      #
      # new Arda.Router(Arda.DefaultLayout, document.body)
      # .pushContext(ParentContext, {})
