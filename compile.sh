#!/bin/bash
LOG_DIR="torment_log"
MAP_FILE=".torment_map"
LOCAL_DATA="torment_data.md"

show_help() {
    echo "Usage: ./compile.sh [ID or Name] [Options]"
    echo ""
    echo "Options:"
    echo "  -l, --list      List all available torments with their unique IDs."
    echo "  -r              Run the binary after successful compilation."
    echo "  -t              Show the torment log (checks $LOG_DIR/ or $LOCAL_DATA)."
    echo "  --cache-update  Force update/re-generate the $MAP_FILE."
    echo "  --no-copy       Do not copy the binary to the root as './program'."
    echo "  --clean         Remove './program' and the '$MAP_FILE'."
    echo "  -h, --help      Show this help message."
}

update_map() {
    # Clear the file first
    true > "$MAP_FILE"
    
    local count=1
    # Loop through every item in the current directory
    for dir in */; do
        # Strip the trailing slash
        dir=${dir%/}
        
        # Filter: Must be a directory, not hidden, and not the log dir
        if [[ -d "$dir" && "$dir" != "$LOG_DIR" && ! "$dir" =~ ^\. ]]; then
            echo "$count $dir" >> "$MAP_FILE"
            ((count++))
        fi
    done

    # If the file is empty, remove it to trigger the "No torments" message
    [[ ! -s "$MAP_FILE" ]] && rm -f "$MAP_FILE"
}

resolve_name() {
    local input=$1
    if [[ -f "$MAP_FILE" && $input =~ ^[0-9]+$ ]]; then
        awk -v id="$input" '$1 == id {print $2}' "$MAP_FILE"
    else
        echo "$input"
    fi
}

list_torments() {
    update_map
    if [[ ! -f "$MAP_FILE" ]]; then
        echo "No torments found in the current directory."
        return
    fi
    echo -e "ID\t| Torment Name"
    echo -e "--\t| ------------"
    while read -r id name; do
        printf "%-2s\t| %s\n" "$id" "$name"
    done < "$MAP_FILE"
}

show_markdown_log() {
    local name=$1
    if [[ -f "$LOCAL_DATA" ]]; then
        echo -e "\033[1;33m--- Scanning $LOCAL_DATA for '$name' ---\033[0m"
        # Finds heading, prints until next heading or end of file
        sed -n "/# $name/,/^# /p" "$LOCAL_DATA" | sed '$d' | less
    else
        echo "Error: No log found for '$name'."
    fi
}

# --- Handle No Arguments ---
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# ----
RUN=false
COPY=true
SHOW_LOG=false
INPUT_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--list) list_torments; exit 0 ;;
        --clean) rm -f program "$MAP_FILE"; echo "Cleaned."; exit 0 ;;
        --cache-update) update_map; echo "Cache updated."; exit 0 ;;
        -r) RUN=true; shift ;;
        -t) SHOW_LOG=true; shift ;;
        --no-copy) COPY=false; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) 
            if [[ -z "$INPUT_NAME" ]]; then
                INPUT_NAME="$1"
            fi
            shift 
            ;;
    esac
done

# Ensure map exists for ID resolution
if [[ ! -f "$MAP_FILE" ]]; then update_map; fi

TORMENT_NAME=$(resolve_name "$INPUT_NAME")

if [[ -z "$TORMENT_NAME" ]]; then
    echo "Error: Torment '$INPUT_NAME' not found."
    exit 1
fi

if $SHOW_LOG; then
    LOG_PATH="$LOG_DIR/$TORMENT_NAME.log"
    if [[ -f "$LOG_PATH" ]]; then
        less "$LOG_PATH"
    else
        show_markdown_log "$TORMENT_NAME"
    fi
    exit 0
fi

if [[ ! -d "$TORMENT_NAME" ]]; then
    echo "Error: Directory '$TORMENT_NAME' not found."
    exit 1
fi

SRC=""
[[ -f "$TORMENT_NAME/$TORMENT_NAME.asm" ]] && SRC="$TORMENT_NAME/$TORMENT_NAME.asm"
[[ -z "$SRC" && -f "$TORMENT_NAME/main.asm" ]] && SRC="$TORMENT_NAME/main.asm"

if [[ -z "$SRC" ]]; then
    echo "Error: No .asm source found in $TORMENT_NAME/"
    exit 1
fi

OBJ="$TORMENT_NAME/$TORMENT_NAME.o"
BIN="$TORMENT_NAME/$TORMENT_NAME"

as --32 -o "$OBJ" "$SRC" && ld -m elf_i386 -o "$BIN" "$OBJ"

if [[ $? -eq 0 ]]; then
    echo -e "\033[0;32mBuild Successful: $BIN\033[0m"
    if $COPY; then
        cp "$BIN" ./program
        EXEC="./program"
    else
        EXEC="$BIN"
    fi
    
    if $RUN; then
        echo "--- Executing $TORMENT_NAME ---"
        $EXEC
    fi
else
    echo "Build Failed."
    exit 1
fi