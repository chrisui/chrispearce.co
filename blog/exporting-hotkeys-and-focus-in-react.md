*TLDR; Tracking 'focus' in web apps is difficult but React makes it easy by normalising the propagation of `onFocus` & `onBlur`. Taking advantage of this and some key binding gives us a new library [react-hotkeys](https://github.com/Chrisui/react-hotkeys) !*


One of the problems many developers face when developing non-trivial web apps is the implementation of hotkeys and focus management.

Natively browser environments only give us basic functionality for interacting with elements it deems 'in focus'. Browsers only have a concept of a *single* `activeElement` which is most commonly seen as an `input` or `a` element and therefore the `focus` event does *not* bubble.

> Quick Tip: You can make other elements (Ie. `div's`) receive the power of focus by setting the `tabindex` attribute on the element

This basic functionality allows you to respond to direct interaction on an individudal element level but misses the flexibility required for the simple propagating of events which is required for powerful hotkey management.

```
<div id="root">
	<input />
</div>

document.getElementById('root').addEventListener('focus', function() {
	// Never called
});
```

So, imagine you have this interface: You have a `Viewport` with child `Editor's` (they're just some forms for editing nodes within the `Viewport`) and within these you have an `AutoComplete` component which allows you to type out styles while being offered suggestions (think DevTools style editor).

The psuedo-react-tree would look a bit like:

```
<Viewport>
	<Editor>
    	<AutoComplete />
    </Editor>
    <Editor>
    	<AutoComplete />
    </Editor>
</Viewport>
```

Now, you're trying to use the browser focus handling, you focus on the `AutoComplete` input by clicking into it. The browser correctly lets you know that this is your focused element by triggering the `focus` event on the node and elsewhere probably triggering a `blur` event. Great! 

But...

You have a hot key, say `esc`, which you want to be able to close an `Editor` window. If your hotkeys are global, and you only know of the single focused `AutoComplete` how do you know which `Editor` you should be closing? Due to the non-bubbling nature of the `focus` and `blur` events your parents will have no idea when a child has been focused and is therefore in some indirect level of focus.

You'd have to traverse the tree from the `activeElement` until you find a component (`Editor`) which has a matching hotkey handler. And how can an element higher up the tree know when it is technically within the "focus tree" and so should allow hotkey triggering?

### Enter focusin

To solve the non-bubbling issues surrounding `focus` and `blur` events there is a [draft level spec](http://www.w3.org/TR/DOM-Level-3-Events/#event-type-focusIn) for `focusin` and `focusout` events which are identical to their respective `focus` and `blur` events except for the key difference that they *do* bubble.

As always with any upcoming spec there are many cross-browser issues surrounding them (Firefox doesn't implmenet them at all!) but there is is an [excelent article on quirksmode](http://www.quirksmode.org/blog/archives/2008/04/delegating_the.html) which explores how to try and workaround these issues and achieve the desired functionality across different browsers.

What we need is to reduce the boilerplate required and achieve a consistent cross-browser api which has 0 weird side effects.

### React to the rescue

Internally React has its own [Events System](https://facebook.github.io/react/docs/events.html) which handles [delegation](http://davidwalsh.name/event-delegate) of user events. When you bind an `onClick` handler onto an element in React it will actually just track that through a single global event handler at the root of your application and use its own method of propagating the events through your tree from the target element.

While the auto-delegation aspect of the events sytem is cool we're more interested in the custom propagation of events here.

Why is it so good? Well. **The `focus` event is bubbled by default! With 0 configuration or hacks we are able to bind `onFocus` handlers to our target focusable element *AND* to all its parents.**

This turns out to be a much more sensible default and allows for a lot more use-cases of 'focus'. If you have a specific  focusable target element you can simple `stopPropagation()` on the event to prevent the default bubbling behaviour.

### So... hotkeys?

With the ability to monitor the 'focus state' of particular elements (where the element may not neccassarily be a direct focus target but simply within the parent tree) it makes it very easy to bind contextual hotkeys.

And using @ccampbell's excelent [mousetrap](https://github.com/ccampbell/mousetrap) library we are able to declare our hotkeys with very inutitive syntax.

Combining all this you get **[react-hotkeys](https://github.com/Chrisui/react-hotkeys)** which provides a declarative way of binding hotkeys to your React application.

```
import {HotKeys} from 'react-hotkeys';

const keyMap = {
	'deleteNode': ['del', 'backspace'],
    'snapLeft': 'ctrl+left',
    ...
};

render() {
	const handlers = {
    	'deleteNode': this.deleteNode,
        'snapLeft': this.snap.bind(this, SNAP.LEFT),
        ...
    };
    
	return (
    	<HotKeys keyMap={keyMap} handlers={handlers} />
    )
}
```

The library aims to take the pain out of defining key mappings, knowing when certain components are 'in focus' and which hotkey handlers in the hierarchy should be called while providing a minimal API and getting out the way for the most part.

If you'd like to get hands on with react-hotkeys then it's probably best to start with the [getting-started](https://github.com/Chrisui/react-hotkeys/blob/master/docs/getting-started.md) guide!

I've put together my initial ideas for the full public API below so check it out and help me make focus and hotkeys easy for React users!

```
/**
 * Basic 1:1 mapping of named hot keys to their key combo
 * - All Mousetrap (https://github.com/ccampbell/mousetrap) 
 *   combos will be supported
 * - Named mappings to allow user customization flexibility
 */
const map = {
  'snapWindowLeft': 'command+shift+left',
  'floatWindow': 'command command',
  'konami': 'up up down down left right left right b a enter'
};

/**
 * The HotKeys component here creates the root focus point
 * and accepts a hotkey map which will also be made available
 * to all HotKey focus points below in the tree via context
 * - Multiple maps can be passed at different levels of the 
 *   focus tree. They are resolved with a simple merge (dw
 *   the higher map will not be mutated!)
 * - The use of a HotKeys/FocusTrap component will always give
 *   us an extra dom element wrapping our content but this should
 *   not be an issue. Sadly we need this to catch appropiate
 *   events to determine 'focus'. In most cases it's quite useful
 *   as you tend to use HotKeys where you would have a containing
 *   element anyway.
 *   - You can define a component other than the default 'div'
 *   - All props will be forwarded to this so it is flexible
 *     in styling
 *   - Maybe a HotKeys HoC (Higher-order Component) should also
 *     be made available? Would help people avoid the 'extra div'
 *     issue
 */
const App = React.createClass({
  render() {
    return (
      <HotKeys map={map}>
        <WorkSpace>
          <Toolbar />
          <Viewport />
          <NodeEditor />
          <StatusBar />
        </WorkSpace>
      </HotKeys>
    );
  }
});

/**
 * Bindings can then be made on a HotKeys component using the
 * named patterns we declared above.
 * - Internally we track the focus state of all FocusTrap's which
 *   gives us a FocusTree. We can then use this to check whether we
 *   should call the appropiate handler if the component is in focus.
 * - Handler priority works from the bottom up
 *   - If a focused component has handled a hotkey further down in the
 *     tree then we simply do not continue traversing as you would only
 *     expect one action handler per hotkey event
 */
const Workspace = React.createClass({
  render() {
    const bindings = {
      'snapWindowLeft': this.snapFocusedWindow.bind(this, SNAP.LEFT),
      'floatWindow': this.floatFocusedWindow
    };

    return (
      <HotKeys bindings={bindings}>
        {this.props.children}
      </HotKeys>
    );
  }
});

/**
 * We can use FocusTrap (of which HotKeys is a composite layer) if 
 * at some point we just want to see if a particular component is
 * within the active focus tree
 *
 * focusName (this is uniquely generated for internal use if not set)
 * allows us to programatically set focused areas as well as monitor 
 * what is being focused from lower down the tree
 */
const NodeEditor = React.createClass({
  render() {
    return (
      <FocusTrap
      	focusName="nodeEditor"
      	onFocus={this.onFocus}
      	onBlur={this.onBlur}
      >
        <Form>
          <AutoComplete name="nodeType" />
        </Form>
      </FocusTrap>
    );
  }
});

/**
 * If the key used in a bindings object is not found on the context
 * key map then it is assumed to be an explicit key sequence
 */
const AutoComplete = React.createClass({
  render() {
    const bindings = {
      'up': this.shiftSelection.bind(this, SHIFT.UP),
      'return': this.confirmSelection
    };

    return (
      <Hotkeys bindings={bindings}>
        <input type="text" />
        <Dropdown />
      </Hotkeys>
    );
  }
});

React.render(<App />, document.body);

```