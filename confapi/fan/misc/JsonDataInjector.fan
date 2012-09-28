
using web
using util

const class JsonDataInjector {
  public static const JsonDataTransformer[] DEFAULT_TRANSFORMERS := [
    StrJsonDataTransformer(),
    IntJsonDataTransformer(),
    FloatJsonDataTransformer(),
    BoolJsonDataTransformer(),
    UriJsonDataTransformer(),
    EnumJsonDataTransformer(),
    ListJsonDataTransformer()
  ]
  
  const JsonDataTransformer[] transformers
  
  new make(JsonDataTransformer[] transformers := DEFAULT_TRANSFORMERS) {
    this.transformers = transformers
  }
  
  public Obj createObject(Type type, Obj:Obj json) {
    return injectData(type.make, json)
  }
  
  public Obj injectData(Obj obj, Obj:Obj json) {
    obj.typeof.fields.each |field| {
      fname := field.name
      dvalue := json.get(fname)
      
      if (dvalue != null) {
        fvalue := field.get(obj)
        ftype := field.type
        
        Bool actTransformer := false
        for (Int i := 0; i < transformers.size; i++) {
          transformer := transformers.get(i)
          if (ftype.fits(transformer.actType)) {
            field.set(obj, transformer.transform(this, field, obj, dvalue))
            actTransformer = true
            break;
          }
        }
        
        if (actTransformer == false && dvalue is Map) {
          field.set(obj, injectData(fvalue ?: ftype.make, (Map)dvalue))
        }
      }
    }
    return obj
  }

}

const abstract class JsonDataTransformer {
  public const Type actType
  
  new make(Type actType) {
    this.actType = actType
  }
  
  public abstract Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value)
}

internal const class StrJsonDataTransformer : JsonDataTransformer {
  new make() : super(Str#) {}
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    return (Str)value
  }
}

internal const class IntJsonDataTransformer : JsonDataTransformer {
  new make() : super(Int#) {}
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    return value is Int ? value : Int.fromStr(value)
  }
}

internal const class FloatJsonDataTransformer : JsonDataTransformer {
  new make() : super(Float#) {}
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    return value is Float ? value : Float.fromStr(value)
  }
}

internal const class BoolJsonDataTransformer : JsonDataTransformer {
  new make() : super(Bool#) {}
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    return value is Bool ? value : Bool.fromStr(value)
  }
}

internal const class UriJsonDataTransformer : JsonDataTransformer {
  new make() : super(Uri#) {}
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    return value is Uri ? value : Uri.fromStr(value)
  }
}

internal const class EnumJsonDataTransformer : JsonDataTransformer {
  new make() : super(Enum#) {}
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    ftype := field.type
    return ftype.make->fromStr(value)
  }
}

internal const class ListJsonDataTransformer : JsonDataTransformer {
  new make() : super(List#) {}
  override Obj? transform(JsonDataInjector injector,Field field, Obj obj, Obj value) {
    fvalue := field.get(obj)
    ftype := field.type
    if (fvalue == null) {
      fvalue = ftype.make
    }
    ((List)value).each |v| {
      Type type := ftype.params.get("V")
      ((List)fvalue).add(injector.injectData(type.make, v))
    }
    return fvalue
  }
}

internal const class SubListJsonDataTransformer : JsonDataTransformer {
  private const Str subField
  
  new make(Type type, Str subField) : super(type) {
    this.subField = subField
  }
  
  override Obj? transform(JsonDataInjector injector, Field field, Obj obj, Obj value) {
    List? subValues := ((Map)value).get(subField)
    if (subValues == null) return null
    
    fvalue := field.get(obj)
    ftype := field.type
    if (fvalue == null) {
      fvalue = ftype.make
    }
    ((List)subValues).each |subValue| {
      Type type := ftype.params.get("V")
      ((List)fvalue).add(injector.injectData(type.make, subValue))
    }
    return fvalue
  }
  
}
