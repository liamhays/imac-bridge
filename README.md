# imac-bridge
A simple shell script to configure a Raspberry Pi as a
WiFi-to-Ethernet bridge, for old iMacs and other vintage Apples
without WiFi. It also configures `carl` from [Crypto
Ancienne](https://github.com/classilla/cryanc) so that Classilla on
the Mac can browse modern websites.

# Usage
Obviously, whatever Pi you use has to have both a WiFi and an Ethernet
interface. As such, the Pi Zero is probably not a good choice.

Set up a Raspberry Pi with Raspberry Pi OS Lite. Enable SSH and
configure the WiFi to connect to your desired network. Once the Pi is
on WiFi and SSH is enabled, run this command at the prompt:

```
wget
https://github.com/liamhays/imac-bridge/raw/main/install_imac_bridge.sh

bash install_imac_bridge.sh
```

The script will update the system, install some necessary packages,
configure WiFi-to-Ethernet bridge, and set up `carl`. Once it's
finished, reboot the Pi. It should now be a bridge, so plug in the Mac
and test. 

Do not run the script more than once. This script is also designed to
be run on a fresh installation---it will *probably* work on an existing
installation, but your mileage may vary.

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

# Credits
The bridge is configured using info from
<https://forums.raspberrypi.com/viewtopic.php?t=223295>.
