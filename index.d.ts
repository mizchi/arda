// Arda, also known as the Earth, was the world in which Elves, Men, Dwarves, and Hobbits live.
// ref. http://lotr.wikia.com/wiki/Arda
declare module Arda {
  type Promisable<T> = T | Promise<T>;

  export class Scene<Initializers, Query, Props> {
    constructor(p: Initializers);
    static component: typeof Component;

    // Immutable object given by pushContext
    initializers: Initializers;

    // Mutable object update by initState and context.update
    query: Query;
    activeScene: Scene<any, any, any>;

    initQuery(): Promisable<Query>;
    expandProps(): Promisable<Props>;
    updateQuery(updater: (s: Query) => (Query | void)): Promise<any>;
    subscribe(...args): void;
  }

  export class Stacker {
    constructor(fn: Function);

    activeScene: Scene<any, any, any>;

    pushScene<A, B, C>(scene: Scene<A, B, C>): Promise<Scene<A, B, C>>;

    // history push and wait next context's finish
    pushSceneAndWait<A, B, C>(scene: Scene<A, B, C>): Promise<Scene<A, B, C>>;

    // historay pop with promise
    popScene<A, B, C>(): Promise<Scene<A, B, C>>;

    // historay replace with promise
    replacehScene<A, B, C>(scene: Scene<A, B, C>): Promise<Scene<A, B, C>>;

  }

  export var mixin: {
    dispatch: (eventName: string, ...args: any[]) => boolean;
  };

  export class Component<Props, State> {
    refs: any;
    props: Props;
    state: State;
    context: {
      rootProps: any;
    };
    dispatch: (eventName: string, ...args: any[]) => boolean;
  }
}
