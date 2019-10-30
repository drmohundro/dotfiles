# About dotfiles

This is my collection of various config files and options for programs like vim
or bash (heavy unix focus).

## Installation Instructions

I'm making use of symlinks to point my dotfiles to my actual dev folder - to
make it easier to configure this, I've based my Rakefile off of what I've seen
in many other dotfiles. To install, just run:

```sh
rake install
```

To double check your environment, you can run:

```sh
rake check
```

## Overrides

For platform-specific config, you can use the `overrides.yaml` file. See the
included version for details.

## Need help?

Visit my [website](http://mohundro.com/blog) and shoot me a line.

