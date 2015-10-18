# ChangeLog

## v0.17.0

- Support React 0.14
- Rewrite all with Babel from scratch
- Rename API
  - Router -> Stacker
  - Context -> Scene
  - Router#pushState -> Stacker#pushScene
  - Router#popState -> Stacker#popScene
  - Router#replaceState -> Stacker#replaceScene
- Deprecated: Context#subscribers, subscribe. Use constructor

## v0.13

- Now occuring warnings again. Roolback internal to avoid nested case.

## v0.12

- Remove static member access in Context Class
  - Context's `static component` -> `get component()`
  - Context's `static subscribers` -> `get subscribers()`
  - Reason: ES6 classese extends can't extend static props. CoffeeScript and TypeScript work but Babel doesn't
- Remove Arda.Component class
  - Use React.createClass `Arda.mixin` instead.
  - Reason: ES6 Classes is not filled React context features. If it works well later, I will restore it.
- No warning now

## v0.11

- Cache context state on pop
