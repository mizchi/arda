# ChangeLog

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
