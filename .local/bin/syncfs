#!/usr/bin/env bash
# syncfs: push/pull a directory (marked by .syncfs) to/from a fixed remote using rsync.
# Remote dir     = ${SYNCFS_REMOTE}/${md5sum(realpath(syncdir))}
# Remote stamp   = ${SYNCFS_REMOTE}/${md5sum(realpath(syncdir))}.timestamp
# Local stamp    = <syncdir>/.syncfs   (stores POSIX seconds; file also acts as the marker)
set -u

# ------------ helpers ------------
die() {
    echo "Error: $*" >&2
    exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"; }

resolve_realpath() {
    local p="$1"
    if command -v realpath >/dev/null 2>&1; then
        realpath "$p"
    elif readlink -f . >/dev/null 2>&1; then
        readlink -f "$p"
    elif command -v python3 >/dev/null 2>&1; then
        python3 - "$p" <<'PY'
import os,sys
print(os.path.realpath(sys.argv[1]))
PY
    else die "cannot resolve realpath; install coreutils realpath or provide python3"; fi
}

md5_of_string() {
    if command -v md5sum >/dev/null 2>&1; then
        printf '%s' "$1" | md5sum | awk '{print $1}'
    elif command -v md5 >/dev/null 2>&1; then
        printf '%s' "$1" | md5 -q
    else die "need md5sum or md5"; fi
}

# --- Stable sync key helpers ---
# 1) If .syncfs contains a line like `id=...` or `key=...`, we use that as the sync key.
# 2) Otherwise, we canonicalize the absolute path by replacing the user's home prefix
#    with a stable token `~` so different usernames yield the same key (e.g.
#    /home/alice/work/p -> ~/work/p and /home/bob/work/p -> ~/work/p).
canonicalize_for_hash() {
    local p home
    p="$(resolve_realpath "$1")" || exit 1
    home="${HOME:-}"
    if [ -n "$home" ]; then
        home="${home%/}"
        case "$p" in
        "$home"/*) p="~${p#"$home"}" ;;
        esac
    fi
    printf '%s' "$p"
}

sync_id_from_marker() {
    local f="$1/.syncfs"
    if [ -f "$f" ]; then
        awk 'BEGIN{IGNORECASE=1}
             /^[ 	]*#/ {next}
             /^[ 	]*(id|key)[ 	]*[:=][ 	]*/ {
                 sub(/^[ 	]*(id|key)[ 	]*[:=][ 	]*/, "", $0)
                 gsub(/^[ 	]+|[ 	]+$/, "", $0)
                 print $0
                 exit
             }' "$f"
    fi
}

hash_key_for_syncdir() {
    local dir="$1" id
    id="$(sync_id_from_marker "$dir")"
    if [ -n "${id:-}" ]; then
        printf '%s' "$id"
    else
        canonicalize_for_hash "$dir"
    fi
}

find_syncdir() {
    local dir="$PWD"
    while :; do
        if [ -e "$dir/.syncfs" ]; then
            printf '%s\n' "$dir"
            return 0
        fi
        [ "$dir" = "/" ] && return 1
        dir="$(dirname "$dir")"
    done
}

usage() {
    cat <<'EOF'
Usage: syncfs [init|push|pull] [-h|--help]
Synchronizes the directory that contains a `.syncfs` file (searched upwards from the current directory).

Subcommands:
  init  Create an example `.syncfs` file in the *current working directory* and open it in $EDITOR.
  push  Mirror local -> remote (${SYNCFS_REMOTE}/${md5(realpath(syncdir))}), including deletions.
  pull  Mirror remote -> local, including deletions.

No subcommand: prints status (based on rsync dry-runs and timestamps):
- Local changes to push
- Remote changes to pull (including when someone else pushed since your last local sync)
- Both directions
- Up to date

Environment:
  SYNCFS_REMOTE   Required for push/pull/status. Base remote for rsync, e.g. "user@host:/var/syncfs" or a local path.

Notes:
  - Preserves perms and mtimes (-rlpt), not ownership. Excludes ".syncfs", respects per-directory ".gitignore" files (via rsync filter), and **always syncs the `.git` directory**.
  - Uses --delete so that deletions propagate both ways: the destination is mirrored to the source (for push: remote mirrors local; for pull: local mirrors remote).
  - Local last-sync time is stored as POSIX seconds inside ".syncfs" (first line must be numeric).
  - Stable remote key: if your .syncfs contains a line like `id=YOUR_ID` (or `key=...`), that value is used to compute the remote path. Otherwise, the absolute path is canonicalized by replacing your HOME prefix with `~` (so `/home/alice/proj` and `/home/bob/proj` map to the same key `~/proj`).
  - Remote last-push time is stored in "${SYNCFS_REMOTE}/${md5(realpath(syncdir))}.timestamp" (internally computed from the stable key described above).
EOF
}

# rsync options: recursive, symlinks, perms (exec bits), times; itemize changes; exclude marker
RSYNC_OPTS=(-rlpt --itemize-changes --out-format='%i %n%L' --exclude='.syncfs')
# Honor Git ignore rules but always include the VCS metadata (.git).
# The per-dir filter below treats any ".gitignore" as an rsync filter file (optional with '-' so missing files are fine).
RSYNC_OPTS+=("--include=/.git" "--include=/.git/**" "--filter" ":- .gitignore")
# Mirror semantics: propagate deletions both ways (but keep excluded files like .syncfs).
RSYNC_OPTS+=("--delete")

remote_base() { printf '%s' "${SYNCFS_REMOTE%/}"; }
remote_path_for() {
    [ -n "${SYNCFS_REMOTE-}" ] || die "SYNCFS_REMOTE is not set"
    local key hash
    key="$(hash_key_for_syncdir "$1")" || exit 1
    hash="$(md5_of_string "$key")" || exit 1
    printf '%s/%s' "$(remote_base)" "$hash"
}
remote_ts_path_for() {
    local key hash
    key="$(hash_key_for_syncdir "$1")" || exit 1
    hash="$(md5_of_string "$key")" || exit 1
    printf '%s/%s.timestamp' "$(remote_base)" "$hash"
}

# Remote existence probes
remote_dir_exists() {
    local p="$1"
    case "$p" in
    /* | ./* | ../*) [ -d "$p" ] ;;
    *) rsync --list-only "$p/" >/dev/null 2>&1 ;;
    esac
}
remote_file_fetch() { # $1 remote-file, $2 local-dest; returns 0 on success
    local src="$1" dst="$2"
    case "$src" in
    /* | ./* | ../*) [ -f "$src" ] && cp -f "$src" "$dst" 2>/dev/null ;;
    *) rsync "$src" "$dst" >/dev/null 2>&1 ;;
    esac
}

ensure_remote_base_exists() {
    local base
    base="$(remote_base)"
    if ! remote_dir_exists "$base"; then
        die "SYNCFS_REMOTE base not found or unreachable: $base"
    fi
}

# Dry-run that tolerates rsync 23/24 (common with GVFS/remote FS)
# 0 => has changes, 1 => no changes, 2 => fatal error
dry_changes_exist() {
    local src="$1" dst="$2" out rc
    out="$(rsync -n "${RSYNC_OPTS[@]}" "$src" "$dst" 2>&1)"
    rc=$?
    case "$rc" in 0 | 23 | 24) ;; *)
        echo "$out" >&2
        return 2
        ;;
    esac
    # With --itemize-changes, normal changes start with [<>chd.*], deletions with "deleting ...".
    printf '%s\n' "$out" | grep -Eq '^[<>chd\.*]|^deleting ' && return 0 || return 1
}

# Timestamp IO (POSIX seconds)
get_local_ts() {
    local f="$1/.syncfs" v
    if [ -f "$f" ]; then
        v="$(head -n1 "$f" | grep -Eo '^[0-9]{1,}$' || true)"
        [ -n "$v" ] && printf '%s' "$v" && return 0
    fi
    printf '0'
}
set_local_ts() {
    local d="$1" ts="$2"
    printf '%s\n' "$ts" >"$d/.syncfs" || die "cannot write $d/.syncfs"
}
get_remote_ts() {
    local syncdir="$1" rf tmp v
    rf="$(remote_ts_path_for "$syncdir")"
    tmp="$(mktemp)"
    trap 'rm -f "$tmp"' RETURN
    if remote_file_fetch "$rf" "$tmp"; then
        v="$(head -n1 "$tmp" | grep -Eo '^[0-9]{1,}$' || true)"
        [ -n "$v" ] && printf '%s' "$v" && return 0
    fi
    printf '0'
}
set_remote_ts() {
    local syncdir="$1" ts="$2" rf tmp
    rf="$(remote_ts_path_for "$syncdir")"
    tmp="$(mktemp)"
    printf '%s\n' "$ts" >"$tmp"
    case "$rf" in
    /* | ./* | ../*) cp -f "$tmp" "$rf" ;;
    *) rsync "$tmp" "$rf" ;;
    esac || die "failed to write remote timestamp: $rf"
    rm -f "$tmp"
}

# ------------ subcommands ------------

do_init() {
    local dir
    dir="$PWD"
    local f
    f="$dir/.syncfs"
    if [ -e "$f" ]; then
        echo "'.syncfs' already exists here: $f"
    else
        cat >"$f" <<'SYNCFS_MARKER'
0
# syncfs marker for the directory.
# The first line is the last-sync timestamp in POSIX seconds.
# Leave it as 0 initially; it will be updated on push/pull.
# You may add notes below this line; they are ignored.
SYNCFS_MARKER
        chmod 0644 "$f" 2>/dev/null || true
        echo "Created example $f"
    fi
}

do_push() {
    local syncdir="$1" remote now
    remote="$(remote_path_for "$syncdir")" || exit 1
    echo "Pushing (mirror local -> remote, including deletions):"
    echo "  Local : $syncdir/"
    echo "  Remote: $remote/"
    rsync "${RSYNC_OPTS[@]}" "$syncdir/" "$remote/" || exit 1
    now="$(date +%s)"
    set_remote_ts "$syncdir" "$now"
    set_local_ts "$syncdir" "$now"
}

do_pull() {
    local syncdir="$1" remote now
    remote="$(remote_path_for "$syncdir")" || exit 1
    if ! remote_dir_exists "$remote"; then
        echo "Nothing to pull: remote '$remote' does not exist yet."
        return 0
    fi
    echo "Pulling (mirror remote -> local, including deletions):"
    echo "  Remote: $remote/"
    echo "  Local : $syncdir/"
    rsync "${RSYNC_OPTS[@]}" "$remote/" "$syncdir/" || exit 1
    now="$(date +%s)"
    set_local_ts "$syncdir" "$now"
}

status_both_dirs() {
    local syncdir="$1" remote push_has=0 pull_has=0 remote_newer=0
    remote="$(remote_path_for "$syncdir")" || exit 1
    # rsync-based detection
    if dry_changes_exist "$syncdir/" "$remote/"; then
        push_has=1
    elif [ $? -ne 1 ]; then
        die "rsync dry-run (push) failed; is the remote reachable?"
    fi
    if remote_dir_exists "$remote"; then
        if dry_changes_exist "$remote/" "$syncdir/"; then
            pull_has=1
        elif [ $? -ne 1 ]; then
            die "rsync dry-run (pull) failed; is the remote reachable?"
        fi
    fi
    # timestamp-based detection
    local lts rts
    lts="$(get_local_ts "$syncdir")"
    rts="$(get_remote_ts "$syncdir")"
    if [ "$rts" -gt "$lts" ]; then
        remote_newer=1
    fi
    # Decision logic
    if [ "$push_has" -eq 1 ] && { [ "$pull_has" -eq 1 ] || [ "$remote_newer" -eq 1 ]; }; then
        echo "There are changes in BOTH directions: you can 'push' and 'pull'."
        [ "$remote_newer" -eq 1 ] && echo "(Remote has newer changes since your last local sync.)"
    elif [ "$push_has" -eq 1 ]; then
        echo "There are LOCAL changes to push."
    elif [ "$pull_has" -eq 1 ] || [ "$remote_newer" -eq 1 ]; then
        echo "There are REMOTE changes to pull."
        [ "$remote_newer" -eq 1 ] && echo "(Someone else likely pushed after your last local sync.)"
    else
        echo "Up to date. Nothing to push or pull."
    fi
}

# ------------ main ------------
case "${1-}" in
-h | --help)
    usage
    exit 0
    ;;
init)
    do_init
    exit 0
    ;;
esac

# For push/pull/status we need rsync/awk, a syncdir, and SYNCFS_REMOTE
need rsync
need awk
syncdir="$(find_syncdir)" || die "no .syncfs found from $PWD upwards"
[ -d "$syncdir" ] || die "syncdir does not exist: $syncdir"
: "${SYNCFS_REMOTE:?SYNCFS_REMOTE environment variable must be set}"
ensure_remote_base_exists

case "${1-}" in
push) do_push "$syncdir" ;;
pull) do_pull "$syncdir" ;;
"") status_both_dirs "$syncdir" ;;
*)
    echo "Unknown subcommand: $1" >&2
    usage >&2
    exit 2
    ;;
esac
