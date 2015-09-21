# Ride with GPS to Pocket Earth
## Export process / notes

* Export the route from RWG as a GPX track.
* Separately, export the cuepoints as a GPX route.
* Open both in a text editor
* Rename each "rtept" element to "wpt"
  * :%s/rtept/wpt/g 
* Rename each "cmt" element to "desc"
  * :%s/cmt>/desc>/g
* Copy all wpt elements to the track file as children of the "gpx" element.
  * note: this is alongside the "trk" element, not within it.

Import this combined GPX file into Pocket Earth.
The waypoints will appear along the route and can be used for dead-reckoning navigation.




