local fs = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

m = Map("netcontrol", translate("NetControl 网络管家"),
    translate("按设备设置每日允许上网时段、循环休息和上下行限速。设备通过 MAC 地址识别，建议先在 DHCP 静态租约中固定设备 IP。时间控制通过独立 nftables 表实现，不覆盖 OpenClash/fw4 规则。"))

s = m:section(TypedSection, "device", translate("设备规则"))
s.addremove = true
s.anonymous = false
s.sortable = true
s.template = "cbi/tblsection"

name = s:option(Value, "name", translate("设备名称"))
name.rmempty = false
name.placeholder = "例如：孩子的手机"

enabled = s:option(Flag, "enabled", translate("启用"))
enabled.default = "0"
enabled.rmempty = false

mac = s:option(Value, "mac", translate("设备 MAC 地址"))
mac.datatype = "macaddr"
mac.rmempty = false
mac.placeholder = "AA:BB:CC:DD:EE:FF"

ip = s:option(Value, "ip", translate("设备 IPv4 地址（限速用）"))
ip.datatype = "ip4addr"
ip.rmempty = true
ip.placeholder = "例如：192.168.1.123"

start = s:option(Value, "start", translate("允许开始时间"))
start.default = "07:00"
start.rmempty = false
start.placeholder = "07:00"

finish = s:option(Value, "finish", translate("允许结束时间"))
finish.default = "21:30"
finish.rmempty = false
finish.placeholder = "21:30"

work = s:option(Value, "work_min", translate("连续上网分钟"))
work.datatype = "uinteger"
work.default = "45"
work.rmempty = false
work.description = translate("填 0 表示关闭循环休息")

rest = s:option(Value, "rest_min", translate("休息分钟"))
rest.datatype = "uinteger"
rest.default = "15"
rest.rmempty = false

down = s:option(Value, "download_kbit", translate("下载限速 kbit/s"))
down.datatype = "uinteger"
down.default = "5000"
down.rmempty = true
down.description = translate("例如 5000 约等于 5 Mbps；留空或 0 表示不限制")

up = s:option(Value, "upload_kbit", translate("上传限速 kbit/s"))
up.datatype = "uinteger"
up.default = "1000"
up.rmempty = true
up.description = translate("例如 1000 约等于 1 Mbps；留空或 0 表示不限制")

local status = m:section(SimpleSection)
status.title = translate("状态与说明")
local st = status:option(DummyValue, "status", translate("运行状态"))
st.rawhtml = true
st.cfgvalue = function(self, section)
    local out = sys.exec("/usr/sbin/netcontrol status 2>/dev/null")
    out = (out or "状态暂不可用"):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\n", "<br />")
    return out
end

return m
