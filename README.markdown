# About dotfiles

This is my collection of various config files and options for programs like vim or bash (heavy unix focus).

## Installation Instructions

I'm making use of symlinks to point my dotfiles to my actual dev folder - to make it easier to configure this, I've based my Rakefile off of what I've seen in many other dotfiles. To install, just run:

    rake install

I also use submodules and pathogen to track various vim bundles so you'll likely need to run these commands as well:

    git submodule init
    git submodule update

## Need help?

Visit my [website](http://mohundro.com/blog) and shoot me a line.
