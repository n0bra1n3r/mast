discard """
action: "compile"
target: "c++"
"""

import std/macros

import mast, mast/macros as mastmacros
import utils

should "compile spread operator":
  template body() =
    echo "line 0"
    echo "line 1"
    echo "line 3"

  template astImpl() =
    proc test() =
      echo "line 0"
      echo "line 1"
      echo "line 3"

  let bodyAst = getAst body()

  let procAst = ast do:
    ProcDef:
      `test`
      Empty
      Empty
      FormalParams:
        Empty
      Empty
      Empty
      StmtList:
        (...bodyAst)

  let refAst = getAst astImpl()

  doAssert refAst == procAst

