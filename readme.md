# GPX Merge

This is a simple utility to merge/convert separate GPX track and GPX
route files into a unified GPX file. The GPX route points (turn-by-turn
cues) are converted into waypoints and inserted after the track.

Pocket Earth will then display the track and waypoints which makes it
much more effective for routing on a pre-selected track. Currently,
Pocket Earth 2.8 offers routing *or* tracking modes. Routing requires an
internet connection to their API which provides the routing service.
Routes created externally are only imported as historical tracks and do
not offer turn-by-turn directions.

However, an existing track can be loaded and new tracks may be
recorded into that file.
While somewhat less than ideal (statistics such as overall distance and
average speed will include the routed "track") this enables a simple way
to check that the current track is "on route" or to quickly identify the
direction back to the route.

---

## Usage
Use the ```--help``` flag to display the built-in documentation.
Source GPX track and route files are required. Omit the output file path to redirect output to stdout.

```
gpxmerge -t <path to track file> -c <path to cue points file> -f <path to output file>
```


