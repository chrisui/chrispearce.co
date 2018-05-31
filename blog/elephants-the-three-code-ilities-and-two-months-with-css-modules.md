“Move fast and break things” is what they said.

Over at [Kalo](http://kalohq.com/) we are definitely moving *fast*. In only two months we have gone from having nothing but a feature list and early designs to having two beautiful, component-sharing, fully functional apps built and shipping to companies such as Google, Twitter & Apple.

## The Three Ilities

While moving fast feels great (and *is*, of course, great) it can very easily (and more often than not) come back to haunt you if you do not approach it correctly. The problem, of course, are the “Three Code Ilities” - maintability, scalability and stability. These are all needed to maintain efficiency and sanity in the long run allowing us developers to do our jobs and develop features within a 0-friction environment.

When moving fast these can become seriously comprompised as we tend to cut corners, make hacks and even have to make sacrifices to code quality in some areas.

> This is not because we are *bad* developers but because we are humans with a job to do, deadlines to hit and dependants we want to satisfy.

Unless you are writing a throw-away application it is important to choose the *right* corners to cut, isolate the hacks and, probably most importantly, have *good infrastructure*. Making sure the tools we are working with day-to-day is vital to allowing everyone to maintain their work velocity over a prolonged period. Facebook realised this and [changed their motto](http://mashable.com/2014/04/30/facebooks-new-mantra-move-fast-with-stability/) to (the now much less catchy) “Move fast with good infra”.

I could spend an age discussing strategies on how to develop quickly and maintain the “three code ilities” but today I just want to focus on infrastructure and on one piece in particular...

## The Elephant

Take the hacks and cut corners away while moving fast, you will find CSS is *still* a nightmare to work on as applications scale. I won’t repeat what has been said a million times before so let’s just remind ourselves of that *one* slide from that [*one* presentation](http://blog.vjeux.com/2014/javascript/react-css-in-js-nationjs.html).

![Problems with CSS at scale](http://i.imgur.com/6C374Em.png)

> CSS was an Elephant and I’m glad we’ve addressed it.

At first CSS is lovely. And it's incredibly sastisfying how quick and easy you can write your first styles and make some really good looking components. If you&rsquo;ve been developing on the web for a while I bet you can still remember the first time you used CSS to render rounded corners... mmm.

However...

![Writing CSS at scale](http://i.imgur.com/je1ZJSc.gif)

> Over time we just keep adding and adding things to the codebase. All in one namespace. This is like scaling vertically over horizontally which works but only upto a point.

The visual states get more complex and more and more people get their hands on it - it just begins to spiral and becomes that area nobody wants to touch.

> “As most companies grow, they slow down too much because they’re more afraid of making mistakes than they are of losing opportunities by moving too slowly.” - Mark Zuckerberg

On large codebases I was certainly afraid of touching the CSS and I was beyond fed up of writing verbose BEM class names to tip-toe around the fundamental problem of CSS.

## Enter CSS Modules

To remedy these problems and allow us to move at an electric pace we took the early decision to implement and use the rather new and shiny CSS Modules pattern.

The fundamental of CSS Modules is simply having localised classes over all classes being shared in a global namespace. Ie. If two components use the class name `.active` their rules will not clash. This seems like a very trivial thing but it makes us think about our styles in new ways which I hope to demonstrate.

If you, for some reason, haven’t heard of or just not had time to read up on CSS Modules yet I strongly recommend you go and read the [introductory blog post](http://glenmaddern.com/articles/css-modules) by Glen Maddern (one of the original creators) to understand it’s core principles and the problems it specifically sets out to solve.

Since it was very early days for the pattern it could be seen as a bit of a punt to implement it as the fundamental ground work into what is going to become a large enterprise platform but after two months...

> I can now confirm CSS Modules has been a huge success and we are finally  ~~enjoying~~ **loving** CSS again

Below I will try to document our experience with CSS Modules. The areas it has helped improve and the decisions we have had to make to get us writing styles without a worry in the world.

*Disclaimer: The team has consisted of 4 developers working on 2 applications spanning hundreds of components working with CSS Modules every day for 2 months.*

### Setup

If you’re using webpack and React, like we are, you can literally start using CSS Modules in the time it takes you to install the loader and import a stylesheet.

If you haven’t seen already then once you are setup you will be able to import your styles as object literals where the key are the class names you defined in your CSS file.

```
// styles.css
.content {
  color: black;
  padding: 5px;
}

// component.js
import styles from './styles.css'

render() {
  return (
    <div className={styles.content}>Hello World!</div>
  )
}
```

If you are already using React or some other JS templating solution there is pretty much no syntax (or other) overhead to direct referencing your styles this way and in our experience having the explicit import and use has made writing and maintaining drastically quicker.

> You are following explicit directions to your source rather than seeing an implicit class name and having to mentally figure out where it *might* be. The explicit usage shows you *it is right **here!***

Since getting installed 2 months ago we haven’t had to fiddle with the configuration at all with the ine exception to optimize the outputted class names during development for easy debugging. For this we arrived at `localIdentName=[name]__[local]___[hash:base64:5]` which lets us quickly see which component and class name we are working with and maintains uniqueness with the hash (although we should never actually have clashing component names!).

### “Everything is a Component”

When writing CSS as localized modules you will really need to get into the mindset of thinking of everything as small individual components. If you’ve been developing with React or even using BEM the chances are you’re already working with this mindset and so the transition to forcing components into a localized state should be trivial.

Having these localized components provides a *huge* mental win now that we no longer have to even think about other components. We can focus purely on the component in front of us which helps us focus and work much more efficiently. We go back to having a small isolated piece of code we can work on free from outside restrictions. Thinking of each component as a mini app we go back to the scale at which CSS was fun again!

This is the difference between writing a stateless function or a mutable class (which I explore more later).

The biggest leap we at [Kalo](https://kalohq.com/) found was getting over the inability to target a child component from within a containing component. For example you couldn’t expect to do something like this:

```
// Override child component styles from parent component
// Where our `button` and `buttonGroup` are *supposed* to
// be separate components
.buttonGroup .button {
  padding: 5px;
}
```

Now, this is somewhat of an anti-pattern in itself as it took away from the encapsulation of individual components which just do their thing but the ease of targeting selectors in CSS meant we could target these specific compositions easily and override styles from a parent component.

Instead of doing this we should instead be moving this customization of the child to the child’s API itself. Ie. In the above example the child component would expose a modifier. Eg. `padded` which we could then use when initializing our component.

I’ve included a React example below to see how this actually works.

```
<ButtonGroup>
  <Button padded={true} />
</ButtonGroup>
// or ButtonGroup can be made to pass the `padded`
// prop implicitly by mapping it’s children
```

### Style Purity

Component encapsulation lets us develop CSS with the wind in our hair and peace-of-mind. I’m no longer wasting time thinking about how to avoid name clashes, worrying about specificity issues or having nightmares over how changing that one selector might break my styles but I’m just concerned with how my component looks and how the public interface appears.

This encapsulation and forced component scope ensures we can develop our styles in *complete* isolation and therefore making our styles *pure*. From functional programming we have learned of the great benefits surrounding purity and lack of side-effects so having this insurance on our component styles is a huge win for testability and peace-of-mind when developing.

> I am no longer writing a mutable class. I am writing a function!

Now that I have my pure function it is incredibly easy to whip out a few test fixtures for my component et voila, sanity (and no nightmares).

### Customization

As discussed in the “everything is a component” section we have seen that we lose the ability to target children and override styles which limits the level of customization we can achieve directly from our CSS file.

Customization therefore becomes a case of either expanding your component API or creating new components which compose your base components. So far we have found no concrete rule on when to choose one pattern over the other but have preferred to simply expand a component’s API before creating a new component as at least in the mid term we will not have to go looking in too many different places.

On that note - when moving fast and expecting to maintain a codebase for a long time in the future it is easier to keep functionality in one place which can be later extracted than it is to do the reverse. That as well as you never want code to be too fragmented *before* you need it (we, as developers, often have a tendancy to over-abstract too early rather than build things and watch the patterns emerge themselves to easily see the most effective abstraction).

> Tip: As a good example of composability, ease-of-use and familiarity we have created `H1`, `H2` and `H3` components which all simply compose the base `Heading` component.

### Style Normalization

You will still want your `normalize.css` stylesheet to sit at the top of your application’s component hierarchy, that is for sure.

In our experience we have found this is the *only* stylesheet which will ever target tags globally. You can create localised components for *everything* - even for all our typography we have created `Text` and `Heading` components for re-use which has not shown any downsides thus far.

### Composition and DRY

The CSS Modules spec supports a `composes` keyword which gives you *sort of* extend-like functionality.

```
.button {
  composes: .default from "typography.css";
}
```

While I can imagine this is helpful for non-React developers we have found it basically redundant in our React application as we can already very easily compose our React components and therefore there is no need for composing the underlying styles. *(Note if anyone has found any applicable uses for this in React please give me a shout and I can update this!)*

Currently you will also need to implement some way to share your common variables to avoid hard-coding any values in your CSS rules. I'd advise using a [POSTCSS](https://github.com/postcss/postcss) plugin for this (there's a load so you can choose one to fit your team's preference!). There are discussions at the moment however revolving around bringing a [constant syntax](https://github.com/css-modules/css-modules-loader-core/pull/28) into CSS Modules which are shaping up rather nicely!

*On the subject of keeping code DRY I would like to highlight the fantastic talk (just 25 mins) by Sebastian Markbage on [“Learning patterns instead of frameworks”](http://2014.jsconf.eu/speakers/sebastian-markbage-minimal-api-surface-area-learning-patterns-instead-of-frameworks.html) which has inspired our approach to moving quickly in a maintainable fashion greatly. The premise of this being not to over-abstract too early and create too many fragmented pieces within your stack.*

###Interopable component styles at scale

A component’s styles should only be concerned with styling that component and not have any side-effects on sibling components. Right? It seems strange then that we add a property such as `margin` to our styles which have the side effect of shifting components.

Why should our `.heading` component be pushing sibling components away? What happens we have two `.button` components together and we need spacing? What happens when we have a `.button` component proceeding an `.input` component and want spacing?

Traditionally we had the power to go in and work with side-effect selectors such as `.button + .input` or `.heading + .paragraph` which would target certain sequences of components. This, combined with us usually putting default spacing around all kinds of components, meant we had side-effects everywhere and meant our component styles were no longer responsible for *just one* thing but when using them we had to account for how they would affect other components. This works for a while but then grows out of control as you re-use components everywhere and want unique control over layout and spacing in various containers.

In our opinion for the best, CSS Modules removes the ability to do this kind of targeting due to the local scope.

We still haven’t found the perfect solution but we have started working on a few things.

1. Firstly *no* component should ever emit any spacing side-effect style such as a `margin` by default. We can instead (if appropiate) expose a generic, well-defined & explicit API for control of such styles at the component initialization time (this is when you know all about surrounding components and can lay out accordingly).
2. Provide generic layout components which wrap children with an extra component of which it’s sole purpose is to position it’s children accordingly. For example we have a `List` component which wraps all children with a `ListItem` component which solely emits spacing (`margin`) styles. There is a well-defined API to control the styles which has the added benefit of providing consistency across our app.

*Would really love to hear some opinions, ideas & thoughts around this stuff in particular! [@Chrisui](http://twitter.com/chrisui)*

###Naming

With typical global CSS naming is *super* important. If you don’t choose a good standard early on or even begin to deviate slightly somewhere (it happens when you’re up against the wall and moving quickly - that’s reality!) then you will quickly lose control.

Obviously, with CSS Modules, there is less of an emphasis on getting naming *perfect* as names are only local to the component you are developing. This said you still shouldn’t be having multiple developers going off doing their own thing all at once as consistency is helpful for maintainability and getting new developers onboarded and working quickly.

> At [Kalo](http://kalohq.com) we’ve approached this as we have everything else with a “minimum standard, get stuff done and watch patterns emerge” approach.

The idea there is that you:

1. Construct a minimum standard which prevents any wild deviations - and being minimal it is quick and doesn’t restrict too much creative thinking 
2. Get developing and ensure open code reviews - which prevents people doing anything crazy and allows for transparency and discussion to occur
3. Watch and you will see the good patterns emerge and live and the bad patterns die as developers try slightly different things.

###CSS Modules Quick Tips

A few final quick tips:

- Keep CSS files next to the relevant component/template for easy navigation.
  - *Every* component in our codebase is a self-contained directory containing the component [button.jsx], component styles [button.css], tests [button-test.jsx] and an index [index.js] for less verbose imports.
- If using React and `classnames` dependency implement an `.undefined !important` class during development which will catch any mis-used style names.

## Conclusion

In short I have loved CSS Modules and how it is encouraging me to write my styles. We spend less time fixing bugs, write styles more quickly and just generally feel better about our codebase which is massively important!

> The biggest win from using CSS Modules is *not* simply having localised CSS files but the patterns it encourages us to use.

I have likened it to my experience with React which has, quite simply, transformed how I think about and develop UI’s.

All in all CSS Modules has provided us with a sane piece of infrastructure around styling which will allow us to move forward without any deacceleration of development in the long-term.



In terms of the three ilities:

- **Maintainability** - Strong component encapsulation means it is easy to locate where to make changes and doesn’t require external contextual thought.
- **Scalability** - Pure component and style architecture means infinite developers can work on infinite components atomically. 
- **Stability** - Pure styles makes testing easy and breaking things difficult.

<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">Just published &quot;Elephants, The Three Code Ilities and 2 months with CSS Modules&quot; <a href="http://t.co/FmVVJ6rsQW">http://t.co/FmVVJ6rsQW</a> <a href="https://twitter.com/hashtag/CSS?src=hash">#CSS</a> <a href="https://twitter.com/hashtag/webdev?src=hash">#webdev</a> <a href="https://twitter.com/hashtag/reactjs?src=hash">#reactjs</a></p>&mdash; Chris Pearce (@Chrisui) <a href="https://twitter.com/Chrisui/status/644172667352948736">September 16, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

**Feel free to follow and give me a shout on Twitter [@Chrisui](http://twitter.com/chrisui) for whatever reason! :)**