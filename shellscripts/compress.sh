#!/bin/bash

mogrify -strip -colorspace Gray -quality 80 -resize x1200 ./html/facs/*.jpg