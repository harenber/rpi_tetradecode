# rpi_tetradecode
Docker container to monitor TETRA traffic  using your Raspberry Pi and a RTL dongle

This is a Dockerfile to create a Docker Container on a Raspberry Pi to
Monitor TETRA traffic.

All here is based on the fine work explained in the following article:

https://www.rtl-sdr.com/rtl-sdr-tutorial-listening-tetra-radio-channels/

You will need:

* Some knowledge about radio, digital data modes on radio links
* the knowledge given in the mentioned article!
* a Raspberry Pi (I tested it on a Pi 4 with 4 GB of RAM)
* an [RTL-SDR RTL2832U dongle](https://www.rtl-sdr.com)
* a VNC viewer (preferable on the same machine, so that you hear the sound)

Attach the dongle to the Raspberry Pi and set it up accordingly,
especially blacklist the `dvb_usb_rtl28xxu` kernel module.

run the container with

```
docker run -p 127.0.0.1:5920:5920 --device=/dev/bus/usb:/dev/bus/usb --device /dev/snd --rm -d harenber/rpi_tetradecode:<tag>
```

and connect a vncviewer to  127.0.0.1:5920, the password will be TestVNC

Arrange the windows and start the example as described in the article. 

Enjoy!

**IMPORTANT**

Use this at your own risk! I shall not be responsible for anything, especially not for any damage to your hardware 
or legal issue you might have in your jurisdiction. Obey all laws. 
