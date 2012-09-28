
using util

internal class ConfluenceComplexTests : Test {
  
  public Void testComplex() {
    echo(
      ConfluenceWikiHtmlRender().render(
        ConfluenceUtils.readResourceFile(`/res/confluence-wiki.test`)
      )
    )
  }
  
}
