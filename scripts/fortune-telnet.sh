#!/bin/sh
# /etc/init.d/fortune-telnet
# starts up wlan0 interface, hostapd, and dnsmasq for broadcasting a wireless network

NAME=fortune-telnet
DESC="Brings up wireless access point for connecting to web server running on the device."
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

	case "$1" in
		start)
			echo "Starting $NAME access point..."
			#bring down wlan0
			ifdown wlan0

			# bring down hostapd + dnsmasq to ensure wlan0 is brought up first
			service hostapd stop
			service dnsmasq stop

			# bring up WLAN0 interface
			ifup wlan0

			# *now* start the hostapd and dnsmasq services
			service hostapd start
			service dnsmasq start
		;;

		status)
		;;

		stop)
			ifdown wlan0

			service hostapd stop
            service dnsmasq stop
		;;

		restart)
			$0 stop
			$0 start
		;;

*)
		echo "Usage: $0 {status|start|stop|restart}"
		exit 1
esac
