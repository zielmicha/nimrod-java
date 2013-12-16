import strutils

proc classnameToId*(name: string): string =
  name.replace('/', '_').replace('$', '_').replace('.', '_').replace("__", "")

const nimrodKeywords = ["addr", "and", "as", "asm", "atomic", "bind", "block", "break", "case", "cast", "const", "continue", "converter", "discard", "distinct", "div", "do", "elif", "else", "end", "enum", "except", "export", "finally", "for", "from", "generic", "if", "import", "in", "include", "interface", "is", "isnot", "iterator", "lambda", "let", "macro", "method", "mixin", "mod", "nil", "not", "notin", "object", "of", "or", "out", "proc", "ptr", "raise", "ref", "return", "shared", "shl", "shr", "static", "template", "try", "tuple", "type", "var", "when", "while", "with", "without", "xor", "yield"]

proc mangleProcName*(name: string): string =
  if name in nimrodKeywords:
    return "j" & name
  else:
    return name
