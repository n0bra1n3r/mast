discard """
action: "compile"
target: "c++"
"""

import std/macros

import mast
import utils

should "bind symbol":
  doAssert bindSym"false" == sym`false`

should "generate symbol":
  doAssert nnkSym == kind sym Proc`test`

should "generate literals":
  doAssert newLit("test") == lit"test"
  doAssert newLit(1) == lit 1

should "produce identifier":
  doAssert ident"test" == ast`test`

should "interpolate identifier name":
  let i = 1
  doAssert ident"test1" == ast`test{i}`

should "embed variable into ast":
  let someLit = "iamastring"
  doAssert newLit("iamastring") == ast (lit someLit)

should "produce correct AST for typical proc":
  template astImpl() {.dirty.} =
    proc test() =
      var pt: ptr[int] = nil
      var val = 1

      pt = (addr)val

      when true:
        if not isNil(pt):
          echo "value is: ", pt[]

  let refAst = getAst astImpl()

  let mastAst = ast do:
    ProcDef:
      `test`
      Empty
      Empty
      FormalParams:
        Empty
      Empty
      Empty
      StmtList:
        VarSection:
          IdentDefs:
            `pt`
            PtrTy:
              Bracket:
                `int`
            NilLit
        VarSection:
          IdentDefs:
            `val`
            Empty
            1
        Asgn:
          `pt`
          Command:
            Par:
              `addr`
            `val`
        WhenStmt:
          ElifBranch:
            `true`
            StmtList:
              IfStmt:
                ElifBranch:
                  Prefix:
                    `not`
                    Call:
                      `isNil`
                      `pt`
                  StmtList:
                    Command:
                      `echo`
                      "value is: "
                      BracketExpr:
                        `pt`

  doAssert refAst == mastAst
