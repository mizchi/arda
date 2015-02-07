require './spec_helper'
Ow = require '../src/index'

describe "src/router", ->
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
    router.pushContext(TestContext, {name: 'john doe'})
    assert $$(router.renderedHtml)('.name').text() is 'my name is john doe'

  it "will render template with initState and expandTemplate", ->
    class TestContext extends Ow.Context
      initState: (props) -> name: props.name + ' foo'
      expandTemplate: (props, state) -> name: state.name + ' bar'
      @component: class Test extends Ow.Component
        render: -> React.createElement 'div', {className: 'name'}, 'my name is '+@props.name
    router = new Ow.Router Ow.DefaultLayout, null
    router.pushContext(TestContext, {name: 'john'})
    assert $$(router.renderedHtml)('.name').text() is 'my name is john foo bar'

  # context 'update', ->
  #   it "create templateProps by initState and aggregate", (done) ->
  #     class TestContext extends Ow.Context
  #       @component: class Test extends Ow.Component
  #         render: -> React.createElement 'div', {}, 'test'
  #
  #     router = new Ow.Router Ow.DefaultLayout, null
  #     router.pushContext(TestContext, {})
