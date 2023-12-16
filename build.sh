#!/bin/bash

dir="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Defaults
TAGS_DIRS=('tags')
EXTRA_TAGS_DIRS=()
DATA_DIR="data"
MAPS_DIR="maps"
BUILD_NEW_RESOURCE_MAPS=0
USE_EXISTING_RESOURCE_MAPS=0
ENGINE_TARGET="mcc-cea"
USE_HD_BITMAPS=0

echoerr() { printf "%s\n" "$*" >&2; }

__usage="Usage: $(basename $0) [OPTIONS]

Options:
  -b            Use high resolution transparency and rasterizer bitmaps.
  -d <dir>      Change the data directory used for scripts.
  -h            Show this help text.
  -l <lang>     Build a localization. Valid options are: de, es, fr, it, jp, kr,
                tw, en (default).
  -m <dir>      Change the output maps directory.
  -n            Make and use new resource maps (two pass build).
  -q            Make invader-build be quiet.
  -r            Build against existing resource maps.
  -t            Prefix an extra tags directory (can be used more than once).
"

# Scenario basenames
CAMPAIGN=('a10' 'a30' 'a50' 'b30' 'b40' 'c10' 'c20' 'c40' 'd20' 'd40')

MULTIPLAYER_XBOX=('beavercreek' 'bloodgulch' 'boardingaction' 'carousel' 'chillout'
         'damnation' 'hangemhigh' 'longest' 'prisoner' 'putput' 'ratrace'
         'sidewinder' 'wizard')

MULTIPLAYER_PC=('dangercanyon' 'deathisland' 'gephyrophobia' 'icefields'
        'infinity' 'timberland')

MULTIPLAYER=("${MULTIPLAYER_XBOX[@]}" "${MULTIPLAYER_PC[@]}")

# Options
lang_set=0
while getopts ":bd:hl:m:nqrt:" arg; do
    case "${arg}" in
        b)
            USE_HD_BITMAPS=1
        ;;
        d)
            DATA_DIR="${OPTARG}"
        ;;
        h)
            echo "$__usage"
            exit
        ;;
        l)
            if [[ $lang_set != 1 ]]; then
                case "${OPTARG}" in
                    de)
                    ;&
                    es)
                    ;&
                    fr)
                    ;&
                    it)
                    ;&
                    jp)
                    ;&
                    kr)
                    ;&
                    tw)
                        TAGS_DIRS=("loc/tags_${OPTARG}" "${TAGS_DIRS[@]}")
                    ;;
                    en)
                        true
                    ;;
                    *)
                        echoerr "Error: Unknown Language \"$OPTARG\""
                        exit 1
                    ;;
                esac
                lang_set=1
            else
                echoerr "Error: The language can only be set once"
                exit 1
            fi
        ;;
        m)
            MAPS_DIR="${OPTARG}"
        ;;
        n)
            BUILD_NEW_RESOURCE_MAPS=1
        ;;
        q)
            INVADER_QUIET=1
        ;;
        r)
            USE_EXISTING_RESOURCE_MAPS=1
        ;;
        t)
            # Flip it
            EXTRA_TAGS_DIRS+=("${OPTARG}")
        ;;
        *)
            echoerr "Error: Unknown option. use -h for supported options"
            exit 1
        ;;
    esac
done

# Find Invader
if command -v invader-build &> /dev/null; then
    CACHE_BUILDER=invader-build
    W32_CB=0
elif command -v invader-build.exe &> /dev/null; then
    CACHE_BUILDER=invader-build.exe
    W32_CB=1
elif command -v ./invader-build.exe &> /dev/null; then
    CACHE_BUILDER=./invader-build.exe
    W32_CB=1
else
    echoerr "Error: Could not find invader-build in \$PATH or next to this script"
    exit 1
fi

if command -v invader-resource &> /dev/null; then
    RESOURCE_BUILDER=invader-resource
    W32_RB=0
elif command -v invader-resource.exe &> /dev/null; then
    RESOURCE_BUILDER=invader-resource.exe
    W32_RB=1
elif command -v ./invader-resource.exe &> /dev/null; then
    RESOURCE_BUILDER=./invader-resource.exe
    W32_RB=1
else
    echoerr "Error: Could not find invader-resource in \$PATH or next to this script"
    exit 1
fi

if [[ $W32_CB != $W32_RB ]]; then
    echoerr "Error: Mixed Windows and non-Windows invader tools are not supported by this script"
    exit 1
fi

if [[ $W32_CB == 1 ]]; then
    if command -v wslpath &> /dev/null; then
        MAPS_DIR_NIX=$(wslpath "${MAPS_DIR}")
    else
        echoerr "Error: Usage of the windows tools are only supported on WSL"
        exit 1
    fi
else
    MAPS_DIR_NIX="${MAPS_DIR}"
fi

# Make sure this exists
mkdir -p "${MAPS_DIR_NIX}"

# Set common build args
BUILD_ARGS=("--maps" "${MAPS_DIR}" "--game-engine" "$ENGINE_TARGET")

# Add tags directory arguments
for ET_PATH in "${EXTRA_TAGS_DIRS[@]}"; do
    BUILD_ARGS+=("--tags" "${ET_PATH}")
done

if [[ $USE_HD_BITMAPS == 1 ]]; then
    BUILD_ARGS+=("--tags" "extra/tags_highres_bitmaps")
fi

for MT_PATH in "${TAGS_DIRS[@]}"; do
    BUILD_ARGS+=("--tags" "${MT_PATH}")
done

# Quiet?
if [[ $INVADER_QUIET == 1 ]]; then
    BUILD_ARGS+=("--quiet")
fi

# Use existing resource maps if enabled.
if [[ $USE_EXISTING_RESOURCE_MAPS == 1 && $BUILD_NEW_RESOURCE_MAPS != 1 ]]; then
        RESOURCE_ARGS=("--resource-usage" "check")
    else
        RESOURCE_ARGS=("--resource-usage" "none")
fi

run_build() {
    # Campaign
    for s in "${CAMPAIGN[@]}"; do
        $CACHE_BUILDER levels/$s/$s \
            --data "${DATA_DIR}" \
            "${BUILD_ARGS[@]}" \
            "${RESOURCE_ARGS[@]}"
    done

    # MP (Stock Compat)
    for m in "${MULTIPLAYER[@]}"; do
        $CACHE_BUILDER levels/test/$m/$m \
            --auto-forge \
            --data "${DATA_DIR}" \
            "${BUILD_ARGS[@]}" \
            "${RESOURCE_ARGS[@]}"
    done

    # UI
    $CACHE_BUILDER levels/ui/ui \
        --data "${DATA_DIR}" \
        "${BUILD_ARGS[@]}" \
        "${RESOURCE_ARGS[@]}"
}

run_build

# If making new resource maps, make them based on the first build and do a second pass
if [[ $BUILD_NEW_RESOURCE_MAPS == 1 ]]; then
    # Make resource maps based on existing maps
    MAP_ARGS=()
    for MAPNAME in "${CAMPAIGN[@]}" "${MULTIPLAYER[@]}" ui; do
        MAP_ARGS+=("--with-map" "${MAPS_DIR}/${MAPNAME}.map")
    done

    for RESOURCE_TYPE in bitmaps sounds; do
        $RESOURCE_BUILDER --type "$RESOURCE_TYPE" "${BUILD_ARGS[@]}" "${MAP_ARGS[@]}"
    done

    RESOURCE_ARGS=("--resource-usage" "check")
    run_build
fi
