# NetControl 0.1.2 — OpenWrt 25.12.5 / RAX3000M

NetControl is a LuCI app prototype for per-device internet time windows, work/rest cycles, and IPv4 upload/download shaping. It uses UCI, a separate `inet netcontrol` nftables table, and `tc`/IFB. It does not edit `/etc/config/firewall`, OpenClash YAML, or MosDNS.

## Important delivery status

This directory is the complete **package source**, not a prebuilt router-installable `.apk`. OpenWrt 25.12 uses APK v3 packages. A valid package must be built with the matching OpenWrt 25.12.5 SDK/package tools; this environment did not successfully obtain that SDK, so no installable `.apk` is claimed here. Do not rename this ZIP/TAR to `.apk` or upload it as one.

## Easiest build path (GitHub web UI; no SSH)

This source includes `.github/workflows/build-apk.yml`. To build an APK without using SSH:

1. Create a private GitHub repository in your browser.
2. Upload the contents of this source folder to the repository (including `.github/workflows/build-apk.yml`).
3. Open the repository's **Actions** tab and enable Actions if prompted.
4. Select **Build OpenWrt 25.12.5 APK** → **Run workflow**.
5. When it finishes, open the run and download the artifact named `netcontrol-openwrt-25.12.5-mediatek-filogic`.

The workflow downloads the official SDK and checks its SHA-256 against the checksum file published in the same official OpenWrt release directory. The artifact is a build output, not proof that the package has been tested on a physical router. Review the dependency list and test on a non-critical device first.

## Build the APK manually with the official matching SDK


On a Linux x86-64 build machine, download and extract the official SDK for `25.12.5 / mediatek / filogic` from:

`https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/filogic/`

Copy this package directory into the SDK's `package/` directory as `package/luci-app-netcontrol`, then run:

```sh
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make package/luci-app-netcontrol/compile V=s
```

The generated APK should appear under `bin/packages/aarch64_cortex-a53/luci/` (verify actual output path and package architecture in the SDK).

## Install on the router

A `.apk` is the only correct package format for OpenWrt 25.12.5. The standard LuCI Software page typically installs packages from configured feeds; it may not provide a local APK upload control. If your firmware's Software page has an upload/install-local-package control, upload the **built APK** there. If it does not, a web-only install is not possible with stock LuCI alone; do not upload this source archive as a package. A trusted custom package feed or a router-side package install command is then required.

Dependencies are intentionally declared in the package metadata:
- `luci-base`, `tc-full`
- `kmod-ifb`, `kmod-sched-core`, `kmod-sched-htb`, `kmod-sched-ingress`, `kmod-sched-act-mirred`, `kmod-sched-u32`

Kernel modules must match the router's exact kernel build. Do not force-install incompatible kmods.

## First setup

After installation, open **Network → NetControl 网络管家**. A disabled example device is pre-created so the package cannot accidentally block a device on first boot.

For each device:
1. Reserve its IPv4 address under **Network → DHCP and DNS → Static Leases**.
2. Enter its MAC address and reserved IPv4 address.
3. Enable the rule and configure start/end time.
4. Set work/rest minutes; set work minutes to `0` to disable cycling.
5. Set download/upload in kbit/s; blank or `0` means no limit.

## Current implementation details and limitations

- Time enforcement uses the device MAC in the `inet netcontrol` forward hook. It blocks forwarded IPv4/IPv6 packets from that device but leaves access to the router itself available. Local LAN traffic may be affected if it is routed through the forward hook; test before relying on it.
- Schedule is evaluated once per minute. Router time/timezone must be correct.
- A work/rest cycle starts when the daemon first sees an enabled device and persists its anchor in `/etc/netcontrol/state/`. It is a wall-clock cycle, not a detector of actual game/app activity. After a restart, the saved anchor is retained.
- Speed shaping currently supports IPv4 addresses only. Download shaping is attached to the LAN bridge egress; upload shaping uses a dedicated IFB device.
- Existing root or ingress traffic-control qdiscs are not intentionally overwritten. If another QoS/SQM system owns those qdiscs, the corresponding direction is skipped and logged. The status page reports a general status, not a full per-direction success audit.
- Software/hardware flow offloading can bypass some per-device firewall accounting on some builds. Test with the router's current flow-offload settings; if a blocked device still passes traffic, turn off flow offloading and retest before relying on the schedule.
- This is a first prototype and has not been run on the user's physical RAX3000M. Verify firewall and speed-limit behavior on a test device before enabling important policies.
- The app manages its own nftables table. It does not flush or replace the main fw4 ruleset and does not edit OpenClash or MosDNS.

## Uninstall / recovery

Use LuCI's package manager to remove `luci-app-netcontrol`. The package pre-removal hook stops the service and deletes only the `inet netcontrol` table and qdiscs marked as owned by NetControl. Configuration `/etc/config/netcontrol` is preserved as a package conffile where APK supports conffiles. Review it before reinstalling.

## License

MIT
