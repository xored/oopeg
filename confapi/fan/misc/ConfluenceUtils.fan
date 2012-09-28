
internal class ConfluenceUtils {
  private static const Str POD_NAME := "confapi"
  
  public static File getResourceFile(Uri path) {
    pod := Pod.find(POD_NAME)
    return pod.file(path)    
  }

  public static Str readResourceFile(Uri path) {
    return getResourceFile(path).readAllStr
  }
  
}
