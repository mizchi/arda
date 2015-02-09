require './spec_helper'
require '../src/component'
Arda = require '../src'
describe "src/component", ->
  describe '#createChildElement', ->
    it "should render child context", ->
      class ChildContext extends Arda.Context
        @component:
          class Child extends Arda.Component
            render: ->
              React.createElement 'div', {}, [
                React.createElement 'h1', {}, 'Child'
              ]

      class Parent extends Arda.Component
        constructor: ->
          super
          @state = child: new ChildContext

        render: ->
          React.createElement 'div', {}, [
            React.createElement 'h1', {}, 'Parent'
            @state.child.render({})
          ]

      React.render React.createFactory(Parent)({}), document.body
      assert document.body.innerHTML.indexOf('Parent') > -1
      assert document.body.innerHTML.indexOf('Child') > -1

    it "can update inner child" #, (done) ->
      # class ChildContext extends Arda.Context
      #   expandTemplate: (__, state) -> state
      #   @component:
      #     class Child extends Arda.Component
      #       render: ->
      #         console.log 'child renderer', @props, @state
      #         React.createElement 'div', {}, @props?.a ? 'nothing'
      #
      # class Parent extends Arda.Component
      #   childContexts:
      #     child: ChildContext
      #
      #   componentDidMount: ->
      #     childContext = @getChildContextByKey('child')
      #     childContext.updateState((state) => {a: 1})
      #     .then =>
      #       assert.deepEqual childContext.state, {a: 1}
      #       done()
      #
      #   render: ->
      #     assert @getChildContextByKey('child')
      #
      #     React.createElement 'div', {}, [
      #       React.createElement 'h1', {}, 'Parent'
      #       @createChildElement('child', {})
      #     ]
      #
      # React.render React.createFactory(Parent)({}), document.body

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
