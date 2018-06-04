TL;DR: [Thunk middleware with custom API](https://gist.github.com/Chrisui/750ee07f500df6355f2bcee96115b769) makes action creators isolated and easily testable.

One of the first features you come across when working with [Redux](http://redux.js.org) is the concept of an "Action Creator". An Action Creator is simply a function which will return an "Action" (an object describing something *to happen* or *has happened*). These Action Creators allow us to reduce boilerplate and repetition across our codebase - instead of calling `dispatch(action)` in our views we are isolating that logic into our Action Creators. 

Then comes the requirement of async flows. The most obvious activity being requesting data from a server. We now need to make our Action Creators handle this gracefully so how do we do it?

The first thing we'll find suggested is using "Thunk Middleware". A Thunk in this sense is simply a function which is returned from our action creator. Redux middleware can then call this with some specific arguments allowing us to *act later* and importantly *with access to new references as provided by the thunk middleware* - in particular we can call `dispatch` again later.

A basic example is as follows:

```
function asyncActionCreator() {
  return function thunk({dispatch}) {
    setTimeout(function doLater() {
      // dispatch an action *later*
      dispatch({type: PING});
    }, 500);
  }
}
```

It should hopefully be relatively obvious how this would translate to doing something useful - going back to our example of fetching data how would we do that? Well we need some API Utils so let's just import them, right?

```
import api from 'api';

function fetchUser(id) {
  return function thunk({dispatch}) {
    api.fetch(`users/${id}`).then(function(resp) {
      dispatch({type: USER_LOADED, user: resp.data});
    });
  }
}
```

*Awesome!*

But... How do we test this? We're now going to need to mock our dependencies. Ugh! This is a clear sign that our once nicely-isolated testable function has broken it's bounds in terms of dependencies. If your 'api' contains state here as well you're in for a bumpy ride.

This is where some people cry "thunks are cool but don't scale!", "thunk's can't be tested easily!" etc. but I tend to disagree still.

> We missed one important detail of the thunk middleware which would've allowed us to keep our action creators totally isolated. The arguments.

The standard thunk-middleware just injects an object with two properties - `getState` and `dispatch`. That's great but why don't we inject *more*!

The thunk arguments provide the perfect point for injecting any outside dependencies in a manner you can test and isolate.

For example our `fetchUser` action creator will now look something more like this:

```
export function fetchUser(id) {
  return ({api, dispatch}) =>
    api.fetch(`users/${id}`).then(resp =>
      dispatch({action: FETCH_USER, user: resp.body.data}));
}
```

This function is now completely isolated and suddenly testing becomes *really* simple.

```
// And now testing is *super* easy - just inject away!
it ('should hit correct endpoint', () => {
  const api = createMockApi([
    {
      test: 'users/1',
      resp: {data: {id: 1, type: 'user', name: 'Chris'}}
    }
  ]);
  const store = createMockAppStore({api});
  
  store.dispatch(fetchUser(1));
  
  expect(api.fetch.firstCall.args[0]).toEqual('users/1');
  expect(store.dispatch.firstCall.args[0]).toEqual(
    {action: FETCH_USER, user: {id: 1, type: 'user', name: 'Chris'}}
  );
})
```

*You can find a more complete example of usage in [this gist](https://gist.github.com/Chrisui/750ee07f500df6355f2bcee96115b769).*

So now async thunk based action creators are easily testable and, providing you structure them correctly within the scope of your application (a topic for another time), they scale perfectly and are arguably more understandable, have less caveats and way less of an architectural restriction on the way you code than some of the other solutions out there.

At Kalo we've been using custom thunk middleware since we picked up redux and, removing a little churn, have found them to be incredibly powerful as a simple concept (much like Redux itself!) so don't throw away thunks too quickly - they go a long way!

If you enjoyed this post or it gave you some inspiration do [reach out to me on twitter](https://twitter.com/chrisui) and let me know so I can write more! :)

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Wrote a quick blog post on how we&#39;ve made Redux Thunks testable with &quot;one small trick&quot; <a href="https://t.co/OyqhKdr6JS">https://t.co/OyqhKdr6JS</a> <a href="https://twitter.com/hashtag/redux?src=hash">#redux</a> <a href="https://twitter.com/hashtag/reactjs?src=hash">#reactjs</a></p>&mdash; Chris Pearce (@Chrisui) <a href="https://twitter.com/Chrisui/status/719821823194566656">April 12, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

*Ps. I recently gave a talk on ["real world redux"](https://speakerdeck.com/chrisui/real-world-redux) if you're interested in finding out more about redux at scale in the wild!*