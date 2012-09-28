
using concurrent

public abstract class ConfluenceDatasource {
  protected ConfluenceClient client
  
  new make(ConfluenceClient client) {
    this.client = client
  }
  
  public abstract Obj? getData(Obj key)
  public abstract Void clearCache()
}

public class ConfluenceDirectDatasource : ConfluenceDatasource {
  new make(ConfluenceClient client) : super(client) {}

  override public Obj? getData(Obj key) { client.reciveJson(key) }
  override public Void clearCache() {}
}

public class ConfluenceInMemoryCache : ConfluenceDatasource {
  private const Actor sender
  
  new make(ConfluenceClient client, Duration? expiredTime := null, ActorPool pool := ActorPool()) : super(client) {
    sender = MemoryCacheActor(expiredTime, pool)
  }
  
  override public Obj? getData(Obj key) {
    sender.send(Unsafe([CacheActionType.GET, key, |->Obj?| { client.reciveJson(key) }])).get
  }
  
  override public Void clearCache() {
    sender.send(Unsafe([CacheActionType.CLEAR])).get
  }
}
