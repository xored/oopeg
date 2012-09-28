using build

class Build : build::BuildPod {
  new make() {
    podName = "confapi"
    summary = "Confluence integration API"
    version = Version.fromStr("1.0")
    srcDirs = [`test/`, `fan/`]
    resDirs = [`res/`]
    depends = [
      "sys 1.0",
      "web 1.0",
      "util 1.0",
      "concurrent 1.0",
      "peg 0.8"
    ]
  }
}
