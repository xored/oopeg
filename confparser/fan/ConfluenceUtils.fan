
internal class ConfluenceUtils {
  
  public static File getResourceFile(Uri path) {
    pod := ConfluenceUtils#.pod
    return pod.file(path)
  }

  public static Str readResourceFile(Uri path) {
    return getResourceFile(path).readAllStr
  }
  
}
