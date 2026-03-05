#!/bin/bash
# Script to clean up German language map entries from rspamd multimap configurations
# This removes all _de blocks and updates language comments to English-only

set -e

MAPS_DIR="content/assets/rspamd/local.d/ms"

if [ ! -d "$MAPS_DIR" ]; then
    echo "Error: Maps directory not found: $MAPS_DIR"
    exit 1
fi

echo "🧹 Cleaning up German language entries from multimap configurations..."
echo "📁 Working in: $MAPS_DIR"
echo ""

# Count of files to be processed
file_count=$(find "$MAPS_DIR" -name '_multimap_*.conf' | wc -l)
echo "📋 Found $file_count _multimap_.conf files to process"
echo ""

# Process each _multimap_*.conf file
for file in "$MAPS_DIR"/_multimap_*.conf; do
    filename=$(basename "$file")
    
    # Update language comments from "German and english" to "English"
    if grep -q "Languages: German and english" "$file"; then
        sed -i 's/Languages: German and english/Languages: English/g' "$file"
        sed -i 's/# -----------------------------/# --------------------------------/g' "$file"
        echo "✅ Updated language comment in: $filename"
    fi
    
    # Remove all _de blocks (including the entire block from opening { to closing })
    if grep -q "_de {" "$file"; then
        # Use awk to skip _de blocks entirely
        awk '
        /^[a-z_]*_de \{/ {
            # Found a _de block, skip it
            skip = 1
            next
        }
        skip && /^}/ {
            # End of block, stop skipping
            skip = 0
            next
        }
        !skip {
            # Print lines that are not in a _de block
            print
        }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        
        # Clean up multiple consecutive newlines
        sed -i '/^$/N;/^\n$/!P;D' "$file"
        
        echo "✅ Removed German (_de) blocks from: $filename"
    fi
done

echo ""
echo "🗑️  Removing standalone German map files (.de. pattern)..."
removed_count=$(find "$MAPS_DIR" -name '*multimap*.de.*.conf' | wc -l)

if [ "$removed_count" -gt 0 ]; then
    find "$MAPS_DIR" -name '*multimap*.de.*.conf' -delete
    echo "🗑️  Deleted $removed_count German-specific map files"
else
    echo "ℹ️  No German-specific map files found to remove"
fi

echo ""
echo "✨ Cleanup complete!"
echo ""
echo "📝 Summary:"
echo "   - Updated language comments to English-only"
echo "   - Removed all _de blocks from _multimap_*.conf files"
echo "   - Deleted German-specific (.de.) configuration files"
echo ""
echo "💡 Tip: Review changes with 'git diff' before committing"
