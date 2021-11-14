import std/macros
import std/strformat

template lit*(value: string or Ordinal): NimNode =
  newLit value

template sym*(name: untyped{ident}): NimNode =
  bindSym astToStr name

macro sym*(name: untyped{nkAccQuoted}): NimNode =
  newCall(bindSym"bindSym", newLit strVal name[0])

macro errorNimSymKind(kind, node: untyped) =
  error("invalid Nim symbol kind: " & kind.repr, node)

template checkedNimSymKind(kind, node: untyped): NimSymKind =
  when not compiles(NimSymKind.`nsk kind`):
    errorNimSymKind(kind, node)
  else:
    NimSymKind.`nsk kind`

macro sym*(kind: untyped{call}): NimNode =
  expectLen(kind, 1, 2)

  let repr = strVal kind[0]
  result = newCall(bindSym"genSym",
    newCall(bindSym"checkedNimSymKind", ident repr, kind[0]))

  if kind.len > 1:
    var repr: string
    for ident in kind[1]: repr &= strVal ident
    let ident = newCall(bindSym"fmt", newLit repr)
    result.add(ident)

macro errorNimNodeKind(kind, node: untyped) =
  error("invalid Nim node kind: " & kind.repr, node)

template checkedNimNodeKind(kind, node: untyped): NimNodeKind =
  when not compiles(NimNodeKind.`nnk kind`):
    errorNimNodeKind(kind, node)
  else:
    NimNodeKind.`nnk kind`

proc astImpl(tree: NimNode): NimNode =
  case tree.kind:
  of nnkLiterals - {nnkNilLit}:
    result = newCall(bindSym"newLit", tree)
  of nnkIdent:
    if tree.eqIdent"true" or tree.eqIdent"false":
      result = newCall(bindSym"bindSym", newLit strVal tree)
    else:
      let repr = strVal tree
      result = newCall(bindSym"newNimNode",
        newCall(bindSym"checkedNimNodeKind", ident repr, tree))
  of nnkAccQuoted:
    var repr: string
    for ident in tree: repr &= strVal ident
    result = newCall(bindSym"newIdentNode", newCall(bindSym"fmt", newLit repr))
  of {nnkCall, nnkCallStrLit, nnkCommand}:
    let repr = strVal tree[0]
    result = newCall(bindSym"newNimNode",
      newCall(bindSym"checkedNimNodeKind", ident repr, tree))

    if tree.len > 1:
      if tree[1].kind == nnkStmtList:
        for node in tree[1]:
          result = newCall(bindSym"add", result, astImpl node)
      else:
        for node in tree[1..^1]:
          result = newCall(bindSym"add", result, astImpl node)
  of nnkStmtList:
    result = newNimNode nnkStmtList

    for node in tree:
      result.add(astImpl node)
  of nnkPar:
    result = tree[0]
  else:
    error("invalid AST: " & tree.repr, tree)

macro ast*(tree: untyped): NimNode =
  astImpl tree
