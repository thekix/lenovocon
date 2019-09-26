# lenovocon
Small script to connect using the 3G/4G SIMcard with Lenovo (probably others) laptops

## Setup

Edit the script and set your APN name and the device:

```
IFACE="wwp0s20u4";
APN="Movistar";
```

## Usage

The usage is easy. Call the script (witout arguments, it offers help)

```
./lenovocon.sh <pin>|off
```

## Examples:

Connect:
```
./lenovocon.sh 1234
```

Disconnect:
```
./lenovocon.sh off
```

## Notes

Sometimes the script is unable to find the device. It is a bug (probably kernel).
In this case, close the LID, open it again, and call the script.

If you get this error, it is an dbus error, try it again:
```
error: couldn't connect the modem: 'GDBus.Error:org.freedesktop.ModemManager1.Error.Core.Retry: Too much time waiting to get to a final state'
Connecting error
```

Add the script to the $PATH

Comments/patches are welcome.
