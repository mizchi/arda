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
