import std/macros

export macros except
  name,
  pragma,
  `pragma=`

proc name*(node: NimNode): NimNode =
  expectKind node: RoutineNodes + {nnkIdentDefs, nnkTypeDef}
  case node.kind
  of nnkIdentDefs, nnkTypeDef:
    result = node[0]
    if result.kind == nnkPragmaExpr:
      result = result[0]
    if result.kind == nnkPostfix:
      if result[1].kind == nnkAccQuoted:
        result = result[1][0]
      else:
        result = result[1]
    elif result.kind == nnkAccQuoted:
      result = result[0]
  else:
    result = macros.name(node)

proc pragma*(node: NimNode): NimNode =
  expectKind node: RoutineNodes + {nnkIdentDefs, nnkTypeDef, nnkProcTy}
  case node.kind
  of nnkIdentDefs, nnkTypeDef:
    if node[0].kind == nnkPragmaExpr:
      result = node[0][1]
  else:
    result = macros.pragma(node)

proc `pragma=`*(node, pragma: NimNode) =
  expectKind node: RoutineNodes + {nnkIdentDefs, nnkTypeDef, nnkProcTy}
  expectKind pragma: nnkPragma
  case node.kind
  of nnkIdentDefs, nnkTypeDef:
    if node[0].kind == nnkPragmaExpr:
      node[0][1] = pragma
    else:
      node[0] = nnkPragmaExpr.newTree(node[0], pragma)
  else:
    macros.`pragma=`(node, pragma)

proc ofInherit*(node: NimNode): NimNode =
  expectKind node: nnkTypeDef
  expectKind node[2]: nnkObjectTy
  result = node[2][1]

proc `ofInherit=`*(node: NimNode, ofInheritNode: NimNode) =
  expectKind node: nnkTypeDef
  expectKind node[2]: nnkObjectTy
  expectKind ofInheritNode: nnkOfInherit
  node[2][1] = ofInheritNode
