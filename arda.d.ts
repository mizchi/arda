// Arda, also known as the Earth, was the world in which Elves, Men, Dwarves, and Hobbits live.
// ref. http://lotr.wikia.com/wiki/Arda
declare module Arda {
  export class Router {
    // mount on element with layout component
    // example.
    //    new Arda.Router(Arda.DefaultLayout, document.body);
    constructor(layout: typeof Component, el: HTMLElement);

    // history push with promise
    // example.
    //    var router = new Arda.Router(Arda.DefaultLayout, document.body);
    pushContext(context: typeof Context, args?: any): Thenable<Context<any, any, any>>;

    // history push and wait next context's finish
    pushContextAndWaitForBack(context: typeof Context, args?: any): Thenable<Context<any, any, any>>;

    // historay replace with promise
    replaceContext(context: typeof Context, args?: any): Thenable<Context<any, any, any>>;

    // historay pop with promise
    popContext(): Thenable<Context<any, any, any>>;
  }

  export var mixin: {
    dispatch: (eventName: string, ...args: any[]) => boolean;
  };

  // Arda.Component extends React.Component
  export class Component<ComponentProps, InternalState> {
    refs: any;
    props: ComponentProps;
    state: InternalState;
    dispatch: (eventName: string, ...args: any[]) => boolean;
  }

  // Arda.Component extends React.Component
  export class DefaultLayout<ComponentProps> extends Component<{}, {
    // Top context on history
    activeContext: Context<any, any, ComponentProps>;
    // last template props
    templateProps: ComponentProps;
  }> {}

  export class Context<Props, State, ComponentProps> {
    // root component of this context
    static component: typeof Component;

    // static subscribers are automatically delegated at instantiate
    // example
    //     class MyContext extends Context
    //        static subscribers: [
    //          require('./lifecycle-subscriber'),
    //          (context: MyContext, subscribe) => {
    //            subscribe('my:update', () => console.log('updated'))
    //          }
    static subscribers: ((
      self: any,
      subscribe: (eventName: string, ...args: any[]) => any
    ) => any)[];

    delegate(
      fn: (
        subscribe:
          ((eventName: string, fn?: (...args: any[]) => any) => any)
      ) => void
    )

    // Immutable object given by pushContext
    props: Props;

    // Mutable object update by initState and context.update
    state: State;

    getActiveComponent(): Component<ComponentProps, any>;
    initState(p: Props): State | Thenable<State>;
    expandComponentProps(p: Props, s: State): ComponentProps | Thenable<ComponentProps>;
    update(updater?: (s: State) => (State | void)): Thenable<any>;
  }

  // Type checking helper for typescript
  export function subscriber<Props, State>
  (
    fn: (
      context: Context<Props, State, any>,
      subscribe:
        ((eventName: string, fn?: (...args: any[]) => any) => any)
    ) => void
  ):
  (
    fn: (
      context: Context<Props, State, any>,
      subscribe:
        ((eventName: string, fn?: (...args: any[]) => any) => any)
    ) => void
  ) => void

  // Agnostic local Promise
  export interface Thenable<R> {
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => Thenable<U>): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => U): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => Thenable<U>, onRejected?: (error: any) => void): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => Thenable<U>): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => U): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => void): Thenable<U>;
    then<U>(onFulfilled?: (value: R) => U, onRejected?: (error: any) => void): Thenable<any>;
    then<U>(onFulfilled?: (value: any) => any, onRejected?: (error: any) => void): Thenable<any>;
    // TODO: fix this optional later
    catch?<U>(onRejected?: (error: any) => U): Thenable<U>;
    catch?<U>(onRejected?: (error: any) => void): Thenable<U>;
    catch?(onRejected?: (error: any) => void): Thenable<any>;
  }

}
