
using peg

class Main
{
  
  static Void main(Str[] args) {
    grammarText := Main#.pod.file(`/res/ecl-grammar.peg`).readAllStr
    grammar := Grammar.fromStr(grammarText)
    
    input := "try -times 10 -command { get-button \"Foo\" | click }"
    root := Parser.tree(grammar, input.toBuf)
    printScript(root, input)
  }
  
  private static Void printScript(BlockNode n, Str text) {
    if (n.block.name.equals("CommandName")) {
      echo("command: " + text[n.block.range])
    }
    if (n.block.name.equals("ParameterName")) {
      echo("  arg: " + text[n.block.range])
    }
    if (n.block.name.equals("ParameterValue")) {
      echo("    value: '" + text[n.block.range] + "'")
    }
    n.kids.each { printScript(it, text) }
  }
  
}
