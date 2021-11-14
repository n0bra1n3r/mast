import std/macros
import std/strformat

template lit*(value: string or Ordinal): NimNode =
  newLit value

template sym*(name: untyped{ident}): NimNode =
  bindSym astToStr name

macro sym*(name: untyped{nkAccQuoted}): NimNode =
  newCall(bindSym"bindSym", newLit strVal name[0])

macro sym*(kind: untyped{call}): NimNode =
  expectLen(kind, 1, 2)

  result = newCall(bindSym"genSym", ident "nsk" & strVal kind[0])

  if kind.len > 1:
    var repr: string
    for ident in kind[1]: repr &= strVal ident
    let ident = newCall(bindSym"fmt", newLit repr)
    result.add(ident)

proc astImpl(tree: NimNode): NimNode =
  case tree.kind:
  of nnkLiterals - {nnkNilLit}:
    result = newCall(bindSym"newLit", tree)
  of nnkIdent:
    if tree.eqIdent"true" or tree.eqIdent"false":
      result = newCall(bindSym"bindSym", newLit strVal tree)
    else:
      result = newCall(bindSym"newNimNode", ident "nnk" & strVal tree)
  of nnkAccQuoted:
    var repr: string
    for ident in tree: repr &= strVal ident
    result = newCall(bindSym"newIdentNode", newCall(bindSym"fmt", newLit repr))
  of {nnkCall, nnkCallStrLit, nnkCommand}:
    result = newCall(bindSym"newNimNode", ident "nnk" & strVal tree[0])

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
