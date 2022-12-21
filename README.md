# About dotfiles

This is my collection of various config files and options for programs like vim
or fish (heavy unix focus).

## Installation Instructions

I'm making use of symlinks to point my dotfiles to my actual dev folder - to
make it easier to configure this, I'm using a PowerShell Core (pwsh) script. To
install, just run:

```sh
pwsh install.ps1
```

To double check what will happen, you can run:

```sh
pwsh check.ps1 -whatIf
```

## Overrides

For platform-specific config, you can use the `overrides.json` file. See the
included version for details.

## NeoVim Specifics

Recommended to also have:

- luarocks
- luacheck

## Need help?

Open an issue or visit my [website](https://mohundro.com/) and shoot me a line.
