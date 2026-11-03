#!/bin/bash
# Check that images satisfy the Toolbx image requirements
# (https://containertoolbx.org/doc/#requirements).
#
# Usage:
#   ./check-toolbox.sh [--strict] IMAGE [IMAGE...]
#
# MUST / MUST NOT requirements are reported as FAIL and make the script exit
# with a non-zero status. SHOULD recommendations are reported as WARN, and are
# treated as failures only with --strict.
#
# The container engine is taken from $CONTAINER_ENGINE (default: docker, or
# podman if docker is not installed).

set -u

STRICT=0
IMAGES=()

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
  --strict) STRICT=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  -*)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 2
    ;;
  *) IMAGES+=("$1") ;;
  esac
  shift
done

if [ ${#IMAGES[@]} -eq 0 ]; then
  usage >&2
  exit 2
fi

if [ -z "${CONTAINER_ENGINE:-}" ]; then
  if command -v docker >/dev/null 2>&1; then
    CONTAINER_ENGINE=docker
  elif command -v podman >/dev/null 2>&1; then
    CONTAINER_ENGINE=podman
  else
    echo "Neither docker nor podman was found." >&2
    exit 2
  fi
fi

# POSIX sh probe, run as root inside a throw-away container of the image.
# It prints one "PASS|WARN|FAIL <message>" line per check.
read -r -d '' PROBE <<'EOF' || true
have() { command -v "$1" >/dev/null 2>&1; }
pass() { echo "PASS $*"; }
warn() { echo "WARN $*"; }
fail() { echo "FAIL $*"; }

# Directories must exist and root must be able to create a regular file in them.
dir_writable() {
  severity=$1; dir=$2
  if [ ! -d "$dir" ]; then
    $severity "$dir is missing"
  elif touch "$dir/.toolbox-check" 2>/dev/null; then
    rm -f "$dir/.toolbox-check"
    pass "$dir is present and writable"
  else
    fail "root cannot create a file in $dir"
  fi
}

# Files that must be absent or regular files.
regular_or_absent() {
  for f in "$@"; do
    if [ -L "$f" ] || { [ -e "$f" ] && [ ! -f "$f" ]; }; then
      fail "$f exists but is not a regular file"
    else
      pass "$f is absent or a regular file"
    fi
  done
}

# Commands
for c in capsh mount passwd useradd usermod ldconfig; do
  if have "$c"; then pass "command $c"; else fail "command $c is missing"; fi
done
if have test || [ -x /usr/bin/test ] || [ -x /bin/test ]; then
  pass "command test"
else
  fail "command test is missing"
fi
if have flatpak-spawn; then pass "command flatpak-spawn"; else warn "command flatpak-spawn is missing"; fi

# /home
if [ -z "$(ls -A /home 2>/dev/null)" ]; then
  pass "/home is empty"
else
  fail "/home is not empty: $(ls -A /home | tr '\n' ' ')"
fi

# Users that could collide with the host user ID
users=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {printf "%s(%s) ", $1, $3}')
if [ -z "$users" ]; then
  pass "no regular user defined (no UID clash with the host user)"
else
  fail "regular users defined, 'useradd' may fail for the host user: $users"
fi

# Host name resolution
regular_or_absent /etc/host.conf /etc/hosts /etc/resolv.conf
plugin=$(find /lib /lib64 /usr/lib /usr/lib64 -name libnss_myhostname.so.2 2>/dev/null | head -n 1)
if [ -n "$plugin" ]; then
  pass "libnss_myhostname.so.2 found ($plugin)"
else
  warn "libnss_myhostname.so.2 is missing"
fi
hosts=$(grep -E '^hosts:' /etc/nsswitch.conf 2>/dev/null)
case " $hosts " in
*" myhostname "*)
  before=${hosts%%myhostname*}
  if echo "$before" | grep -Eq '(^|[[:space:]])(m?dns[A-Za-z0-9_]*)([[:space:]]|$)'; then
    warn "myhostname has a too low priority in nsswitch.conf: $hosts"
  else
    pass "myhostname has a high priority in nsswitch.conf"
  fi
  ;;
*) warn "myhostname is not configured for hosts in nsswitch.conf" ;;
esac

# Kerberos, PKCS #11, dynamic linker, RPM
dir_writable warn /etc/krb5.conf.d
dir_writable warn /etc/pkcs11/modules
dir_writable warn /etc/ld.so.conf.d
if [ -f /etc/ld.so.cache ]; then pass "/etc/ld.so.cache is present"; else warn "/etc/ld.so.cache is missing"; fi
if have rpm; then dir_writable warn /usr/lib/rpm/macros.d; fi
found=
for p in /usr/lib/pkcs11 /usr/lib/aarch64-linux-gnu/pkcs11 /usr/lib/x86_64-linux-gnu/pkcs11 /usr/lib64/pkcs11; do
  [ -e "$p/p11-kit-client.so" ] && found=$p
done
if [ -n "$found" ]; then pass "p11-kit-client.so found in $found"; else warn "p11-kit-client.so is missing"; fi

# VTE snippets
for f in /etc/profile.d/vte.sh /etc/profile.d/vte.csh; do
  if [ -e "$f" ]; then pass "$f is present"; else warn "$f is missing"; fi
done

# /usr/share/empty
if [ -d /usr/share/empty ] && [ -z "$(ls -A /usr/share/empty)" ]; then
  pass "/usr/share/empty is an empty directory"
else
  warn "/usr/share/empty is missing or not empty"
fi

# sudo
if have sudo; then
  pass "command sudo"
  group=
  for g in sudo wheel; do
    if getent group "$g" >/dev/null && grep -hEq "^%$g[[:space:]]" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
      group=$g
      break
    fi
  done
  if [ -n "$group" ]; then
    pass "sudo is enabled for the existing group '$group'"
    if grep -hE "^%$group[[:space:]].*NOPASSWD" /etc/sudoers /etc/sudoers.d/* 2>/dev/null | grep -q .; then
      pass "sudo allows empty passwords (NOPASSWD)"
    else
      warn "sudo does not allow empty passwords for '$group'"
    fi
  else
    fail "sudo is not enabled for an existing 'sudo' or 'wheel' group"
  fi
else
  fail "command sudo is missing"
fi

# Time zone and machine ID
if [ -e /etc/localtime ] || [ -L /etc/localtime ]; then
  if [ -L /etc/localtime ]; then
    case "$(readlink /etc/localtime)" in
    *usr/share/zoneinfo/*) pass "/etc/localtime links into /usr/share/zoneinfo" ;;
    *) fail "/etc/localtime does not link into /usr/share/zoneinfo" ;;
    esac
  else
    fail "/etc/localtime is not a symbolic link"
  fi
else
  pass "/etc/localtime is absent"
fi
regular_or_absent /etc/timezone /etc/machine-id
EOF

TOTAL_FAIL=0
for image in "${IMAGES[@]}"; do
  echo "=== $image"
  if ! "$CONTAINER_ENGINE" image inspect "$image" >/dev/null 2>&1; then
    echo "FAIL image not found (build it first)"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    continue
  fi

  fails=0
  warns=0
  report() {
    case "$1" in
    PASS*) echo "  $1" ;;
    WARN*)
      echo "  $1"
      warns=$((warns + 1))
      ;;
    FAIL*)
      echo "  $1"
      fails=$((fails + 1))
      ;;
    esac
    if [ -n "${GITHUB_ACTIONS:-}" ]; then
      case "$1" in
      WARN*) echo "::warning title=${image}::${1#WARN }" ;;
      FAIL*) echo "::error title=${image}::${1#FAIL }" ;;
      esac
    fi
  }

  entrypoint=$("$CONTAINER_ENGINE" image inspect --format '{{json .Config.Entrypoint}}' "$image")
  case "$entrypoint" in
  null | '[]' | '') report "PASS no entry point" ;;
  *) report "FAIL the image specifies an entry point: $entrypoint" ;;
  esac

  label=$("$CONTAINER_ENGINE" image inspect --format '{{index .Config.Labels "com.github.containers.toolbox"}}' "$image")
  if [ "$label" = true ]; then
    report 'PASS label com.github.containers.toolbox="true"'
  else
    report 'WARN label com.github.containers.toolbox="true" is missing'
  fi

  output=$(printf '%s\n' "$PROBE" |
    "$CONTAINER_ENGINE" run --rm -i --user 0 --network none --entrypoint /bin/sh "$image" -s 2>&1)
  status=$?
  if [ $status -ne 0 ] && ! grep -Eq '^(PASS|WARN|FAIL) ' <<<"$output"; then
    report "FAIL could not run the checks (exit status $status): $output"
  else
    while IFS= read -r line; do
      [ -n "$line" ] && report "$line"
    done <<<"$output"
  fi

  echo "  -> $fails failure(s), $warns warning(s)"
  if [ $fails -gt 0 ] || { [ $STRICT -eq 1 ] && [ $warns -gt 0 ]; }; then
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
  fi
done

if [ $TOTAL_FAIL -gt 0 ]; then
  echo "$TOTAL_FAIL image(s) do not satisfy the Toolbx requirements."
  exit 1
fi
echo "All images satisfy the Toolbx requirements."
