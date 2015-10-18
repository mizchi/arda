import test from 'ava';
import {Scene} from '../src/scene';

class TestScene extends Scene {
  initQuery() {
    return {a: 1};
  }
  expandProps() {
    return {aa: this.initializers.a + this.query.a};
  }
}

class AsyncInitStateScene extends Scene {
  async initQuery() {
    await new Promise(done => setTimeout(done, 100));
    return {a: 1};
  }
  expandProps() {
    return {};
  }
}

test('scene#initialize', async (t) => {
  const s = new TestScene({a: 2});
  await s.initialize();
  t.same(s.initializers, {a: 2});
  t.same(s.query, {a: 1});
  t.same(s.expandProps(), {aa: 3});
  t.end();
});

test('scene#update', async (t) => {
  const s = new TestScene({a: 1});
  await s.initialize();

  t.same(s.query, {a: 1});
  await s.updateQuery(s => {
    return {a: s.a + 1};
  });
  t.same(s.query, {a: 2});

  await s.updateQuery(s => {
    s.a = 4;
  });
  t.same(s.query, {a: 4});
  t.end();
});

test('scene#update async', async (t) => {
  const s = new AsyncInitStateScene({a: 1});
  await s.initialize();

  t.same(s.query, {a: 1});
  t.end();
});

test('scene#dispose', async (t) => {
  const s = new TestScene({a: 1});
  await s.initialize();

  t.notOk(s.disposed);
  await s.dispose();
  t.ok(s.disposed);
  t.notOk(s.initializers);
  t.notOk(s.query);
  t.throws(() => t.updateQuery(s => {}));

  t.end();
});
