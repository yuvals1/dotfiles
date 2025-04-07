#!/bin/bash

# Define the path to the links CSV file
LINKS_FILE="$HOME/Documents/links.csv"

# Check if the file exists
if [ ! -f "$LINKS_FILE" ]; then
	echo "Error: Links file not found at $LINKS_FILE"
	exit 1
fi

# Define multiple colors (6 different colors)
COLORS=(
	"\033[38;5;39m"  # Light blue
	"\033[38;5;147m" # Light purple
	"\033[38;5;78m"  # Light green
	"\033[38;5;209m" # Light orange
	"\033[38;5;175m" # Pink
	"\033[38;5;220m" # Yellow
)
RESET="\033[0m"

# Create a temporary file for formatted output with colors and a lookup file for URLs
TMP_OUTPUT=$(mktemp)
TMP_LOOKUP=$(mktemp)

# Process the CSV, skipping the header row, and apply rotating colors
# Also create a lookup file that maps names to URLs
awk -F, 'NR>1 {
  gsub(/^[ \t]+|[ \t]+$/, "", $1);  # Trim whitespace from name
  gsub(/^[ \t]+|[ \t]+$/, "", $2);  # Trim whitespace from URL
  
  # Store name and URL in lookup file
  print $1 ":::" $2 > "'"$TMP_LOOKUP"'";
  
  # Apply colors to names based on row number
  color_index = (NR - 2) % 6;
  if (color_index == 0) printf "'"${COLORS[0]}"'%s'"$RESET"'\n", $1;
  else if (color_index == 1) printf "'"${COLORS[1]}"'%s'"$RESET"'\n", $1;
  else if (color_index == 2) printf "'"${COLORS[2]}"'%s'"$RESET"'\n", $1;
  else if (color_index == 3) printf "'"${COLORS[3]}"'%s'"$RESET"'\n", $1;
  else if (color_index == 4) printf "'"${COLORS[4]}"'%s'"$RESET"'\n", $1;
  else printf "'"${COLORS[5]}"'%s'"$RESET"'\n", $1;
}' "$LINKS_FILE" > "$TMP_OUTPUT"

# Temporarily override the global FZF_DEFAULT_OPTS to disable bat preview
OLD_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"
export FZF_DEFAULT_OPTS="--ansi"

# Use fzf to select a name
selected_name=$(cat "$TMP_OUTPUT" | fzf --ansi)

# Restore original FZF_DEFAULT_OPTS
export FZF_DEFAULT_OPTS="$OLD_FZF_DEFAULT_OPTS"

# Remove ANSI color codes from the selection
clean_name=$(echo "$selected_name" | sed 's/\x1b\[[0-9;]*m//g')

# Check if a selection was made
if [ -z "$clean_name" ]; then
	echo "No selection made."
	rm "$TMP_OUTPUT" "$TMP_LOOKUP"
	exit 0
fi

# Look up the URL for the selected name using the lookup file
url=$(grep -F "^$clean_name:::" "$TMP_LOOKUP" | cut -d':' -f4-)

# If URL not found using fixed string, try with regex
if [ -z "$url" ]; then
	url=$(grep "^$clean_name:::" "$TMP_LOOKUP" | cut -d':' -f4-)
fi

# Check if URL exists and open it
if [ -n "$url" ]; then
	echo "Opening: $url"

	# Detect OS and use appropriate command to open URL
	case "$(uname -s)" in
		Darwin)
			# macOS
			open "$url"
			;;
		Linux)
			# Linux - try different commands
			if command -v xdg-open > /dev/null; then
				xdg-open "$url"
			elif command -v gnome-open > /dev/null; then
				gnome-open "$url"
			else
				echo "Error: Could not find a command to open the URL on your system."
				echo "URL is: $url"
			fi
			;;
		CYGWIN* | MINGW* | MSYS*)
			# Windows
			start "$url"
			;;
		*)
			# Unknown OS
			echo "Error: Could not determine your OS to open the URL."
			echo "URL is: $url"
			;;
	esac
else
	echo "No URL available for this selection or selected item has no URL."
	echo "Selected name: '$clean_name'"
	echo "Debug: Contents of lookup file:"
	cat "$TMP_LOOKUP"
fi

# Clean up the temporary files
rm "$TMP_OUTPUT" "$TMP_LOOKUP"
