# http.nelua

A sufficiently featured webserver for nelua

## Quick start

```lua
local http = require "path.to.http"

local app = http.Server.new()

app:get(nil, "/", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "hello, world")
end)

app:serve()
```

## Reference

### http.nelua

#### http

```lua
local http = @record{}
```

#### http.json

See [json.nelua](#jsonnelua)

```lua
local http.json = json
```

#### http.send_request

See [send_request.nelua](#send_requestnelua)

```lua
local http.send_request = send_request
```

#### http.utils

See [utils.nelua](#utilsnelua)

```lua
local http.utils = utils
```

#### http.Status

Enum list of different possible HTTP status codes

```lua
local http.Status = @enum{
  Continue = 100,
  SwitchingProtocols = 101,
  Processing = 102,
  EarlyHints = 103,
  
  OK = 200,
  Created = 201,
  Accepted = 202,
  NonAuthoritativeInfo = 203,
  NoContent = 204,
  ResetContent = 205,
  PartialContent = 206,
  MultiStatus = 207,
  AlreadyReported = 208,
  IMUsed = 226,
  
  MultipleChoices = 300,
  MovedPermanently = 301,
  Found = 302,
  SeeOther = 303,
  NotModified = 304,
  UseProxy = 305,
  SwitchProxy = 306,
  TemporaryRedirect = 307,
  PermanentRedirect = 308,

  BadRequest = 400,
  Unauthorized = 401,
  PaymentRequired = 402,
  Forbidden = 403,
  NotFound = 404,
  MethodNotAllowed = 405,
  NotAcceptable = 406,
  ProxyAuthRequired = 407,
  RequestTimeout = 408,
  Conflict = 409,
  Gone = 410,
  LengthRequired = 411,
  PreconditionFailed = 412,
  RequestEntityTooLarge = 413,
  RequestURITooLong = 414,
  UnsupportedMediaType = 415,
  RequestedRangeNotSatisfiable = 416,
  ExpectationFailed = 417,
  Teapot = 418,
  MisdirectedRequest = 421,
  UnprocessableEntity = 422,
  Locked = 423,
  FailedDependency = 424,
  TooEarly = 425,
  UpgradeRequired = 426,
  PreconditionRequired = 428,
  TooManyRequests = 429,
  RequestHeaderFieldsTooLarge = 431,
  UnavailableForLegalReasons = 451,

  InternalServerError = 500,
  NotImplemented = 501,
  BadGateway = 502,
  ServiceUnavailable = 503,
  GatewayTimeout = 504,
  HTTPVersionNotSupported = 505,
  VariantAlsoNegotiates = 506,
  InsufficientStorage = 507,
  LoopDetected = 508,
  NotExtended = 510,
  NetworkAuthenticationRequired = 511,
}
```

#### http.TriBool

```lua
local http.TriBool= @enum{
  NULL = -1,
  FALSE,
  TRUE
}
```

#### http.Cookie

```lua
local http.Cookie = @record{
  name: string,
  val: string,
  path: string,
  domain: string,
  expires: string,
  secure: http.TriBool,
  httpOnly: http.TriBool
}
```

#### http.Response

```lua
local http.Response = @record{
  body: string,
  status: http.Status,
  content_type: string,
  headers: hashmap(string, string),
  cookies: sequence(http.Cookie)
}
```

#### http.Response:destroy

Destorys the response object and sets it to a zeroed state

```lua
function http.Response:destroy()
```

#### http.Response:tostring

This function converts your response into a http request string

```lua
app:get(nil, "/test", function(self: *http.Server)
  local resp = self:text(200, "ok")
  print(resp:tostring) -- "HTTP/1.1 200 OK\r\nServer: http-nelua\r\nDate: Thu, 17 Apr 2025 19:23:00 GMT\r\nContent-type: text/plain\r\nContent-Length: 4\r\n\r\nok\r\n"
  return resp
end)
```

```lua
function http.Response:tostring(): string
```

#### http.Response:set_header

Sets a header to be sent with the response
```lua
app:get(nil, "/", function(self: *http.Server)
  local resp = self:text(200, "ok")
  local err = resp:set_header("name", "james")
  if err ~= "" then
    return self:error(err)
  end
  return resp
end)
```

```lua
function http.Response:set_header(key: string, val: string):  string
```

#### http.Response:set_cookie

Sets a cookie to be sent with the response

```lua
app:get(nil, "/", function(self: *http.Server)
  local resp = self:text(200, "ok")
  local err = resp:set_cookie({
    name = "name",
    val = "james"
  })
  if err ~= "" then
    return self:error(err)
  end
  return resp
end)
```

```lua
function http.Response:set_cookie(c: http.Cookie):  string
```

#### http.ActionFn

```lua
local http.ActionFn = @function(self: *http.Server): http.Response
```

#### http.Session

```lua
local http.Session = @record{
  vals: hashmap(string, string),
  send: boolean
}
```

#### http.Session:set_val

This function is used to set values that will be stored in the sesssion

```lua
app:get(nil, "/", function(self: *http.Server)
  self.session:set_val("name", "james")
  self.session:set_val("age", "10")
  return self:text(200, "ok")
end)
```

```lua
function http.Session:set_val(name: string, val: string): string
```

#### Session:get_val(name: string): string

This function is used to get values that are stored in the sesssion

```lua
app:get(nil, "/test", function(self: *http.Server)
  local name = self.session:get_val("name")
  local age = self.session:get_val("age")
  return self:text(200, "ok")
end)
```

#### http.BeforeFn

```lua
local http.BeforeFn = @function(self: *http.Server): (boolean, http.Response)
```

#### http.Request

```lua
local http.Request = @record{
  method: string,
  version: string,
  headers: hashmap(string, string),
  current_path: string,
  params: hashmap(string, string),
  body: string
}
```

#### http.Request:get_header

Gets a header from the request object

```lua
app:get(nil, "/test", function(self: *http.Server)
  local name = self.req:get_header("name")
  return self:text(200, "ok")
end)

```lua
function http.Request:get_header(name: string): string
```

#### http.Request:get_cookie

Gets a cookie from the request object

```lua
app:get(nil, "/test", function(self: *http.Server)
  local name = self.req:get_cookie("name")
  return self:text(200, "ok")
end)

```lua
function http.Request:get_cookie(name: string): string
```

#### http.Config

Defaults are only set if the server is instantiated with [http.Server.new](#httpservernew)
- port: The port you want the server to run on, default is `8080`
- bind_host: The interface the server will bind to, default is `0.0.0.0`
- secret: This is used to sign your session, default is `please-change-me`
- session_name: Name of cookie used to store the session, default is `http_session`
- log: This determines whether the server will log the request information to the console, default is [http.NotSetOrBool](#httpnotsetorbool).NOT_SET

```lua
local http.Config = @record{
  port: uinteger,
  bind_host: string,
  secret: string,
  session_name: string,
  log: http.TriBool
}
```

#### http.Server

```lua
http.Server = @record{
  config: http.Config,
  static_dir: string,
  static_name: string,
  static_headers: hashmap(string, string),
  routes: hashmap(string, Route),
  var_routes: hashmap(string, Route),
  named_routes: hashmap(string, string),
  req: http.Request,
  default_route: http.ActionFn,
  handle_404: http.ActionFn,
  session: http.Session,
  before_funcs: sequence(http.BeforeFn),
  write: function(self: *http.Server, s: string): (boolean, string),
  written: boolean,
  _fd: integer
}
```

#### http.Server:set_static

This sets the directory when static files will be read from as well as the name that will be used for routing

```lua
local app = http.Server.new()

app:set_static("./static", "static")

app:get(nil, "/", function(self: *http.Server): http.Response
  return self:html(200, '<link rel="stylesheet" href="/static/test.css" />')
end)
```

```lua
function http.Server:set_static(dir: string, name: string)
```

#### http.Server:before_filter

This adds functions that will run before every request
The [http.BeforeFn](#httpbeforefn) returns a boolean and a [http.Response](#httpresponse), if the boolean is `true`, it will return the response instead of the hit route

```lua
app:before_filter(function(self: *http.Server): (boolean, http.Response)
  self.session:set_val("val", "test")
  if self.req.current_path ~= self:url_for("test") and self.session:get_val("val") == "test" then
    return true, self:redirect("/test")
  end
  return false, {}
end)
```

```lua
function http.Server:before_filter(fn: http.BeforeFn)
```

#### Supported HTTP Methods

```lua
## local methods = {"get", "post", "put", "patch", "delete"}
```

#### http.Server:#|method|#

These are routing functions where `method` could be one of the [supported http methods](#supported-http-methods)

```lua
local http = require "path.to.http"

local app = http.Server.new()

app:get(nil, "/", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "hello, world")
end)
```
- name: This can be provided to set a name for a route, usually to be used with the [http.Server:url_for](#httpserverurlfor) function
- route: The actual route that will be called
- action: The function to be called when the route is hit

```lua
function http.Server:#|method|#(name: facultative(string), route: string, action: http.ActionFn)
```

#### http.Server.UrlForOpts

Used to alter the returned url from [http.Server:url_for](#httpserverurl_for)

```lua
local http.Server.UrlForOpts = @record{
  route_params: hashmap(string, string),
  query_params: hashmap(string, string)
}
```

#### http.Server:url_for

This function returns the route of the relevant name
`opts` can be passed to the function to help build a url if it contains route params or you would like to add query params, see [http.Server.UrlForOpts](#httpserverurlforopts)

Examples:

```lua
app:get("get_params", "/get_params", function(self: *http.Server)
  local route_params: hashmap(string, string)
  route_params["id"]   = "10"
  route_params["name"] = "james"
  route_params["*"]    = "splat"

  local query_params: hashmap(string, string)
  query_params["id"]   = "10"
  query_params["name"] = "james"
  return self:html(200, ("<a href='%s'>link</a>"):format(self:url_for("params", {
    route_params = route_params,
    query_params = query_params
  })))
end)

app:get("params", "/params/:id/:name/*", function(self: *http.Server)
  return self:text(200, self.req.params["id"] .. " " .. self.req.params["name"] .. " " .. self.req.params["*"])
end)
-- Should return "/params/10/james/splat?id=10&name=james"
```

```lua
app:get(nil, "/", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, self:url_for("test"))
end)
-- will return "/really-long-name"

app:get("test", "/really-long-name", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "hello, world")
end)
```

```lua
function http.Server:url_for(name: string, opts: http.Server.UrlForOpts): string
```

#### http.Server:html

helper function for commonly returned [http.Response](#httpresponse) to specify the response is `html`

```lua
function http.Server:html(code: http.Status, html: string): http.Response
```

#### http.Server:json

helper function for commonly returned [http.Response](#httpresponse) to specify the response is `json`
-`body`: Can either be a string or a json serializable object

```lua
function http.Server:json(code: http.Status, body: overload(string, auto)): http.Response
```

#### http.Server:text

helper function for commonly returned [http.Response](#httpresponse) to specify the response is `text`

```lua
function http.Server:text(code: http.Status, text: string): http.Response
```

#### http.Server:redirect

helper function to specify that the return should be a redirect and redirect to `path`

```lua
app:get(nil, "/", function(self: *http.Server): http.Response
  return self:redirect(self:url_for("actual"))
end)

app:get("actual", "/actual-path", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "ok")
end)
```

```lua
function http.Server:redirect(path: string): http.Response
```

#### http.Server:error

helper function that returns a http text response with a 500 error code and your `msg`

```lua
function http.Server:error(msg: string): http.Response
```

#### http.csrf

```lua
local http.csrf = @record{}
```

#### http.csrf.generate_token

This function generates a csrf token that is stored in your session and returns it as a value
If a token already exists, it returns that and doesn't create a new one

```lua
app:before_filter(function(self: *http.Server): (boolean, http.Response)
  local token = http.csrf.generate_token(self)
  return false, {}
end)
```

```lua
function http.csrf.generate_token(self: *http.Server): string
```

#### http.csrf.validate_token

This function checks that there is a csrf token in your session and that the token passed in your request params matches it

```lua
app:post(nil, "/test", function(self: *http.Server)
  if not http.csrf.validate_token(self) then
    return self:text(403, "forbidden")
  end
  return self:text(200, "ok")
end)
```

```lua
function http.csrf.validate_token(self: *http.Server): boolean
```

#### http.Server:serve

This function starts the server
It should always be the last line of your file

```lua
function http.Server:serve()
```

#### http.MockRequestOpts

```lua
local http.MockRequestOpts = @record{
  method: string,
  params: hashmap(string, string),
  headers: hashmap(string, string),
  cookies: hashmap(string, string),
  session_vals: hashmap(string, string)
}
```

#### http.Server:mock_request

This function is meant for testing and helps you simulate requests to your server

```lua
function http.Server:mock_request(path: string, opts: http.MockRequestOpts): (http.Response, string)
```

#### http.Server.new

This function returns a new [http.Server](#httpserver) instance that will be used throughout your app

The `config` param can be ommited and default values will be used, it is of type [http.Config](#httpserverconfig)

```lua
local http = require "path.to.http"

local app = http.new({
  secret = os.getenv("SECRET"),
  session_name = "my_app"
})
```

```lua
function http.Server.new(config: http.Config): http.Server
```

To write to the client, the `write` method is called
Below is the default implementation

```lua
  s.write = function(self:*http.Server, s: string): (boolean, string)
    local written_bytes = send(self._fd, (@cstring)(s), #s, MSG_NOSIGNAL)
    if written_bytes == -1 then
      local err_msg = C.strerror(C.errno)
      return false, (@string)(err_msg)
    end
    return true, ""
  end
```

When a request does not match any of the routes you've defined, the `default_route` method will be called to create a response.
Below is the default implementation

```lua
  s.default_route = function(self: *http.Server)
    if self.req.current_path:match("./$") then
      local stripped = self.req.current_path:sub(1, #self.req.current_path - 1)
      return self:redirect(stripped)
    else
      return self:handle_404()
    end
  end
```

In the default `default_route`, the method `handle_404` is called when the path of the request did not match any routes.
Below is the default implementation

```lua
  s.handle_404 = function(self: *http.Server)
    return self:text(http.Status.NotFound, "Page or resource not found")
  end
```

### json.nelua

#### JsonNodeType enum

```lua
local JsonNodeType = @enum{
  NULL = 0,
  BOOLEAN,
  STRING,
  NUMBER,
  ARRAY,
  OBJECT
}
```

#### JsonNode record

Representing an individual json node after parsing

```lua
local JsonNode = @record{
  val: union{
    bol: boolean, -- accounts for NULL
    str: string,
    num: number,
    arr: sequence(JsonNode),
    obj: hashmap(string, JsonNode)
  },
  type: JsonNodeType
}
```

Example usage:

```lua
if node:is_obj() then
  local obj = node:get_obj()
  -- Work with object
elseif node:is_arr() then
  local arr = node:get_arr()
  -- Work with array
elseif node:is_str() then
  local str = node:get_str()
  -- Work with string
elseif node:is_num() then
  local num = node:get_num()
  -- Work with number
elseif node:is_bool() then
  local bool = node:get_bool()
  -- Work with boolean
elseif node:is_null() then
  -- Handle null case
end
```

#### JsonNode:is

Returns a string stating the node type

```lua
function JsonNode:is(): string
```

#### JsonNode:is_obj

Returns true if node is an object

```lua
function JsonNode:is_obj(): boolean
```

#### JsonNode:is_num

Returns true if node is a number

```lua
function JsonNode:is_num(): boolean
```

#### JsonNode:is_str

Returns true if node is a string

```lua
function JsonNode:is_str(): boolean
```

#### JsonNode:is_arr

Returns true if node is an array

```lua
function JsonNode:is_arr(): boolean
```

#### JsonNode:is_bool

Returns true if node is a boolean

```lua
function JsonNode:is_bool(): boolean
```

#### JsonNode:is_null

Returns true if node is a null value

```lua
function JsonNode:is_null(): boolean
```

#### JsonNode:get_obj

Returns a hashmap of strings to JsonNodes from the JsonNode

```lua
function JsonNode:get_obj(): hashmap(string, JsonNode)
```

#### JsonNode:get_num

Returns a number from the JsonNode

```lua
function JsonNode:get_num(): number
```

#### JsonNode:get_str

Returns a string from the JsonNode

```lua
function JsonNode:get_str(): string
```

#### JsonNode:get_arr

Returns an array from the JsonNode

```lua
function JsonNode:get_arr(): sequence(JsonNode)
```

#### JsonNode:get_bool

Returns a boolean from the JsonNode

```lua
function JsonNode:get_bool(): boolean
```

#### JsonNode:get_null

Returns a null value(false) from the JsonNode

```lua
function JsonNode:get_null(): boolean
```

#### json record

```lua
local json = @record{}
```

#### json.JsonNode

```lua
local json.JsonNode = JsonNode
```

#### json.parse_file

Parses a JSON file into a JsonNode structure.

```lua
local json = require "path.to.json"

local node, err = json.parse_file("config.json")
if err ~= "" then
  print("Parse error:", err)
  return
end

-- Access the node data
if node:is_obj() then
  local obj = node:get_obj()
  -- Process object
end
```

```lua
function json.parse_file(file_path: string): (JsonNode, string)
```

#### json.parse_string

Parses a JSON string into a JsonNode structure.

```lua
local json = require "path.to.json"

local content = [=[
{
  "name": "John",
  "active": true,
reference "data": [1, 2, 3]
}
]=]

local node, err = json.parse_string(content)
if err ~= "" then
  print("Parse error:", err)
  return
end
```

```lua
function json.parse_string(content: string): (JsonNode, string)
```

#### json.parse_string_to_record

Directly parses a JSON string into a nelua record.

```lua
local json = require "path.to.json"

local Config = @record{
  debug: boolean,
  port: integer,
  hosts: sequence(string),
  metadata: record{
    version: string,
    updated_at: string
  }
}

local content = [=[
{
  "debug": true,
  "port": 8080,
  "hosts": ["localhost", "127.0.0.1"],
  "metadata": {
    "version": "1.0.0",
    "updated_at": "2024-02-12"
  }
}
]=]

local config, err = json.parse_string_to_record(content, Config)
if err ~= "" then
  print("Failed to parse config:", err)
  return
end
```

Type Mapping:
- JSON object -> record
- JSON array -> any contiguous data structure
- JSON string -> string
- JSON number -> number
- JSON boolean -> boolean
- JSON null -> false

```lua
function json.parse_string_to_record(content: string, rec: type): (#[rec.value]#, string)
```

#### json.parse_file_to_record

Directly parses a JSON file into a nelua record, see [json.parse_string_to_record](#jsonparse_string_to_record) for more information

```lua
function json.parse_file_to_record(file_path: string, rec: type)
```

#### json.serialize_record

Converts a nelua record into a JSON string.

```lua
local json = require "path.to.json"

local User = @record{
  name: string,
  age: integer,
  active: boolean,
  tags: sequence(string)
}

local user: User = {
  name = "Alice",
  age = 25,
  active = true,
  tags = {"admin", "staff"}
}

local json_str = json.serialize_record(user)
print(json_str)
-- Prints {"name": "Alice", "age": 25, "active": true, "tags": ["admin", "staff"]}
```

NB: All record fields must be of supported types

```lua
function json.serialize_record(rec: auto): string
```

#### json.pretty_serialize_record

Converts a nelua record into a pretty JSON string.

```lua
local json = require "path.to.json"

local User = @record{
  name: string,
  age: integer,
  active: boolean,
  tags: sequence(string)
}

local user: User = {
  name = "Alice",
  age = 25,
  active = true,
  tags = {"admin", "staff"}
}

local json_str = json.pretty_serialize_record(user, 1)
print(json_str)
--[=[Prints
{
    "name": "Alice",
    "age": 25,
    "active": true,
    "tags": [
        "admin",
        "staff"
    ]
}
]=]
```

NB: All record fields must be of supported types

```lua
function json.pretty_serialize_record(rec: auto, indent: uinteger): string
```

### send_request.nelua

#### SendRequest

```lua
local SendRequest = @record{
  url: string,
  method: string,
  headers: hashmap(string, string),
  body: hashmap(string, string)
}
```

#### SendResponse

```lua
local SendResponse = @record{
  body: string,
  status: string,
  headers: hashmap(string, string)
}
```

#### send_request

This function takes a [SendRequest](#sendrequest) object, makes either an http or https request and returns a [SendResponse](#sendresponse) object
Keep note that this function will block whatever route you call it on until the request is completed

```lua
local result, err = send_request({
  url = "https://dummy-json.mock.beeceptor.com/posts/1",
  method = "get"
})
```

### utils.nelua

#### Utils

```lua
local Utils = @record{}
```

#### Utils.url_escape

This function escapes a string so it is url friendly

```lua
print(Utils.url_escape("hello world"))
-- hello%20world
```

```lua
function Utils.url_escape(s: string): string
```

#### Utils.url_unescape

This function unescapes a url string

```lua
print(Utils.url_escape("hello%20world"))
-- hello world
```

```lua
function Utils.url_unescape(s: string): string
```

#### Utils.slugify

This functions converts a string to a slug suitable for a url

```lua
print(Utils.slugify("Hello, World! Welcome to ChatGPT: AI for Everyone 🚀"))
-- hello-world-welcome-to-chatgpt-ai-for-everyone
```

```lua
function Utils.slugify(s: string): string
```

#### Utils.sign

This function is what is used to sign session data

```lua
print(Utils.sign("key", "data"))
-- 5031fe3d989c6d1537a013fa6e739da23463fdaec3b70137d828e36ace221bd0
```

```lua
function Utils.sign(key: cstring, data: cstring): string
```

#### Utils.b64_encode(input: string): string

This function encodes a string to base64

```lua
print(Utils.b64_encode("hello world"))
-- aGVsbG8gd29ybGQ=
```

```lua
function Utils.b64_encode(input: string): string
```

#### Utils.b64_decode(input: string): string

This function decodes a string from base64

```lua
print(Utils.b64_encode("aGVsbG8gd29ybGQ="))
-- hello world
```

```lua
function Utils.b64_decode(data: string): string
```

---
  
## Acknowledgement

This library is heavliy inspired by the [lapis](https://github.com/leafo/lapis) and a bit by the [echo](https://github.com/labstack/echo) web frameworks
