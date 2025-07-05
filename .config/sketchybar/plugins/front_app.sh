#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # When triggered by aerospace focus commands, we need to get the app name
  if [ -z "$INFO" ] || [ "$INFO" = "" ]; then
    INFO=$(aerospace list-windows --focused | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  fi
  # Get current workspace
  WORKSPACE=$(aerospace list-workspaces --focused)
  
  # Count total instances of this app in workspace
  TOTAL=$(aerospace list-windows --workspace "$WORKSPACE" | 
          awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}' | 
          grep -c "^$INFO$")
  
  if [ "$TOTAL" -gt 1 ]; then
    # Get focused window ID (trim spaces)
    FOCUSED_ID=$(aerospace list-windows --focused | awk -F'|' '{gsub(/^ *| *$/, "", $1); print $1}')
    
    # Find position of focused window among instances of the same app
    POSITION=$(aerospace list-windows --workspace "$WORKSPACE" | 
               awk -F'|' -v app="$INFO" '{gsub(/^ *| *$/, "", $1); gsub(/^ *| *$/, "", $2); if ($2 == app) print $1}' | 
               grep -n "^$FOCUSED_ID$" | 
               cut -d: -f1)
    
    # Format label with instance counter
    LABEL="$INFO $POSITION/$TOTAL"
  else
    # Single instance, no counter needed
    LABEL="$INFO"
  fi
  
  # Update sketchybar item
  sketchybar --set $NAME label="$LABEL" icon="$($CONFIG_DIR/plugins/icon_map_fn.sh "$INFO")"
fi
