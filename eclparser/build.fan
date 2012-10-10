using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "eclparser"
    summary = ""
    srcDirs = [`test/`, `fan/`]
    resDirs = [`res/`]
    depends = ["sys 1.0", "peg 0.8.1"]
  }  
}
