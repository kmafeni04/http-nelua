---@class PackageDependency
---@field name string package name as it will be used in file gen
---@field repo string git repo
---@field version? string git hash(#) or tag(v), defaults to "#HEAD"

---@class Package
---@field dependencies? PackageDependency[] List of package dependencies
---@field scripts? table<string, string> scripts that can be called with `nlpm run`

---@type Package
return {
  dependencies = {
    {
      name = "json-nelua",
      repo = "https://github.com/kmafeni04/json-nelua",
      version = "#bb1a6f8d6639f22faceab1018efcf2bbd0a748cd",
    },
  },
  scripts = {
    test = "nelua test.nelua",
    gen_doc = "nelua http-doc.nelua",
  },
}
