local ds18b20 = require('ds18b20')

local PIN_THERM = 3


local function sendfile(fname, sock)
  sock:send(string.format("HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\nConnection: close\r\n\r\n", file.stat(fname).size))
  local fd = file.open(fname, "r")

  local function send(lsock)
    local chunk = fd:read(1024)
    if chunk then
      lsock:send(chunk)
    else
      lsock:close()
      fd:close()
      fd = nil
    end
  end

  sock:on("sent", send)
  send(sock)
end

local function receiver(sock, data)
  -- At this stage data size is not greater than MTU.
  if data:match("^GET /ping HTTP") then
    sock:send("HTTP/1.1 200 OK\r\nConnection: close\r\n\r\npong\n")

  elseif data:match("^GET / HTTP") then
    -- Return here to prevent socket cleanup below - cleanup is handled by sendfile().
    return sendfile("index.html", sock)

  elseif data:match("^GET /t HTTP") then
    local function readtemp(temps)
      local addr, temp = next(temps)
      if type(temp) == 'string' then
        sock:send(string.format("HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n%s", temp))
      else
        sock:send("HTTP/1.1 500 OK\r\nContent-Type: text/plain\r\n\r\nerror reading temperature")
      end
    end

    ds18b20:read_temp(readtemp, PIN_THERM, ds18b20.C)

  else
    sock:send("HTTP/1.1 404 OK\r\nConnection: close\r\n\r\nNot Found")
  end

  sock:on("sent", function(s)
    s:close()
  end)
end

return function(sock)
  local _, ip = sock:getpeer()

  print(string.format("Connection from %s; heap %s", ip, node.heap()))
  sock:on("receive", receiver)

  -- Drop this module from cache, so that it is completely reloaded the next
  -- time.
  package.loaded[module] = nil
end

