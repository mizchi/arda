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
      context.update((state) => {a: state.a+1})
      .then =>
        assert initStateSpy.calledOnce
        assert updateSpy.calledWith(2)
        context.update((state) => {a: state.a+1})
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
