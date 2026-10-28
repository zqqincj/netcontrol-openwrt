include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-netcontrol
PKG_VERSION:=0.1.2
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=NetControl contributors

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-netcontrol
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=NetControl Network Time and Speed Manager
  DEPENDS:=+luci-base +luci-compat +tc-full +kmod-ifb +kmod-sched-core +kmod-sched-htb +kmod-sched-ingress +kmod-sched-act-mirred +kmod-sched-u32
  PKGARCH:=all
endef

define Package/luci-app-netcontrol/description
 LuCI app for per-device internet schedules, cyclic rest breaks, and IPv4 upload/download shaping.
endef

define Build/Compile
endef

define Package/luci-app-netcontrol/conffiles
/etc/config/netcontrol
endef

define Package/luci-app-netcontrol/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || { /etc/init.d/netcontrol enable; /etc/init.d/netcontrol start; }
exit 0
endef

define Package/luci-app-netcontrol/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || { /etc/init.d/netcontrol stop; /etc/init.d/netcontrol disable; }
exit 0
endef

define Package/luci-app-netcontrol/install
	$(CP) ./files/* $(1)/
	chmod 0755 $(1)/etc/init.d/netcontrol $(1)/usr/sbin/netcontrol
endef

$(eval $(call BuildPackage,luci-app-netcontrol))
