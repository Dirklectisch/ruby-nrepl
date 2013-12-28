# ruby-nREPL #

The Clojure network REPL is a REPL build using a client-server architecture. It is specifically build so that it is easy to extend with new clients that can be used in other (non Clojure environments). Ruby-nREPL is such a client written in ruby. It can be used to communicate with a Clojure nREPL server instance programmatically from Ruby.

It is NOT an alternative REPL implementation for Ruby or a replacement for Ruby's irb. My main goal with this library is enabling support for Clojure in Ruby based development tools such as Textmate.

## Alternatives ##

There are many different nREPL clients the main ones are listed in the Clojure nREPL Readme. My advice is to use any one of those if it fits your needs, they are without exception more mature clients.

If you need Ruby client there are also several alternatives. Most of them didn't fit my taste for several reasons:

- More external dependencies that are not really necessary.
- Dirty implementation when retrieving messages from the socket.

One other difference is that ruby-nREPL is written in more idiomatic Ruby which allows for cleaner composition. A trade off when using this library is that it requires Ruby 2.X or above at  the moment because of its use of lazy enumerators.

## Installation ##

I will package this as a Ruby gem once I feel it is stable enough to be used by others. But if you really want to try it now it is good to know that it depends on Ruby 2.X and one external gem ruby-bencode.

## Example ##

Examples to follow later.

## Documentation ##

Link to the docs once they are written.

## Contribution guidelines ##

Tell me how I can help out including wanted features and code standards.

## Contributor list ##

- Dirk Geurs

