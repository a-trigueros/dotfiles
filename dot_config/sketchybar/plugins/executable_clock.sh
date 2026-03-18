#!/bin/bash

# Plugin : clock.sh
# Affiche l'heure et la date

sketchybar --set "$NAME" label="$(date '+%a %d %b  %H:%M')"
