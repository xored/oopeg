
using concurrent

enum class CacheActionType {
  CLEAR, GET
}

const class MemoryCacheActor : Actor {
  private static const Str CACHE := "memory.cache"
  private const Duration? expired
  
  new make(Duration? expired, ActorPool pool := ActorPool()) : super(pool) {
    this.expired = expired
    sendClear
  }

  internal Obj:Obj? values {
    get { Actor.locals.getOrAdd(CACHE) { Obj:Obj? [:] } }
    set { Actor.locals[CACHE] = it }
  }
  
  override protected Obj? receive(Obj? msg) {
    Obj[] arr := (Obj[])((Unsafe)msg).val
    switch (arr[0]) {
      case CacheActionType.GET:
        return values.getOrAdd(arr[1], (|->Obj?|) arr[2])
      case CacheActionType.CLEAR:
        values.clear
    }
    return null
  }

  private Void sendClear() {
    if (expired != null) {    
      sendLater(expired, Unsafe([CacheActionType.CLEAR]))
    }
  }
  
}
