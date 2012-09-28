
using peg

enum class ConfluenceElementType {
  Characters, Spaces, EOL, LineBreak, Numbers, SpecialSign, Signs,
  BoldText, StrikeText, ItalicText, UnderText,
  CitationText, SuperScriptText, SubScriptText,
  H1Text, H2Text, H3Text, H4Text, H5Text, H6Text, HBodyText,
  BulletedList, NumberedList, BulletedListLine, NumberedListLine,
  LinkAddress,
  GraphicalEmoticon,
  Table, TableTr, TableTd, TableTh
}

const class ConfluenceWikiHtmlRender {
  private static const Grammar GRAMMAR := |->Grammar| {
    grammarText := ConfluenceUtils.readResourceFile(`/res/confluence-wiki.grammar`)
    return Grammar.fromStr(grammarText)
  }.call

  private StrBuf traverse(
    ConfluenceRenderContext context, BlockNode node,
    |Block -> Str| onBefore, |Block -> Str| onAfter
  ) {
    result := StrBuf()    
    result.add(onBefore(node.block))
    node.kids.each {
      kids := traverse(context, it, onBefore, onAfter)
      result.add(kids)
    }
    result.add(onAfter(node.block))
    return result
  }
  
  private StrBuf makeTraverse(BlockNode root, ConfluenceRenderContext context) {
    return traverse(
      context, root,
      // On before
      |Block block -> Str| {
        ConfluenceElementType? type := null
        try {
          type = ConfluenceElementType.fromStr(block.name)
        } catch (Err err) {}
        
        if (type != null) {
          render := context.renderers.get(type)
          if (render != null) {
            return render.onBefore(block, context)
          }
        }
        return ""
      },
      // On after
      |Block block -> Str| {
        ConfluenceElementType? type := null
        try {
          type = ConfluenceElementType.fromStr(block.name)
        } catch (Err err) {}
        
        if (type != null) {
          render := context.renderers.get(type)
          if (render != null) {
            return render.onAfter(block, context)
          }
        }
        return ""
      }
    )
  }
  
  public Str render(Str inputText) {
    renderers := [
      ConfluenceElementType.Characters: PlainTextRender(),
      ConfluenceElementType.Spaces: PlainTextRender(),
      ConfluenceElementType.Numbers: PlainTextRender(),
      ConfluenceElementType.SpecialSign: PlainTextRender(),
      ConfluenceElementType.Signs: PlainTextRender(),
      ConfluenceElementType.EOL: PlainTextRender(),
      ConfluenceElementType.LineBreak: LineBreakRender(),
      
      ConfluenceElementType.BoldText: BoldTextRender(),
      ConfluenceElementType.ItalicText: ItalicTextRender(),
      ConfluenceElementType.UnderText: UnderTextRender(),
      ConfluenceElementType.StrikeText: StrikeTextRender(),
      
      ConfluenceElementType.CitationText: CitationTextRender(),
      ConfluenceElementType.SuperScriptText: SuperScriptTextRender(),
      ConfluenceElementType.SubScriptText: SubScriptTextRender(),
      
      ConfluenceElementType.LinkAddress: LinkRender(),
      ConfluenceElementType.GraphicalEmoticon: GraphicalEmoticonRender(),
      
      ConfluenceElementType.H1Text: H1TextRender(),
      ConfluenceElementType.H2Text: H2TextRender(),
      ConfluenceElementType.H3Text: H3TextRender(),
      ConfluenceElementType.H4Text: H4TextRender(),
      ConfluenceElementType.H5Text: H5TextRender(),
      ConfluenceElementType.H6Text: H6TextRender(),
      ConfluenceElementType.HBodyText: HBodyTextRender(),
      
      ConfluenceElementType.BulletedListLine: ListLineRender("ul"),
      ConfluenceElementType.NumberedListLine: ListLineRender("ol"),
      ConfluenceElementType.BulletedList: ListRender("ul"),
      ConfluenceElementType.NumberedList: ListRender("ol"),
      
      ConfluenceElementType.Table: TableRender(),
      ConfluenceElementType.TableTr: TableTrRender(),
      ConfluenceElementType.TableTd: TableTdRender(),
      ConfluenceElementType.TableTh: TableThRender()
    ]

    return customizedRender(inputText, renderers)
  }
  
  public Str customizedRender(Str inputText, ConfluenceElementType:ConfluenceNodeRender renderers) {
    root := Parser.tree(GRAMMAR, inputText.toBuf)
    context := ConfluenceRenderContext(renderers, inputText)
    return makeTraverse(root, context).toStr    
  }
}
