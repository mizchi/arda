# Arda

[![Build Status](https://drone.io/github.com/mizchi/arda/status.png)](https://drone.io/github.com/mizchi/arda/latest)

WIP

## TODO for Release(1.0.0)

- [x] Event Discrypter & Subscriber
- [ ] Check disposer with child context
- [x] TypeScript definition file
- [x] Dogfooding by author's job

## Minimum Case

```coffee
window.React = require 'react'
window.Promise = require 'bluebird'
Arda = require 'arda'

class HelloComponent extends Arda.Component
  render: ->
    React.createElement 'h1', {}, name: 'Hello Arda'

class HelloContext extends Arda.Context
  @component: HelloComponent

window.addEventListener 'DOMContentLoaded', ->
  router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(HelloContext, {})
```

## Transition

Router has `pushContext`, `popContext` and `replaceContext`.

```coffee
window.React = require 'react'
window.Promise = require 'bluebird'
Arda = require 'arda'

class MainContext extends Arda.Context
  @component:
    class Main extends Arda.Component
      render: ->
        React.createElement 'h1', {}, name: 'Main'

class SubContext extends Arda.Context
  @component:
    class Sub extends Arda.Component
      render: ->
        React.createElement 'h1', {}, name: 'Sub'

window.addEventListener 'DOMContentLoaded', ->
  window.router = new Arda.Router(Arda.DefaultLayout, document.body)
  router.pushContext(MainContext, {})             # Main
  .then => router.pushContext(SubContext, {})     # Main, Sub
  .then => router.pushContext(MainContext, {})    # Main, Sub, Main
  .then => router.popContext()                    # Main, Sub
  .then => router.replaceContext(MainContext, {}) # Main, Main
  .then => router.replaceContext(SubContext, {})  # Main, Sub
  .then => console.log router.history
```

## LICENSE

MIT
