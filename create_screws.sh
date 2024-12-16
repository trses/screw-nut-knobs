#!/bin/bash

/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -D TYPE='"M6"' -D EDGE_QUALITY=36 -o test.stl --backend=manifold schraubenkopf-round.scad