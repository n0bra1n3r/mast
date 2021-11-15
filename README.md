# mast

![Testing](https://github.com/n0bra1n3r/mast/actions/workflows/test.yml/badge.svg)

A simple DSL for defining abstract syntax trees in [Nim](https://nim-lang.org/).

This project was directly inspired by the [breeze](https://github.com/alehander92/breeze)
library.

## Overview

This library provides another way to write Nim [macros](https://nim-lang.org/docs/macros.html)
more closely following the output of [`treeRepr`](https://nim-lang.org/docs/macros.html#treeRepr%2CNimNode).

## Showcase

Please **see [tests](tests/)** for examples of most features. This section
provides an incomplete summary of the core functionality.

### Basic example

The following is an example usage:

```nim
import mast

macro makeMain(body: untyped) =
  ast:
    ProcDef:
      `main`
      Empty
      Empty
      FormalParams:
        Empty
      Empty
      Empty
      (body)

makeMain:
  echo "Hello world!"
```

```nim
# `makeMain` expands to:
proc main() =
  echo "Hello world!"
```

Notice that most elements in the AST definition correspond to their `nnk*`
[NimNode](https://nim-lang.org/docs/macros.html#NimNodeKind) counterparts.
Exceptions to this pattern are the following:

* Identifiers which are enclosed in backticks ("`")
* Literals which are simply specified in the AST definition as-is
* External expressions which are embedded in the AST by enclosing them in
parentheses

### Identifiers

Under the hood mast uses the [`fmt`](https://nim-lang.org/docs/strformat.html#fmt.m%2Cstaticstring%2Cstaticchar%2Cstaticchar)
macro to parse identifier names. This means that identifier names can be
composed using the following syntax:

```nim
let i = 1
let newIdent = ast`ident{i}` # generates `Ident "ident1"`
```

Bound symbols can be specified by using the `sym` macro:

```nim
let boundSym = ast (sym someDeclaredSymbol)
```

Lastly, new symbols can be generated using the following syntax:

```nim
let genSymed = ast (sym Proc`someProcSymbol`)
```

The `Proc` symbol here corresponds to [`nskProc`](https://nim-lang.org/docs/macros.html#NimSymKind),
and the symbol inside the backticks can be interpolated in the same way as
identifiers.

## Installing

The package can be installed by following the nimble instructions
[here](https://github.com/nim-lang/nimble#nimble-install).

## Usage

Simply import mast into your module to start using it.

## Contributing

This project is maintained during my free time, and serves as a tool for a game
engine I am writing after work hours. Contributions are welcome, and I will
merge them immediately if they serve to keep the project robust, simple, and
maintainable.

**Cheers and happy coding!** 🍺
