local function init_sta()
  local cfg = {
    ssid = "SSID",
    pwd = "PSK",
    auto = true,
    save = true,
  }

  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(s)
    print(string.format("WiFi connected to ssid %s, bssid %s, channel %s", s.SSID, s.BSSID, s.channel))
  end)

  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(s)
    print(string.format("WiFi disconnected from ssid %s: %s", s.SSID, s.reason))
  end)

  wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
    print("WiFi DHCP timeout...")
  end)

  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(s)
    print(string.format("WiFi: got IP %s/%s via %s", s.IP, s.netmask, s.gateway))
  end)

  wifi.setphymode(wifi.PHYMODE_N)
  wifi.setmode(wifi.STATION, true)
  wifi.sta.sleeptype(wifi.MODEM_SLEEP)
  
  local ssid, pwd = wifi.sta.getconfig()
  if cfg.ssid ~= ssid or cfg.pwd ~= pwd then
    wifi.sta.config(cfg)
  end
end


init_sta()

local srv = net.createServer(net.TCP, 1)
srv:listen(80, function(sock)
  require("http_handler")(sock)
end)

