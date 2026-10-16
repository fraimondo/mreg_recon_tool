#!/bin/bash
#
# Copy an HTCondor reconstruction created by mreg_recon_tool (Start Recon with
# "HTCondor") to another path or host, adapting the submit files to that host.
#
# Only the job definition is copied (data.mat, recon_details.mat, the .dag and
# the .submit files); logs and results of earlier runs are not. The original
# recon folder is not modified.
#
# Usage:
#   mreg_recon_transfer.sh [--host HOST] --output-directory DIR \
#       --executable RUN_SH --mr-root MR_ROOT --rawdata RAW_DAT \
#       [--initialdir DIR] RECON_FOLDER
#
#   RECON_FOLDER         recon folder written by the GUI (on this machine)
#   --host HOST          ssh host to copy to (omit to copy to a local path)
#   --output-directory   recon folder on the target (must not exist yet)
#   --executable         run_mreg_recon_tool_recon.sh on the target
#   --mr-root            MATLAB Runtime folder on the target
#   --rawdata            raw data .dat file on the target
#   --initialdir         working directory of the jobs (default: folder of
#                        --executable)
#
# Example:
#   mreg_recon_transfer.sh --host juseless \
#       --output-directory /data/project/mreg/1h_phantom/recon_01 \
#       --executable /home/me/mreg_recon_tool/mreg_recon_tool/mreg_recon_tool_reconstandaloneApplication/run_mreg_recon_tool_recon.sh \
#       --mr-root /data/project/mreg/matlab_runtime/R2023a \
#       --rawdata /data/project/mreg/1h_phantom/meas_MID00031.dat \
#       ./recon_16.10.2026-15-04-38

set -euo pipefail

usage() {
    sed -n '/^# Usage:/,/^# Example:/p' "$0" | sed '$d; s/^# \{0,1\}//'
    exit 1
}

die() {
    echo "Error: $*" >&2
    exit 1
}

HOST=""
OUTDIR=""
EXECUTABLE=""
MR_ROOT=""
RAWDATA=""
INITIALDIR=""
SRC=""

while [ $# -gt 0 ]; do
    case "$1" in
        --host) HOST="$2"; shift 2 ;;
        --output-directory) OUTDIR="$2"; shift 2 ;;
        --executable) EXECUTABLE="$2"; shift 2 ;;
        --mr-root) MR_ROOT="$2"; shift 2 ;;
        --rawdata) RAWDATA="$2"; shift 2 ;;
        --initialdir) INITIALDIR="$2"; shift 2 ;;
        -h|--help) usage ;;
        -*) die "unknown option $1" ;;
        *) [ -z "$SRC" ] || die "only one recon folder can be given"; SRC="$1"; shift ;;
    esac
done

[ -n "$SRC" ] || usage
[ -n "$OUTDIR" ] || die "--output-directory is required"
[ -n "$EXECUTABLE" ] || die "--executable is required"
[ -n "$MR_ROOT" ] || die "--mr-root is required"
[ -n "$RAWDATA" ] || die "--rawdata is required"
[ -n "$INITIALDIR" ] || INITIALDIR="$(dirname "$EXECUTABLE")"
OUTDIR="${OUTDIR%/}"

# HTCondor splits the arguments line at spaces
for v in "$OUTDIR" "$EXECUTABLE" "$MR_ROOT" "$RAWDATA" "$INITIALDIR"; do
    case "$v" in
        /*) ;;
        *) die "paths must be absolute: $v" ;;
    esac
    case "$v" in
        *" "*) die "paths must not contain spaces (HTCondor arguments): $v" ;;
    esac
done

FILES=(data.mat recon_details.mat mreg_recon_batch.dag mreg_recon_batch.submit mreg_recon_cache.submit)
for f in "${FILES[@]}"; do
    [ -f "$SRC/$f" ] || die "$SRC/$f not found. Is this an HTCondor recon folder created with a recent mreg_recon_tool?"
done

# run a command on the target (remote or local)
on_target() {
    if [ -n "$HOST" ]; then
        ssh "$HOST" "$(printf '%q ' "$@")"
    else
        "$@"
    fi
}

TARGET_NAME="${HOST:-this machine}"
if on_target test -e "$OUTDIR"; then
    die "$OUTDIR already exists on $TARGET_NAME. Choose a new --output-directory."
fi

# warn about paths that are missing on the target
for check in "-f:$EXECUTABLE:executable" "-d:$MR_ROOT:MATLAB Runtime" "-f:$RAWDATA:raw data" "-d:$INITIALDIR:initialdir"; do
    flag="${check%%:*}"; rest="${check#*:}"; path="${rest%:*}"; what="${rest##*:}"
    if ! on_target test "$flag" "$path"; then
        echo "Warning: $what not found on $TARGET_NAME: $path" >&2
    fi
done

# stage the job definition with the adapted submit files
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

rewrite_submit() {
    local line
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            "executable = "*) printf '%s\n' "executable = $EXECUTABLE" ;;
            "initialdir = "*) printf '%s\n' "initialdir = $INITIALDIR" ;;
            "mr_root = "*) printf '%s\n' "mr_root = $MR_ROOT" ;;
            "output_directory = "*) printf '%s\n' "output_directory = $OUTDIR" ;;
            "rawdata_filename = "*) printf '%s\n' "rawdata_filename = $RAWDATA" ;;
            *) printf '%s\n' "$line" ;;
        esac
    done < "$1"
}

for f in data.mat recon_details.mat mreg_recon_batch.dag; do
    ln -s "$(cd "$SRC" && pwd)/$f" "$STAGE/$f"
done
for f in mreg_recon_batch.submit mreg_recon_cache.submit; do
    rewrite_submit "$SRC/$f" > "$STAGE/$f"
done

# copy
on_target mkdir -p "$(dirname "$OUTDIR")"
if [ -n "$HOST" ]; then
    rsync -aL "$STAGE/" "$HOST:$OUTDIR/"
else
    rsync -aL "$STAGE/" "$OUTDIR/"
fi

echo "Copied to $TARGET_NAME:$OUTDIR"
echo
echo "To start the reconstruction, run on $TARGET_NAME:"
echo
echo "    cd $OUTDIR && condor_submit_dag mreg_recon_batch.dag"
