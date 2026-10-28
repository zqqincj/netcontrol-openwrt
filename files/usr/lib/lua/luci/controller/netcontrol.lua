module("luci.controller.netcontrol", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/netcontrol") then
        return
    end
    entry({"admin", "network", "netcontrol"}, cbi("netcontrol"), _("NetControl 网络管家"), 80).dependent = true
end
