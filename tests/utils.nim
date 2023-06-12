template should*(description: static string, body: untyped) =
  macro test() {.genSym.} = body
  test()

