# Ghubvious

Ghubvious is the obvious implementation of an interactive "git status" for Neovim.

## Table of contents

- [General info](#general-info)
- [Technologies](#technologies)
- [Setup](#setup)

## General info

Ghubvious is a neovim plugin to make the "git status" command interactive via a floating window.

My goals for this plugin are the following:

 1. Quick commands on selected files (git add | restore | ignore | remove).
 1. Quick commands on the commits of a single file (Jump between versions, checkout).
 1. Integration with the gh cli.

![Gitstatus.lua demo](./demo/Gitstatus.gif)

## Technologies

This project is created with:

- Lua

I'd like to rely as little as possible on Vimscript.

## Guides and documentation

- [Neovim Lua documentation](https://neovim.io/doc/user/lua.html)
- [Git status documentation](https://git-scm.com/docs/git-status)
- [Luv documentation](https://github.com/luvit/luv/blob/master/docs.md)
- [Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)
- [Using LibUV in Neovim](https://teukka.tech/vimloop.html)
- [Lua guide by nanotee](https://github.com/nanotee/nvim-lua-guide#introduction)

## Depedencies

I plan to remove dependencies for this plugin to be fully standalone, but for
now, this project requires this other plugins to work:

- [neovim-remote](https://github.com/mhinz/neovim-remote)

## Setup

To run this project, install it using your favorite git plugin manager.
