# imac-bridge
A simple shell script to configure a Raspberry Pi as a
WiFi-to-Ethernet bridge. Though the name suggests compatibility with
only iMacs, it will work with any Mac with Ethernet, or any other
Ethernet device for that matter. The script also configures `carl` from
[Crypto Ancienne](https://github.com/classilla/cryanc) so that
Classilla on the Mac can browse modern websites.

# Usage
Obviously, whatever Pi you use has to have both a WiFi and an Ethernet
interface. As such, the Pi Zero is probably not a good choice. I have
tested it on a Pi 4 and a Pi 1. It's slow to install on a Pi 1, but
the bridge and `carl` work great once they're up and running.

Set up a Raspberry Pi with Raspberry Pi OS Lite. Enable SSH and
configure the WiFi to connect to your desired network. There are many
resources on the rest of the Web that explain how to do this, so I'm not
going to explain it here.

Once the Pi is on WiFi and SSH is enabled, run this command at the
prompt:

```
wget https://github.com/liamhays/imac-bridge/raw/main/install_imac_bridge.sh

bash install_imac_bridge.sh
```

The script will update the system, install some necessary packages,
configure WiFi-to-Ethernet bridge, and set up `carl`. Once it's
finished, reboot the Pi. It should now be a bridge, so plug in the Mac
and test. 

Do not run the script more than once on one system. This script is
also designed to be run on a fresh installation---it will *probably*
work on an existing installation, but your mileage may vary.

`carl` always runs in the background on the Pi, controlled by
[`micro_inetd`](https://acme.com/software/micro_inetd/), regardless of
whether or not you use Classilla. If you don't, you can just use the
Pi as a normal bridge.

# Configuring Classilla
Classilla will not work out of the box with `carl`. Follow the
instructions
[here](https://www.floodgap.com/software/classilla/carl.html), under
"Configuring and Using Classilla" (at the bottom), except:

1. Don't use `localhost` for the proxy, use `192.168.4.1`.
2. Use port 6789 instead of 8765 for the proxy.

Now, go to a TLS 1.2 site like <https://old.reddit.com> and see if
Classilla can load it.

# Security
All the data sent between the Pi and the Mac is unencrypted. In
addition, the Pi has no kind of firewall, and `carl` and `micro_inetd`
are likely vulnerable programs. Don't setup a bridge Pi on an unsecure
network, and know what devices are on the network before you start
using the bridge.

# Credits
The bridge is configured using info from
<https://forums.raspberrypi.com/viewtopic.php?t=223295>.
