
using web
using util

public class ConfluenceClient {
  private static const Str REST_API_VERSION := "1"
  private static const Str REST_API := "rest/prototype/" + REST_API_VERSION + "/"
  
  private const Str authToken
  private const Uri serverAdress
  private const JsonDataInjector injector
  public ConfluenceDatasource datasource
  
  new make(Uri serverAdress, Str login, Str password) {
    JsonDataTransformer[] transformers := [,]
    transformers.addAll([
      SubListJsonDataTransformer(ConfluenceAttachment[]#, ConfluenceContants.CONTENT),
      SubListJsonDataTransformer(ConfluenceContent[]#, ConfluenceContants.CONTENT)
    ])
    transformers.addAll(JsonDataInjector.DEFAULT_TRANSFORMERS)
    
    this.serverAdress = serverAdress
    this.authToken = Buf.make.print(login + ":" + password).toBase64
    this.injector = JsonDataInjector(transformers)
    this.datasource = ConfluenceDirectDatasource(this)
  }

  private Str:Str headers() {
    return [
      "Authorization" : "Basic " + authToken,
      "Accept" : "application/json"
    ]
  }
  
  private Str restApi() { serverAdress.toStr + REST_API }

  private WebClient request(Uri path, Str:Str headers := [:], Str method := "GET", Buf contents := Buf()) {
    wc := WebClient(path)
    wc.reqMethod = method
    wc.reqHeaders.setAll(headers)
    wc.writeReq
    if (contents.size > 0) {
      wc.reqOut.writeBuf(contents).close
    }
    wc.readRes
    return wc
  }

  private Str:Str additionalParam(Str paramName, Obj? param := null, [Str:Str]? params := [:]) {
    if (param != null && params != null) {
      params.add( paramName, param is List ? ((List)param).join(",") : param.toStr)
    }
    return params
  }
  
  public Obj? getJson(Str url, Str:Str params := [:]) {
    paramsPostfix := params.isEmpty ? "" : "?" + params.join("&", |value, key| { key + "=" + value   })
    address := restApi + url + paramsPostfix
    return datasource.getData(address)
  }
  
  public Obj? reciveJson(Str url) {
    client := request(Uri(url), headers)
    json := JsonInStream(client.resStr.in).readJson
    client.close
    return json
  }
  
  private Obj getConfluenceEntity(Type type, Str url, Str:Str params := [:]) {
    return injector.createObject(type, getJson(url, params))
  }
  
  /**
   * Returns information about a space identified by the key passed.
   * HTTP 404 (not found) if the space is not found or the user requesting it does not have the correct permissions.
   */
  public ConfluenceSpace getSpace(Str key, ConfluenceExpandType[]? expand := null) {
    return getConfluenceEntity(
      ConfluenceSpace#,
      ConfluenceContants.SPACE + "/" + key,
      additionalParam(ConfluenceContants.EXPAND, expand)
    )
  }

  /**
   * Retrieves a list of spaces visible to the currently logged in user, alphabetically by space name.
   * An optional parameter 'type' allows filtering on space type. The standard paging parameters 'start-index'
   * and 'max-results' can be used to page through the list. A maximum of 50 spaces will be listed.
   *  
   * type - The space type parameter to filter the list by. Type can be one of: GLOBAL, PERSONAL, ALL
   * start-index - The first (inclusive) index to return. Can be any integer zero or greater.
   * max-results - The number of results to return. Can be any positive integer.
   */  
  public ConfluenceSpace[] getSpaces(
    ConfluenceSpaceType type := ConfluenceSpaceType.all, Int startIndex := 0, Int maxResults := 50,
    ConfluenceExpandType[]? expand := null
  ) {
    Str:Str params := [
      ConfluenceContants.TYPE : type.toStr,
      ConfluenceContants.START_INDEX : startIndex.toStr,
      ConfluenceContants.MAX_RESULTS : maxResults.toStr
    ]
    additionalParam(ConfluenceContants.EXPAND, expand, params)
    Str:Obj json := getJson(ConfluenceContants.SPACE, params)
    
    Obj[] spaces := json.get(ConfluenceContants.SPACE)
    
    return spaces.map |raw -> ConfluenceSpace| {
      injector.createObject(ConfluenceSpace#, raw)
    }
  }
  
  /**
   * Returns a full representation of the attachment for the given ID.
   * The ID is that of an attachment and not the page it is attached to.
   */
  public ConfluenceAttachment[] getAttachment(Int id) {
    return getConfluenceEntity(ConfluenceSpace#, ConfluenceContants.ATTACHMENT + "/" + id)
  }
  
  /**
   * Returns the attachments for a given resource. The results are ordered by the creation date.
   *
   * start-index - Index of first item (inclusive) to return.
   * max-results - Maximum number of items to return. Default is 50.
   * mimeType - Mime types to filter the attachments by, such as: image/jpeg
   * attachmentType - 'Nice' type to filter the attachments by. Filtering is case insensititve.
   * reverseOrder - set to true to have the results returned in reverse chronological order.
   */
  public ConfluenceAttachment[] getContentAttachments(
    Int id, Int startIndex := 0, Int maxResults := 50, Bool reverseOrder := false,
    Str? mimeType := null, Str? attachmentType := null,
    ConfluenceExpandType[]? expand := null
  ) {
    Str:Str params := [
      ConfluenceContants.START_INDEX : startIndex.toStr,
      ConfluenceContants.MAX_RESULTS : maxResults.toStr,
      ConfluenceContants.REVERSE_ORDER : reverseOrder.toStr
    ]
    additionalParam(ConfluenceContants.EXPAND, expand, params)
    additionalParam(ConfluenceContants.MIME_TYPE, mimeType, params)
    additionalParam(ConfluenceContants.ATTACHMENT_TYPE, attachmentType, params)
    
    Str:Obj json := getJson(ConfluenceContants.CONTENT + "/" + id + "/" + ConfluenceContants.ATTACHMENTS, params)
    Obj[] attachments := json.get(ConfluenceContants.ATTACHMENT)

    return attachments.map |raw -> ConfluenceAttachment| {
      injector.createObject(ConfluenceAttachment#, raw)
    }
  }
    
  public ConfluenceContent getContent(Int id, ConfluenceExpandType[]? expand := null) {
    return getConfluenceEntity(
      ConfluenceContent#,
      ConfluenceContants.CONTENT + "/" + id,
      additionalParam(ConfluenceContants.EXPAND, expand)
    )
  }
  
  public static Obj? convertToJson(Obj obj) {
    buf := StrBuf()
    JsonOutStream(buf.out).writeJson(obj).flush
    return JsonInStream(buf.toStr.in).readJson
  }
}
