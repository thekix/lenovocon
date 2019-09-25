# lenovocon
Small script to connect using the 3G/4G SIMcard with Lenovo (probably others) laptops

## Setup

Edit the script and set your APN name and the device:

# Set the APN
IFACE="wwp0s20u4";
APN="Movistar";

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


Add the script to the $PATH
Comments/patches are welcome.
