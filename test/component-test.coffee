require './spec_helper'
require '../src/component'
Ow = require '../src'
describe "src/component", ->
  describe '#createChildContext', ->
  it "should be written", (done) ->
    class Main extends Ow.Component
      constructor: ->
        super
        @state = edit: @createChildContext('edit', EditContext)

      render: ->
        React.createElement 'div', {}, [
          React.createElement 'h1', {}, 'Main'
          @createElementByContextKey('edit', {})
        ]

    class Edit extends Ow.Component
      render: ->
        React.createElement 'div', {}, [
          React.createElement 'h1', {}, 'Edit'
        ]

    class MainContext extends Ow.Context
      @component: Main

    class EditContext extends Ow.Context
      @component: Edit

    # # Application
    router = new Ow.Router Ow.DefaultLayout, document.body
    router.pushContext(EditContext, {}).then ->
      assert document.body.innerHTML.indexOf 'Edit' > -1
      assert document.body.innerHTML.indexOf 'Main' is -1
      router.pushContext(MainContext, {}).then ->
        assert document.body.innerHTML.indexOf 'Edit' > -1
        assert document.body.innerHTML.indexOf 'Main' > -1
        done()
