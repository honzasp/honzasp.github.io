---
layout: page
title: Offline lab
menu: lab
---

The offline lab contains experiments that do not run in the browser environment.
These are usually less visual and more algorithmic and theoretic, but there is a
program with GUI and a game, too.

{: .repos }
- ### [Krunimír](https://github.com/honzasp/krunimir)

  This is an implementation of the task from the Czech Programming Competition
  in 2010. We were presented with the problem of implementing a simple
  procedural Logo-based programming language for generation of turtle
  graphics. Having won the competition thanks to my use of `eval`, I decided
  to solve the task once again, using proper compilation techniques.

  Input programs are parsed using
  [Treetop](https://github.com/nathansobo/treetop), a parser-generator library
  for Ruby. The resulting AST is then compiled into "bytecode", which is then
  interpreted by a&nbsp;stack-based virtual machine.

- ### [Inkvizitor](https://github.com/honzasp/inkvizitor)

  Inkvizitor is a simple program to manage lists of debtors. The killer
  feature is the ability to automatically export GPS coordinates corresponding
  to the people's addresses using [Google's
  Geocoding](https://developers.google.com/maps/documentation/geocoding/) API.
  It was my first larger program written in Haskell and using GUI with library
  [wxHaskell](http://www.haskell.org/haskellwiki/WxHaskell).
  

- ### [Ropucha](https://github.com/honzasp/ropucha)

  Ropucha is a programming language used to generate `.tsk` programs to control
  robots from the company Robotis. There is a pseudo-IDE available, which can be
  used to produce those programs, but the interface is graphical and the
  language quite primitive, so I created a simple (textual) programming language
  called Ropucha that transpiles to the `.tsk` format.  The transpiler is
  written in Ruby and was developed using [Cucumber](http://cukes.info) and
  [RSpec](http://rspec.info).  It is not very well-designed, but the translated
  language features high-level hardware access, advanced arithmetic, rich
  control structures and functions.  The language has slightly unusual syntax,
  as it is the only programming language I know that allows whitespace in
  identifiers.
  

- ### [Balloon watcher](https://github.com/honzasp/balloon_watcher)

  This is the application you would use if you wanted to hang a smartphone with
  Android to a balloon and let it fly. The app can take logs with information
  about position and phone state, send those logs via SMS so that you can track
  the balloon and take photos during the flight. It may also be controlled
  remotely using SMS messages.

  Unfortunately, the app never found its use in a real flight, since the plan
  with making and sending the balloon failed.
  
- ### [Totem destroyer](https://github.com/honzasp/totem_destroyer)

  A two-dimensional game written in C++ using [SDL](https://www.libsdl.org) with
  OpenGL for rendering, and [Box2D](https://box2d.org) for physics.  The player
  has to carefully destroy blocks from a totem, so that precious idols do not
  hit the ground. I made the game when I was 13 and was inspired by a similar
  Flash game.
  

- ### [Typing](https://github.com/honzasp/typing)

  Haskell implementations of some type-checkers from [Types and Programming
  Languages](http://www.cis.upenn.edu/~bcpierce/tapl/) by B. C. Pierce. The most
  advanced is System F<sub>&omega;</sub> with subtyping and many extensions,
  such as records and variants.
  
- ### [Radon](https://github.com/honzasp/radon) and [Zinc](https://github.com/honzasp/zinc)

  Implementations of two dynamic programming languages inspired by Lisp.  Radon
  is compiled into x86 assembler and runs with a small runtime written in C and
  assembly. Garbage collector is not yet implemented, so the programs can easily
  exhaust memory, and the code generator is quite naive.  The compiler itself is
  written in Rust.

  On the other hand, Zinc is an interpreter written in Haskell, but the features
  of the language are quite similar to Radon. The syntax is a bit nicer and it
  also supports writable variables.
