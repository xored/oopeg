
using util

internal class ConfluenceSimpleTests : Test {

  Void testPlainText() {
    verify("".equals(render("")))
    verify(" ".equals(render(" ")))
    verify("\t".equals(render("\t")))
    verify("0123456789".equals(render("0123456789")))
    verify("4, 8, 15, 16, 23, 42".equals(render("4, 8, 15, 16, 23, 42")))
    verify("Hello, World!".equals(render("Hello, World!")))
  }
  
  Void testSigns() {
    signs := [
      "[", "]", "{", "}",
      "!", "@", "#", "\$", "%", "&", "(", ")", ":", "\"", "=",
      "<", ">", ";", "/", ",", ".", "'",  "\\", "`", "№" 
    ]
    signs.each {
      verify(it.equals(render(it)))
    }
  }

  Void testBreakLine() {
    verify("<br/>".equals(render("\\\\")))
    verify("<br/>\r\n".equals(render("\r\n")))
    verify("<br/>\r".equals(render("\r")))
    verify("<br/>\n<br/>\n".equals(render("\n\n")))
    verify("<br/>\r<br/>\r".equals(render("\r\r")))
  }
  
  Void testBoldText() {
    verify("*".equals(render("*")))
    verify("**".equals(render("**")))
    verify("***".equals(render("***")))
    verify("* *".equals(render("* *")))
    verify("<strong>bold</strong>".equals(render("*bold*")))
    verify("<strong>b o l d</strong>".equals(render("*b o l d*")))
    verify("<strong>bold 4 815`</strong>".equals(render("*bold 4 815`*")))
  }

  Void testItalicText() {
    verify("_".equals(render("_")))    
    verify("__".equals(render("__")))
    verify("___".equals(render("___")))
    verify("_ _".equals(render("_ _")))
    verify("<em>italic</em>".equals(render("_italic_")))
    verify("<em>i t a l i c</em>".equals(render("_i t a l i c_")))
  }

  Void testStrikeText() {
    verify("-".equals(render("-")))    
    verify("--".equals(render("--")))
    verify("---".equals(render("---")))
    verify("- -".equals(render("- -")))
    verify("<strike>strike</strike>".equals(render("-strike-")))
    verify("<strike>s t r i k e</strike>".equals(render("-s t r i k e-")))
    verify("<strike>strike 481 5@</strike>".equals(render("-strike 481 5@-")))
  }

  Void testUnderText() {
    verify("+".equals(render("+")))
    verify("++".equals(render("++")))
    verify("+++".equals(render("+++")))
    verify("+ +".equals(render("+ +")))
    verify("<u>under</u>".equals(render("+under+")))
    verify("<u>u n d e r</u>".equals(render("+u n d e r+")))
    verify("<u>under4</u>".equals(render("+under4+")))
  }

  Void testCitationText() {
    verify("?".equals(render("?")))
    verify("??".equals(render("??")))
    verify("????".equals(render("????")))
    verify("??????".equals(render("??????")))
    verify("?? ??".equals(render("?? ??")))
    verify("<cite>cite</cite>".equals(render("??cite??")))
    verify("<cite>c i t e</cite>".equals(render("??c i t e??")))
    verify("<cite>\$cite\$</cite>".equals(render("??\$cite\$??")))
  }

  Void testSuperScriptText() {
    verify("^".equals(render("^")))
    verify("^^".equals(render("^^")))
    verify("^^^".equals(render("^^^")))
    verify("^ ^".equals(render("^ ^")))
    verify("<sup>super</sup>".equals(render("^super^")))
    verify("<sup>s u p e r</sup>".equals(render("^s u p e r^")))
    verify("<sup>super %48</sup>".equals(render("^super %48^")))
  }

  Void testSubScriptText() {
    verify("~".equals(render("~")))
    verify("~~".equals(render("~~")))
    verify("~~~".equals(render("~~~")))
    verify("~ ~".equals(render("~ ~")))
    verify("<sub>sub</sub>".equals(render("~sub~")))
    verify("<sub>s u b</sub>".equals(render("~s u b~")))
    verify("<sub>sub -4</sub>".equals(render("~sub -4~")))
  }

  Void testHText() {
    verify(Regex<|<h1>(.)*</h1>|>.matcher(render("h1. h1 title")).matches)
    verify(Regex<|<h2>(.)*</h2>|>.matcher(render("h2. h1 title")).matches)
    verify(Regex<|<h3>(.)*</h3>|>.matcher(render("h3. h1 title")).matches)
    verify(Regex<|<h4>(.)*</h4>|>.matcher(render("h4. h1 title")).matches)
    verify(Regex<|<h5>(.)*</h5>|>.matcher(render("h5. h1 title")).matches)
    verify(Regex<|<h6>(.)*</h6>|>.matcher(render("h6. h1 title")).matches)
    verify("h7. h1 title".equals(render("h7. h1 title")))
    verify(Regex<|<h1>(.)*</h1>|>.matcher(render("h1.")).matches)
  }
  
  Void testGraphicalEmoticons() {
    GraphicalEmoticonType.vals.each |GraphicalEmoticonType emoticon| {
      emoticon.notations.each |Str notation| {
       verify(Regex<|<img(.)*/>|>.matcher(render(notation)).matches)
      }
    }
    verify("(+".equals(render("(+")))
    verify(render("(*)").equals(render("(*y)")))
  }
  
  Void testAlphabets() {
    engAlphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    rusAlphabet := "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя"
    verify(engAlphabet.equals(render(engAlphabet)))
    verify(rusAlphabet.equals(render(rusAlphabet)))
  }
  
  private Str render(Str wikiText) {
    return ConfluenceWikiHtmlRender().render(wikiText)
  }
  
}
