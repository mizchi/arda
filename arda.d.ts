// Arda, also known as the Earth, was the world in which Elves, Men, Dwarves, and Hobbits live.
// ref. http://lotr.wikia.com/wiki/Arda
declare module Arda {
  export class Router {
    // mount on element with layout component
    // example.
    //    new Arda.Router(Arda.DefaultLayout, document.body);
    constructor(layout: typeof Component, elOrMountFunc: HTMLElement | Function);

    // history push with promise
    // example.
    //    var router = new Arda.Router(Arda.DefaultLayout, document.body);
    pushContext(context: typeof Context, args?: any): Promise<Context<any, any, any>>;

    // history push and wait next context's finish
    pushContextAndWaitForBack(context: typeof Context, args?: any): Promise<Context<any, any, any>>;

    // historay replace with promise
    replaceContext(context: typeof Context, args?: any): Promise<Context<any, any, any>>;

    // historay pop with promise
    popContext(): Promise<Context<any, any, any>>;
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

  export class DispatcherButton {
    props: {
      event: string;
      args: any[];
    }
  }

  export class Context<Props, State, ComponentProps> {
    // root component of this context
    component: typeof Component;

    // active / pause / disposed
    lifecycle: string;

    // static subscribers are automatically delegated at instantiate
    // example
    //     class MyContext extends Context
    //        static subscribers: [
    //          require('./lifecycle-subscriber'),
    //          (context: MyContext, subscribe) => {
    //            subscribe('my:update', () => console.log('updated'))
    //          }
    subscribers: ((
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
    initState(p: Props): State | Promise<State>;
    expandComponentProps(p: Props, s: State): ComponentProps | Promise<ComponentProps>;
    update(updater?: (s: State) => (State | void)): Promise<any>;
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
}
