using peg

class GrammarTest : Test
{
  private static const Grammar grammar := Grammar.fromStr(GrammarTest#.pod.file(`/res/ecl-grammar.peg`).readAllStr)
  
  Void testSingleCommand() {
    text := "get-log"
    blocks := Parser.list(grammar, text.toBuf)
    verifyEq(["get-log"], getCommands(blocks, text))
    
    text = "get-log  "
    blocks = Parser.list(grammar, text.toBuf)
    verifyEq(["get-log"], getCommands(blocks, text))
    
    text = "get-log  \t\t"
    blocks = Parser.list(grammar, text.toBuf)
    verifyEq(["get-log"], getCommands(blocks, text))
  }
  
  Void testPipe() {
    text := "get-log | print"
    blocks := Parser.list(grammar, text.toBuf)
    verifyEq(["get-log", "print"], getCommands(blocks, text))
    
    text = "get-log| print"
    blocks = Parser.list(grammar, text.toBuf)
    verifyEq(["get-log", "print"], getCommands(blocks, text))
    
    text = "get-log |print"
    blocks = Parser.list(grammar, text.toBuf)
    verifyEq(["get-log", "print"], getCommands(blocks, text))
  }
  
  private Str[] getCommands(Block[] blocks, Str text) {
    ret := Str[,]
    blocks.each { 
      if (it.name.equals("CommandName")) {
        ret.add(text[it.range])
      }
    }
    return ret
  }
  
  Void testNamedArgs() {
    verifyNamedArgs("get-log -limit 10 -skipInfo true", ["-limit" : "10", "-skipInfo" : "true"])
    verifyNamedArgs("get-log -limit 10 -skipInfo", ["-limit" : "10", "-skipInfo" : ""])
    verifyNamedArgs("get-log -limit -skipInfo", ["-limit" : "", "-skipInfo" : ""])
    verifyNamedArgs("get-log -skipInfo -limit 10", ["-limit" : "10", "-skipInfo" : ""])
    
    verifyNamedArgs("get-by-os -default \"Window/Preferences\" -macosx \"Eclipse/Preferences\"", 
      ["-default" : "\"Window/Preferences\"", "-macosx" : "\"Eclipse/Preferences\""])
  }
  
  private Void verifyNamedArgs(Str text, Str:Str args) {
    blocks := Parser.list(grammar, text.toBuf)
    name := ""
    foundArgs := Str[,]
    blocks.each {
      if (it.name.equals("ArgName")) {
        if (!name.isEmpty) {
          verifyArg(args, name, "", foundArgs)          
        }
        name = text[it.range]
      }
      if (it.name.equals("ArgValue")) {
        verifyArg(args, name, text[it.range], foundArgs)
        name = ""
      }
    }
    if (!name.isEmpty) {
      verifyArg(args, name, "", foundArgs)
    }
    args.keys.each { 
      if (!foundArgs.contains(it)) {
        verify(false, "Argument not found: " + it)
      }
    }
  }
  
  private Void verifyArg(Str:Str args, Str name, Str value, Str[] foundArgs) {
    verifyEq(args[name], value)
    foundArgs.add(name)
  }
  
  Void testPositionalArgs() {
    verifyPositionalArgs("get-log 10 true", ["10", "true"])
    verifyPositionalArgs("get-log", [,])
    verifyPositionalArgs("get-log 10", ["10"])    
    verifyPositionalArgs("get-button \"Foo\"", ["\"Foo\""])
  }
  
  private Void verifyPositionalArgs(Str text, Str[] args) {
    blocks := Parser.list(grammar, text.toBuf)
    expected := args.dup
    blocks.each {
      if (it.name.equals("ArgValue")) {
        verifyEq(expected.first, text[it.range])
        expected.removeAt(0)
      }
    }
    verify(expected.isEmpty, "The following values are not found: " + expected)
  }
  
  Void testBrackets() {
    verifyPositionalArgs("get-menu [get-by-os] | click", ["[get-by-os] "])
    verifyPositionalArgs("try { get-button | click }", ["{ get-button | click }"])
  }
  
}
