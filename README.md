# http.nelua

A HTTP 1.1 webserver library for nelua

## Features
- Routing
- Sessions
- CSRF security
- External http requests
- Builtin JSON library


## Requirements
- [nelua](https://nelua.io/)
- [nlpm](https://github.com/kmafeni04/nlpm)
- openssl
- glibc poll
- glibc unistd
- glibc socket

## How to install
Add to your nlpm package dependencies
```lua
{
  name = "http-nelua",
  repo = "https://github.com/kmafeni04/http-nelua",
  version = "COMMIT-HASH-OR-TAG",
},
```
Run `nlpm install`

## Quick start

```lua
local http = require "http"

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

See [json-nelua](https://github.com/kmafeni04/json-nelua)

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
  print(resp:tostring()) -- "HTTP/1.1 200 OK\r\nServer: http-nelua\r\nDate: Thu, 17 Apr 2025 19:23:00 GMT\r\nContent-type: text/plain\r\nContent-Length: 4\r\n\r\nok\r\n"
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
    return self:error()
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
    return self:error()
  end
  return resp
end)
```

```lua
function http.Response:set_cookie(c: http.Cookie):  string
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

#### http.Session:get_val(name: string): string

This function is used to get values that are stored in the sesssion

```lua
app:get(nil, "/test", function(self: *http.Server)
  local name = self.session:get_val("name")
  local age = self.session:get_val("age")
  return self:text(200, "ok")
end)
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
- log: This determines whether the server will log the request information to the console, default is [http.TriBool](#httptribool).NULL

```lua
local http.Config = @record{
  port: uinteger,
  bind_host: string,
  secret: string,
  session_name: string,
  log: http.TriBool
}
```

#### http.BeforeFn

Type Alias describing the function signature of before functions called in the [http.Server:before_filter](#httpserverbefore_filter)

```lua
local http.BeforeFn = @function(self: *http.Server): (boolean, http.Response)
```

#### http.ActionFn

Type Alias describing the function signature of action functions called on a [http.Server:#|method|#](#httpservermethod)

```lua
local http.ActionFn = @function(self: *http.Server): http.Response
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

#### Supported mime types

These are the mime types that will be matched against when a static file is requested from the server alongside their respective content type

```lua
local mime_types = inline_map!(string, string, {
  ["aac"] = "audio/aac",
  ["abw"] = "application/x-abiword",
  ["apng"] = "image/apng",
  ["arc"] = "application/x-freearc",
  ["avif"] = "image/avif",
  ["avi"] = "video/x-msvideo",
  ["azw"] = "application/vnd.amazon.ebook",
  ["bin"] = "application/octet-stream",
  ["bmp"] = "image/bmp",
  ["bz"] = "application/x-bzip",
  ["bz2"] = "application/x-bzip2",
  ["cda"] = "application/x-cdf",
  ["csh"] = "application/x-csh",
  ["css"] = "text/css",
  ["csv"] = "text/csv",
  ["doc"] = "application/msword",
  ["docx"] = "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  ["eot"] = "application/vnd.ms-fontobject",
  ["epub"] = "application/epub+zip",
  ["gz"] = "application/gzip",
  ["gif"] = "image/gif",
  ["htm"] = "text/html",
  ["html"] = "text/html",
  ["ico"] = "image/vnd.microsoft.icon",
  ["ics"] = "text/calendar",
  ["jar"] = "application/java-archive",
  ["jpeg"] = "image/jpeg",
  ["jpg"] = "image/jpeg",
  ["js"] = "text/javascript",
  ["json"] = "application/json",
  ["jsonld"] = "application/ld+json",
  ["mid"] = "audio/midi",
  ["midi"] = "audio/x-midi",
  ["mjs"] = "text/javascript",
  ["mp3"] = "audio/mpeg",
  ["mp4"] = "video/mp4",
  ["mpeg"] = "video/mpeg",
  ["mpkg"] = "application/vnd.apple.installer+xml",
  ["odp"] = "application/vnd.oasis.opendocument.presentation",
  ["ods"] = "application/vnd.oasis.opendocument.spreadsheet",
  ["odt"] = "application/vnd.oasis.opendocument.text",
  ["oga"] = "audio/ogg",
  ["ogv"] = "video/ogg",
  ["ogx"] = "application/ogg",
  ["opus"] = "audio/ogg",
  ["otf"] = "font/otf",
  ["png"] = "image/png",
  ["pdf"] = "application/pdf",
  ["php"] = "application/x-httpd-php",
  ["ppt"] = "application/vnd.ms-powerpoint",
  ["pptx"] = "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  ["rar"] = "application/vnd.rar",
  ["rtf"] = "application/rtf",
  ["sh"] = "application/x-sh",
  ["svg"] = "image/svg+xml",
  ["tar"] = "application/x-tar",
  ["tif"] = "image/tiff",
  ["tiff"] = "image/tiff",
  ["ts"] = "video/mp2t",
  ["ttf"] = "font/ttf",
  ["txt"] = "text/plain",
  ["vsd"] = "application/vnd.visio",
  ["wav"] = "audio/wav",
  ["weba"] = "audio/webm",
  ["webm"] = "video/webm",
  ["webp"] = "image/webp",
  ["woff"] = "font/woff",
  ["woff2"] = "font/woff2",
  ["xhtml"] = "application/xhtml+xml",
  ["xls"] = "application/vnd.ms-excel",
  ["xlsx"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  ["xml"] = "application/xml",
  ["xul"] = "application/vnd.mozilla.xul+xml",
  ["zip"] = "application/zip",
  ["3gp"] = "video/3gpp; audio/3gpp",
  ["3g2"] = "video/3gpp2; audio/3gpp2",
  ["7z"] = "application/x-7z-compressed",
})
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

Helper function that returns a http text response with a 500 error code and message "Internal Server Error"

```lua
function http.Server:error(): http.Response
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

The `config` param can be ommited and default values will be used, it is of type [http.Config](#httpconfig)

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
If no method is passed, it defaults to "get"
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

#### Utils.b64_encode

This function encodes a string to base64

```lua
print(Utils.b64_encode("hello world"))
-- aGVsbG8gd29ybGQ=
```

```lua
function Utils.b64_encode(input: string): string
```

#### Utils.b64_decode

This function decodes a string from base64

```lua
print(Utils.b64_encode("aGVsbG8gd29ybGQ="))
-- hello world
```

```lua
function Utils.b64_decode(data: string): string
```

#### Utils.trim_wspace

Trims whitespae off from the ends of a string

```lua
print(Utils.trim_wspace("   hello   "))
-- hello
```

```lua
function Utils.trim_wspace(s: string)
```

---
  
## Acknowledgement

This library is heavliy inspired by the [lapis](https://github.com/leafo/lapis) and a bit by the [echo](https://github.com/labstack/echo) web frameworks
