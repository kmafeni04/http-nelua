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
      version = "#43617c9380f4d86a5f593af34cc0ad0152a95a42",
    },
    {
      name = "ssdg",
      repo = "https://github.com/kmafeni04/ssdg",
      version = "#9e1fb58f183ae7efea98d25a40d6d1bf38f483af",
    },
    {
      name = "openssl-bindings-nelua",
      repo = "https://github.com/kmafeni04/openssl-bindings-nelua",
      version = "#6dc1704ab9b4c843a530059886d177aca4de8211",
    },
    {
      name = "ansicolor-nelua",
      repo = "https://github.com/kmafeni04/ansicolor-nelua",
      version = "#0b5f769242a441bdb4d293957be240e6fb694428",
    },
    {
      name = "map-nelua",
      repo = "https://github.com/kmafeni04/map-nelua",
      version = "#4572efa8784fcce5763073007852573fb578fbdd",
    },
    {
      name = "variant-nelua",
      repo = "https://github.com/kmafeni04/variant-nelua",
      version = "#c1dbeb2a1daa86d88a38deb24416b66149161e65",
    },
  },
  scripts = {
    test = "nelua --cc=tcc test.nelua",
    docs = "nelua --cc=tcc nttp-doc.nelua",
  },
}
