# http.nelua

A sufficiently featured webserver for nelua

## Quick start

```lua
local http = require "path.to.http"

local app = http.new()

app:get(nil, "/", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "hello, world")
end)

app:serve()
```

## Note

This library is still in development and I do not know all the edge cases, so please report any bugs you come across and I'll take a look

## API

### Functions

#### http.new(config: http.Config): http.Server

This function returns a new [http.Server](#httpserver) instance that will be used throughout your app

The `config` param can be ommited and default values will be used and is of type [http.Config](#httpconfig)

```lua
local http = require "path.to.http"

local app = http.new({
  threads = 7,
  secret = os.getenv("SECRET"),
  session_name = "my_app"
})
```

#### http.Server:serve()

This function starts the server
It should always be the last line of your file

#### http.Server:set_static(dir: string, name: string)

This sets the directory when static files will be read from as well as the name that will be used for routing

```lua
local app = http.new()

app:set_static("./static", "static")

app:get(nil, "/", function(self: *http.Server): http.Response
  return self:html(200, '<link rel="stylesheet" href="/static/test.css" />')
end)
```

#### http.Server:xxx(name: facultative(string), route: string, action: http.ActionFn): http.Response

These are routing functions where `xxx` could be one of {"get", "post", "put", "patch", "delete"}

```lua
local http = require "path.to.http"

local app = http.new()

app:get(nil, "/", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "hello, world")
end)
```
- name: This can be provided to set a name for a route, usually to be used with the [http.Server:url_for](#httpserverurlforname-string-string) function
- route: The actual route that will be called
- action: The function to be called when the route is hit

#### http.Server:before_filter(fn: http.BeforeFn)

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
#### http.Server:url_for(name: string): string

This function returns the route of the relevant name

```lua
app:get(nil, "/", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, self:url_for("test"))
end)
-- will return "/really-long-name"

app:get("test", "/really-long-name", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "hello, world")
end)
```

#### http.Server:html(code: http.Status, html: string): http.Response

helper function for commonly returned [http.Response](#httpresponse) to specify the response is `html`

#### http.Server:json(code: http.Status, json: string): http.Response

helper function for commonly returned [http.Response](#httpresponse) to specify the response is `json`

#### http.Server:text(code: http.Status, text: string): http.Response

helper function for commonly returned [http.Response](#httpresponse) to specify the response is `text`

#### http.Server:redirect(path: string): http.Response

helper function to specify that the return should be a redirect and redirect to `path`

```lua
app:get(nil, "/", function(self: *http.Server): http.Response
  return self:redirect(self:url_for("actual"))
end)

app:get("actual", "/actual-path", function(self: *http.Server): http.Response
  return self:text(http.Status.OK, "ok")
end)
```

#### http.Server.default_route: http.ActionFn

When a request does not match any of the routes you've defined, the `default_route` function will be called to create a response

This function can be overriden to provide your own custom response

The default functionality is:

```lua
function(self: *http.Server): http.Response
  if self.req.current_path:match("./$") then
    local stripped = self.req.current_path:sub(1, #self.req.current_path - 1)
    return self:redirect(stripped)
  else
    return self:handle_404()
  end
end
```

#### http.Server.handle_404: http.ActionFn

In the default [http.Server.default_route](#httpserverdefaultroute-httpactionfn) function, the function `http.Server.handle_404` is called when the path of the request did not match any routes

This function can be overriden to provide your own custom response

The default functionality is:

```lua
function(self: *http.Server): http.Response
  return http.Response{
    content = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Document</title>
</head>
<body>
  <h1>Page or resource not found</h1>
</body>
</html>]],
    status = 404,
  }
end
```

#### Session:set_val(name: string, val: string): (boolean, string)

This function is used to set values that will be stored in the sesssion

```lua
app:get(nil, "/", function(self: *http.Server)
  self.session:set_val("name", "james")
  self.session:set_val("age", "10")
  return self:text(200, "ok")
end)
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

#### http.Response:tostring(): string

This function converts your response into a http request string

```lua
app:get(nil, "/test", function(self: *http.Server)
  local resp = self:text(200, "ok")
  print(resp:tostring) -- "HTTP/1.1 200 OK\r\nServer: http-nelua\r\nDate: Thu, 17 Apr 2025 19:23:00 GMT\r\nContent-type: text/plain\r\nContent-Length: 4\r\n\r\nok\r\n"
  return resp
end)
```
#### http.Response:set_cookie(c: http.Cookie): (boolean, string)

Sets a cookie to be sent with the response

```lua
app:get(nil, "/", function(self: *http.Server)
  local resp = self:text(200, "ok")
  local ok, err = resp:set_cookie({
    name = "name",
    val = "james"
  })
  return resp
end)
```

#### http.Server:get_cookie(name: string): string

Gets a cookie from the request header

```lua
app:get(nil, "/test", function(self: *http.Server)
  local name = self:get_cookie("name")
  return self:text(200, "ok")
end)
```

#### http.csrf.generate_token(self: *http.Server): string

This function generate a csrf token that is stored in your session and also returns

If a token already exists, it returns that and doesn't create a new one

```lua
app:before_filter(function(self: *http.Server): (boolean, http.Response)
  local token = http.csrf.generate_token(self)
  return false, {}
end)
```

#### http.csrf.validate_token(self: *http.Server): boolean

This function checks that there is a csrf token in your session and that the token passed in your request params matches it

```lua
app:post(nil, "/test", function(self: *http.Server)
  if not http.csrf.validate_token(self) then
    return self:text(403, "forbidden")
  end
  return self:text(200, "ok")
end)
```

#### http.send_request(req: SendRequest): (SendResponse, string)

This function takes a [SendRequest](#sendrequest), makes either an http or https request and returns a [SendResponse](#sendresponse)

Keep note that this function is not multithreaded and will block whatever route you call it on until the request is processed

```lua
local result, err = http.send_request({
  url = "https://dummy-json.mock.beeceptor.com/posts/1",
  method = "get"
})
```

#### http.utils.url_escape(s: string): string

This function escapes a string so it is url friendly

```lua
print(utils.url_escape("hello world"))
-- hello%20world
```

#### http.utils.url_unescape(s: string): string

This function unescapes a url string

```lua
print(utils.url_escape("hello%20world"))
-- hello world
```

#### http.utils.slugify(s: string): string

This functions converts a string to a slug suitable for a url

```lua
print(utils.slugify("Hello, World! Welcome to ChatGPT: AI for Everyone 🚀"))
-- hello-world-welcome-to-chatgpt-ai-for-everyone
```

#### http.utils.sign(key: cstring, data: cstring): string

This function is what is used to sign the session data

```lua
print(utils.sign("key", "data"))
-- 5031fe3d989c6d1537a013fa6e739da23463fdaec3b70137d828e36ace221bd0
```

#### http.utils.b64_encode(input: string): string

This function encodes a string to base64

```lua
print(utils.b64_encode("hello world"))
-- aGVsbG8gd29ybGQ=
```

#### http.utils.b64_decode(input: string): string

This function decodes a string from base64

```lua
print(utils.b64_encode("aGVsbG8gd29ybGQ="))
-- hello world
```

### Types

#### http.NotSetOrBool

This is an `enum` that is used in place of a boolean to determine when a value is actually not set instead of automatically being `false`

```lua
local http.NotSetOrBool = @enum{
  NOT_SET = 0,
  TRUE,
  FALSE
}
```

#### http.Config

```lua
local http.Config = @record{
  port: uinteger,
  threads: uinteger,
  bind_host: string,
  secret: string,
  session_name: string,
  logging: http.NotSetOrBool
}
```
- port: The port you want the server to run on, default is `8080`
- threads: The number of threads used, default is `2`
- bind_host: The interface the server will bind to, default is `0.0.0.0`
- secret: This is used to sign your session, default is `please-change-me`
- session_name: Name of cookie used to store the session, default is `http_session`
- logging: This determines whether the server will log the request information to the console, default is [http.NotSetOrBool](#httpnotsetorbool).NOT_SET

#### http.Server

This is internal reprsentation of the server record

You will rarely have to interact with it directly as functions have already been provided

```lua
local http.Server = @record{
  config: http.Config,
  static_dir: string,
  static_name: string,
  routes: hashmap(string, Route),
  var_routes: hashmap(string, Route),
  named_routes: hashmap(string, string),
  req: record{
    headers: hashmap(string, string),
    current_path: string,
    params: hashmap(string, string),
  },
  default_route: http.ActionFn,
  handle_404: http.ActionFn,
  session: Session,
  before_funcs: sequence(http.BeforeFn),
}
```

#### Route

Internal record used to map an http method to an action function for a given route

```lua
local Route = @record{
  methods: hashmap(string, http.ActionFn)
}
```

#### Session

This record is used to manage the session of the server

```lua
local Session = @record{
  vals: hashmap(string, string),
  send: boolean
}
```

#### http.ActionFn

This is a type alias that maps to `@function(self: *http.Server): http.Response`

#### http.BeforeFn

This is a type alias that maps to `@function(self: *http.Server): (boolean, http.Response)`

#### http.Response

This is what is used to build the html string that is sent when an [http.ActionFn](#httpactionfn) is called

```lua
local http.Response = @record{
  content: string,
  status: http.Status,
  content_type: string,
  headers: hashmap(string, string),
  cookies: sequence(http.Cookie)
}
```

#### http.Cookie

This record is used to map out the values of a cookie

```lua
local http.Cookie = @record{
  name: string,
  val: string,
  path: string,
  domain: string,
  expires: string,
  secure: http.NotSetOrBool,
  httpOnly: http.NotSetOrBool
}
```

#### http.utils

This is just a collection of differnt utility functions

#### http.csrf

This is just a collection of csrf related functions

#### SendRequest

The structure that is passed to the [http.send_request](#httpsendrequestreq-sendrequest-sendresponse-string) function

```lua
local SendRequest = @record{
  url: string,
  method: string,
  headers: hashmap(string, string),
  body: hashmap(string, string)
}
```

#### SendResponse

The structure that is returned from the [http.send_request](#httpsendrequestreq-sendrequest-sendresponse-string) function

```lua
local SendResponse = @record{
  body: string,
  status: string,
  headers: hashmap(string, string)
}
```

## Acknowledgement

This library is heavliy inspired by the [lapis](https://github.com/leafo/lapis) and a bit by the [echo](https://github.com/labstack/echo) web frameworks
