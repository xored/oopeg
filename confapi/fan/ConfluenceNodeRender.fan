
using peg

class ConfluenceRenderContext {
  public ConfluenceElementType:ConfluenceNodeRender renderers
  public Str input
  public Int listDepth
  
  new make(ConfluenceElementType:ConfluenceNodeRender renderers, Str input) {
    this.renderers = renderers
    this.input = input
    this.listDepth = 0    
  }
}

abstract const class ConfluenceNodeRender {
  public virtual Str onBefore(Block node, ConfluenceRenderContext context) { "" }
  public virtual Str onAfter(Block node, ConfluenceRenderContext context) { "" }
}

const class TagWrapperRender : ConfluenceNodeRender {
  private const Str tagName
  
  new make(Str tagName) {
    this.tagName = tagName
  }
  
  override public Str onBefore(Block node, ConfluenceRenderContext context) { "<" + tagName + ">" }
  override public Str onAfter(Block node, ConfluenceRenderContext context) { "</" + tagName + ">" }
}

internal const class PlainTextRender : ConfluenceNodeRender {
  override public Str onBefore(Block node, ConfluenceRenderContext context) { context.input[node.range] } 
}

internal const class LineBreakRender : ConfluenceNodeRender {
  override public Str onBefore(Block node, ConfluenceRenderContext context) { "<br/>" } 
}

internal const class BoldTextRender : TagWrapperRender { new make() : super("strong") {} }
internal const class ItalicTextRender : TagWrapperRender { new make() : super("em") {} }
internal const class UnderTextRender : TagWrapperRender { new make() : super("u") {} }
internal const class StrikeTextRender : TagWrapperRender { new make() : super("strike") {} }
internal const class CitationTextRender : TagWrapperRender { new make() : super("cite") {} }
internal const class SuperScriptTextRender : TagWrapperRender { new make() : super("sup") {} }
internal const class SubScriptTextRender : TagWrapperRender { new make() : super("sub") {} }

internal const class HBodyTextRender : ConfluenceNodeRender {
  private static const Str[] SIGNS := [ 
    "*", "-", "_", "+", "[", "]", " ", "\t",
    "~", "!", "@", "#", "\$", "%", "^", "&", "(", ")", ":", "\"", "|", ">", "=",
    "<", ">", "?", "№", ";", "?", "/", ",", ".", "'", "\\", "{", "}", "`"
  ]
  
  override public Str onBefore(Block node, ConfluenceRenderContext context) {
    return LinkRender.getLinkTag(getInnerLinkAddress(context.input[node.range])) + context.input[node.range]
  }
  
  private Str getInnerLinkAddress(Str text) {
    SIGNS.each { text = text.replace(it, "")  }
    return text
  }
}

internal const class H1TextRender : TagWrapperRender { new make() : super("h1") {} }
internal const class H2TextRender : TagWrapperRender { new make() : super("h2") {} }
internal const class H3TextRender : TagWrapperRender { new make() : super("h3") {} }
internal const class H4TextRender : TagWrapperRender { new make() : super("h4") {} }
internal const class H5TextRender : TagWrapperRender { new make() : super("h5") {} }
internal const class H6TextRender : TagWrapperRender { new make() : super("h6") {} }

internal abstract const class ListPartRender : ConfluenceNodeRender {
  protected Int getListDepth(Str text) {
    Int count := 0
    
    text = text.replace(" ", "")
               .replace("\r", "")
               .replace("\n", "")
               .replace("\t", "")
    
    while (true) {
      v := text.get(count)
      if (v == '*' || v == '#') count++; else break
    }
    
    return count
  }  
}

internal const class ListLineRender : ListPartRender {
  private const Str listType

  new make(Str listType) {
    this.listType = listType
  }
  
  override public Str onBefore(Block node, ConfluenceRenderContext context) {
    ns := getListDepth(context.input[node.range])
    d := ns - context.listDepth
    context.listDepth = ns
    
    result := ""
    if (d > 0) {
      d.times { result += "<" + listType + ">" }
    } else if (d < 0) {
      d.abs.times { result += "</" + listType + ">" }
    }
    result += "<li>"
    
    return result
  }
}

internal const class ListRender : ListPartRender {
  private const Str listType
  
  new make(Str listType) {
    this.listType = listType
  }
  
  override public Str onAfter(Block node, ConfluenceRenderContext context) {
    context.listDepth = 0
    return "</" + listType + ">"
  }
}

internal const class LinkRender : ConfluenceNodeRender {
  override public Str onBefore(Block node, ConfluenceRenderContext context) {
    return getLinkTag(context.input[node.range], context.input[node.range])
  }
  
  public static Str getLinkTag(Str address, Str title := "") { "<a href=\"" + address + "\">" + title + "</a>" }
}

internal enum class GraphicalEmoticonType {
  ADD(["(+)"]),
  FORBIDDEN(["(-)"]),
  HELP(["(?)"]),
  BULB_ON(["(on)"]),
  BULB(["(off)"]),
  STAR_YELLOW(["(*)", "(*y)"]),
  STAR_RED(["(*r)"]),
  STAR_GREEN(["(*g)"]),
  START_BLUE(["(*b)"]),
  SMILE([":)"]),
  SAD([":("]),
  TONGUE([":P"]),
  BIG_GRIN([":D"]),
  WINK([";)"]),
  THUMBS_UP(["(y)"]),
  THUMBS_DOWN(["(n)"]),
  INFORMATION(["(i)"]),
  CHECK(["(/)"]),
  ERROR(["(x)"]),
  WARNING(["(!)"])
  
  public const Str[] notations
  
  private new make(Str[] notations) {
    this.notations = notations
  }
  
  public static GraphicalEmoticonType? findByNotation(Str notation) {
    return GraphicalEmoticonType.vals.find {
      it.notations.find { it.equals(notation) } != null
    }
  }
}

internal const class GraphicalEmoticonRender : ConfluenceNodeRender {
  private static const Str DEFAULT_PATH := "{{media_url}}icons/emoticons/"
  private const Str path
  
  new make(Str path := DEFAULT_PATH) {
    this.path = path
  }
  
  override public Str onBefore(Block node, ConfluenceRenderContext context) {
    content := context.input[node.range]
    try {
      GraphicalEmoticonType type := GraphicalEmoticonType.findByNotation(content)
      imageAddress := path + type.toStr.lower + ".png"
      return "<img src=\"" + imageAddress + "\" align=\"absmiddle\" alt=\"\" border=\"0\"/>"
    } catch (Err err) {
      return content
    }
  }
}

internal const class TableRender : TagWrapperRender { new make() : super("table") {} }
internal const class TableTrRender : TagWrapperRender { new make() : super("tr") {} }
internal const class TableTdRender : TagWrapperRender { new make() : super("td") {} }
internal const class TableThRender : TagWrapperRender { new make() : super("th") {} }
