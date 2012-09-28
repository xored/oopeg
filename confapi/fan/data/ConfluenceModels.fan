
enum class ConfluenceSpaceType {
  global, personal, all
  public static const ConfluenceSpaceType defVal := ConfluenceSpaceType.all
}

enum class ConfluenceExpandType {
  space, children, comments, attachments, rootpages, userproperties, home, labels
}

internal const class ConfluenceContants {
  public static const Str EXPAND          := "expand"  
  public static const Str CONTENT         := "content"
  public static const Str SPACE           := "space"
  public static const Str TYPE            := "type"
  public static const Str START_INDEX     := "start-index"
  public static const Str MAX_RESULTS     := "max-results"
  public static const Str ATTACHMENT      := "attachment"
  public static const Str ATTACHMENTS     := "attachments"
  public static const Str MIME_TYPE       := "mimeType"
  public static const Str ATTACHMENT_TYPE := "attachmentType"
  public static const Str REVERSE_ORDER   := "reverseOrder"
}

@Serializable
abstract class ConfluenceDocument {
  Int? id  
  Str? title
  Str? wikiLink
  ConfluenceLink[]? link := [,]
  ConfluenceDate? lastModifiedDate
  ConfluenceDate? createdDate
}

class ConfluenceContent : ConfluenceDocument {
  Int? parentId
  Str? description  
  ConfluenceSpace? space := null
  Str? body
  
  ConfluenceContent[]? children := [,]
  ConfluenceContent[]? comments := [,]
  ConfluenceAttachment[]? attachments := [,]
  ConfluenceContent[]? labels := [,]
  
  override Str toStr() { "[id: ${id}, title: ${title}]" }  
}

class ConfluenceSpace : ConfluenceDocument {
  Str? key
  Str? name
  Str? description
  ConfluenceContent? home := null
  
  override Str toStr() { "[title: ${title}]" }  
}

class ConfluenceAttachment : ConfluenceDocument {
  Int? ownerId
  Str? fileName
  Str? contentType
  Int? fileSize
  Str? niceFileSize
  Int? version
  Str? niceType
  Str? iconClass
  ConfluenceLink? thumbnailLink
  ConfluenceSpace? space
 
  override Str toStr() { "[name: ${fileName}, size: ${niceFileSize}, type: ${niceType}]" }
}

@Serializable
class ConfluenceDate {
  Str? friendly
  Str? date
  
  Date toDate() { Date.fromStr(date) }
  override Str toStr() { "[date: ${friendly}]" }
}

@Serializable
class ConfluenceLink {
  Uri? href
  Str? type
  Str? rel
  
  override Str toStr() { "[href: ${href}]" }
}
