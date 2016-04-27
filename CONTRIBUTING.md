# Contributing

I love pull requests. I'm trying to keep it as easy as possible to contribute changes. There
are just a couple of guidelines to follow to help me stay on top of things.


## Let's talk

Whether you're fixing a bug or adding a feature, feel free to talk to me first on 
[twitter](https://twitter.com/JustinTomich). We can make sure the change isn't already
underway somewhere else.


## Getting started

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Open a [New Issue](https://github.com/tomichj/authenticate/issues) on github for your change, 
assuming one does not already exist. If one already exists, join the conversation.
* Fork the repository on GitHub.

## Setup

Clone the repo:

`git clone https://github.com/<your-username>/authenticate`

CD into your clone and run bundler install:

`cd authenticate && bundle install`

Make sure the tests pass:
 
`rake`

Make your change. Add tests for your change. Make sure the tests pass:

`rake`

I use `rubocop` to maintain ruby coding style. Install and run it like so:

```sh
gem install rubocop
rubocop
```

Once you resolve any issues rubocop finds, you're ready to go. Push your fork and 
[submit a pull request](https://github.com/tomichj/authenticate/compare/).

The ball is now in my court. I'll try to comment on your pull request within a couple of business days 
(hopefully the same day).
  
Things you can do to increase the speed of acceptance:
 
* talk to me ahead of time
* write tests
* follow the [ruby style guide](https://github.com/bbatsov/ruby-style-guide)
* write a good [commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
 
Thanks very much!
