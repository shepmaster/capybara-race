This example application highlights a race condition between Capybara
1.1.2, Selenium, and JavaScript that removes elements from the DOM.

## Reproduction steps

1. Download this repository
2. Install gems with `bundle`
3. Run `rspec`

## Description

*Disclaimer: This is my current best guess and understanding of what
is happening. I could be very wrong!*

The `:text` matcher in Capybara works by first finding all the nodes
that match the CSS/XPath selector, then selecting nodes that match the
`:text` condition. This happens in the [`all` method][all].

When using Selenium, the node returned during the finding phase
contains a reference back to the original DOM element. When checking
the text of the element, the DOM element is referenced again.

The race condition occurs with the following sequence of events:

1. Some JavaScript starts running.
2. Capybara / Selenium grabs an element matching the selector from the DOM.
3. The JavaScript finally removes the element from the DOM.
4. Capybara asks for the text content of the element.
5. Selenium can no longer find the element, and throws an exception.

```
Selenium::WebDriver::Error::StaleElementReferenceError:
  Element not found in the cache - perhaps the page has changed since it was looked up
```

## Example details

To highlight the issue and make it more reproducible, I've added some
`sleep`s to the example JavaScript as well as Capybara. These delays
should have no effect on the functionality of either piece of code,
they just emulate a slow machine or unlucky timing.

The [example application][app] has a link that removes an element from
the DOM after a delay of one second. All the interesting behavior
occurs in the static file `index.html`; Rails was simply an easy way
to get all the pieces working together.

The example application uses a [custom version][capybara-sleep] of
Capybara based on the 1.1.2 release. This version has a `sleep` of two
seconds added between the first and second phases of the `all` method.

Timeouts of 100 and 200ms, respectively, also reproduce the
error. Lower values do not reliably reproduce the error.

## Environment information

### Ruby version
ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-darwin11.4.2]

### Hardware
MacBook Pro, 2.3 GHz Intel Core i7, 16 GB RAM, SSD

### Operating system
OS X 10.8.2

[all]: https://github.com/jnicklas/capybara/blob/1.1_stable/lib/capybara/node/finders.rb#L109
[app]: https://github.com/shepmaster/capybara-race/blob/master/public/index.html
[capybara-sleep]: https://github.com/shepmaster/capybara/commit/8e5d8d5d72d2c1e2740188980c3ed6a3c353e667
