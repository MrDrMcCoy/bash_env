#!/usr/bin/env bash

ffgif() {
    local dither="none"
    local dry_run=
    local extension=
    local extravf="cas=0.8,hqdn3d,"
    local format=
    local formats=
    local fps="16"
    local input=
    local loop="0"
    local output=
    local palette="full"
    local postflags=()
    local preflags=(-loglevel error -stats)
    local speed="1"
    local text=
    local vf=
    local width="480"

    if [[ $# == 0 ]]; then echo "ERROR: You must specify an option. Try -h for help." ; return 1 ; fi
    while (($#)) ; do
        case "${1}" in
--help|-h) fold -sw "${COLUMNS:-80}" <<EOF
ffgif: convert video to gif

Usage: ffgif [options] ...

Options:
    [--dither] Dithering mode. Choices are none, bayer:bayer_scale=[1-3], floyd_steinberg, sierra2. (Default: ${dither})
    [--dry-run | -n] Print commands that would be run instead of executing them.
    [--duration | -d] Duration from start time of input video to select for gif.
    [--extravf | -f] Extra video filters to pass to ffmpeg. (Default: ${extravf})
    [--fps | -r] Number of frames per second. (Default: ${fps})
    [--help | -h] Print this help
    [--input | -i] Input file path.
    [--loop | -l] Should the gif loop? (Default: yes)
    [--output | -o] Name of output file. (Default: <input_filename>.gif)
    [--palette] Stats mode for palettegen. Choices are diff, full. (Default: ${palette})
    [--postflags] Extra flags to pass to ffmpeg after the input file.
    [--preflags] Extra flags to pass to ffmpeg before the input file.
    [--speed] Playback speed of gif as a decimal value of input video. (default: ${speed}).
    [--start | -s] Start time of input video.
    [--text | -t] add text overlay in lower third.
    [--width | -w] Gif width in pixels. Must be an even number. (Default: ${width})
EOF
return 0 ;;
            --dither) shift ; dither="${1}" ;;
            --dry-run|-n) dry_run="echo" ;;
            --duration|-d) shift ; preflags+=(-t "${1}") ;;
            --extravf|-f) shift ; extravf="${1}," ;;
            --fps|-r) shift ; fps="${1}" ;;
            --input|-i) shift ; input="${1}" ;;
            --loop|-l) shift ; [[ ${1} =~ n|no|-1 ]] && loop=-1 ;;
            --output|-o) shift ; output="${1}" ;;
            --palette) shift ; palette="${1}" ;;
            --postflags) shift ; postflags+=("${1}") ;;
            --preflags) shift ; preflags+=("${1}") ;;
            --speed) shift ; speed="${1}" ;;
            --start|-s) shift ; preflags+=(-ss "${1}") ;;
            --text|-t) shift ; extravf+=drawtext=x=w*0.05:y=h*0.9:shadowx=4:shadowy=4:fontcolor=white:fontsize=76:fix_bounds=true:text="${1}", ;;
            --width|-w) shift ; width="${1}" ;;
            *) echo "Unknown argument: '${1}'. Try -h for help" ; return 1 ;;
        esac
        shift
    done

    for var in input ; do
        [ -n "${!var}" ] || {
            echo "ERROR: You must specify an ${var}. Exiting."
            return 1
        }
    done

    vf="${extravf}setpts=${speed}*PTS,fps=${fps},scale=${width}:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=${palette}[p];[s1][p]paletteuse=dither=${dither}"

    if ${dry_run} ffmpeg -y ${preflags[@]} -i "${input}" -vf "${vf}" -loop ${loop} ${postflags} "${output:-${input}.gif}"
        then echo "Successfully saved to '${output:-${input}.gif}'"
        else echo "Error during conversion. See output above."
    fi
}

# This allows the function to be run as a script if this file is executed directly
[[ $- == *i* ]] || ffgif "$@"
