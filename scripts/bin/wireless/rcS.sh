#!/bin/sh


# Start all init scripts in /etc/init.d
# executing them in numerical order.
#
for i in /etc/init.d/S??* ;do

     # Ignore dangling symlinks (if any).
     [ ! -f "$i" ] && continue

     case "$i" in
	*.sh)
	    # Source shell script for speed.
	    (
		trap - INT QUIT TSTP
		set start
		. $i
	    )
	    ;;
	*)
	    # No sh extension, so fork subprocess.
	    $i start
	    ;;
    esac
done

/usr/bin/enable_bt

aplay -l | grep "card 0.*hdmi"
if [ $? = 0 ] ; then
        alsactl restore 1 -f /var/lib/alsa/asound.state
else
        alsactl restore 0 -f /var/lib/alsa/asound.state
fi 
