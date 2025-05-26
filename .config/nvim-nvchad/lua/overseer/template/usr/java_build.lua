return {
  name = "java build",
  builder = function()
    os.execute "find . -type f | rg -i .java$ > sourceFiles.txt"
    return {
      cmd = { "javac" },
      args = { "@sourceFiles.txt" },
      components = {
        { "on_complete_notify", statuses = { "SUCCESS" } },
        "default",
      },
    }
  end,
  condition = {
    filetype = { "java" },
  },
}
