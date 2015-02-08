require './spec_helper'
Context = require '../src/context'

describe "src/context", ->
  it "call initState if props is null", ->
    initStateSpy = sinon.spy()
    updateSpy = sinon.spy()
    context = new class extends Context
      initState: (props) ->
        initStateSpy()
        {a: 1}
      expandTemplate: (props, state) -> state
    context.props = {}

    # Instead of updater
    context.on 'internal:template-ready', (context, templateProps) =>
      updateSpy(templateProps.a)
      context.emit 'internal:rendered'

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
