require './spec_helper'
require '../src/component'
Orca = require '../src'
describe "src/component", ->
  describe '#createElementByContextKey', ->
    it "should render child context", ->
      class ChildContext extends Orca.Context
        @component:
          class Child extends Orca.Component
            render: ->
              React.createElement 'div', {}, [
                React.createElement 'h1', {}, 'Child'
              ]

      class Parent extends Orca.Component
        childContexts:
          child: ChildContext

        render: ->
          assert @getChildContextByKey('child')

          React.createElement 'div', {}, [
            React.createElement 'h1', {}, 'Parent'
            @createElementByContextKey('child', {})
          ]

      React.render React.createFactory(Parent)({}), document.body
      assert document.body.innerHTML.indexOf 'Parent' > -1
      assert document.body.innerHTML.indexOf 'Child' > -1

    it "can update inner child", (done) ->
      class ChildContext extends Orca.Context
        expandTemplate: (__, state) -> state
        @component:
          class Child extends Orca.Component
            render: ->
              console.log 'child renderer', @props, @state
              React.createElement 'div', {}, @props?.a ? 'nothing'

      class Parent extends Orca.Component
        childContexts:
          child: ChildContext

        componentDidMount: ->
          childContext = @getChildContextByKey('child')
          childContext.updateState((state) => {a: 1}).then =>
            assert.deepEqual childContext.state, {a: 1}
            console.log '~~~~~~~~~', childContext
            console.log document.body.innerHTML
            done()

        render: ->
          assert @getChildContextByKey('child')

          React.createElement 'div', {}, [
            React.createElement 'h1', {}, 'Parent'
            @createElementByContextKey('child', {})
          ]

      React.render React.createFactory(Parent)({}), document.body
