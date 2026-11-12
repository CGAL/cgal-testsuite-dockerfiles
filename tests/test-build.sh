#!/bin/bash
set -eu

root=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/cgal"
touch "$tmp/cgal/CMakeLists.txt"

cat > "$tmp/bin/docker" <<'EOF'
#!/bin/bash
printf '%s' "$1" >> "$DOCKER_LOG"
shift
printf '\t%s' "$@" >> "$DOCKER_LOG"
printf '\n' >> "$DOCKER_LOG"
EOF
chmod +x "$tmp/bin/docker"
export PATH="$tmp/bin:$PATH" DOCKER_LOG="$tmp/docker.log" CGAL_SOURCE_DIR="$tmp/cgal"
export REGISTRY=localhost NAMESPACE=cgal IMAGE_NAME=testsuite
cd "$root"

./build.sh Ubuntu-no-gmp-no-leda --test > "$tmp/output"
[ "$(grep -c '^build' "$DOCKER_LOG")" -eq 2 ]
[ "$(grep -c '^run' "$DOCKER_LOG")" -eq 1 ]
grep -Fq $'base_image=localhost/cgal/testsuite:ubuntu\t--target\tcgal-base' "$DOCKER_LOG"
grep -Fq $'base_image=localhost/cgal/testsuite:ubuntu\t--target\tcgal-toolbox' "$DOCKER_LOG"
grep -Fq $'image_tag=localhost/cgal/testsuite:ubuntu-no-gmp-no-leda\t' "$DOCKER_LOG"
grep -Fq $'image_tag=localhost/cgal/testsuite:ubuntu-no-gmp-no-leda-toolbox\t' "$DOCKER_LOG"

: > "$DOCKER_LOG"
./build.sh Ubuntu-no-gmp-no-leda --std-only > "$tmp/output"
[ "$(grep -c '^build' "$DOCKER_LOG")" -eq 1 ]
grep -Fq $'base_image=localhost/cgal/testsuite:ubuntu\t--target\tcgal-base' "$DOCKER_LOG"

: > "$DOCKER_LOG"
./build.sh Ubuntu-no-gmp-no-leda --toolbox > "$tmp/output"
[ "$(grep -c '^build' "$DOCKER_LOG")" -eq 1 ]
grep -Fq $'base_image=localhost/cgal/testsuite:ubuntu\t--target\tcgal-toolbox' "$DOCKER_LOG"

: > "$DOCKER_LOG"
./build.sh Debian-stable-Release > "$tmp/output"
grep -Fq $'base_image=localhost/cgal/testsuite:debian-stable\t--target\tcgal-base' "$DOCKER_LOG"
grep -Fq $'base_image=localhost/cgal/testsuite:debian-stable\t--target\tcgal-toolbox' "$DOCKER_LOG"

: > "$DOCKER_LOG"
./build.sh --all --test > "$tmp/output"
count=0
for file in */Dockerfile; do
  dir=${file%/Dockerfile}
  variant=$(printf '%s' "$dir" | tr '[:upper:]_' '[:lower:]-')
  if [ "$variant" = ubuntu-gcc-master-cpp20-release ]; then
    variant=ubuntu-gcc_master_cxx20-release
  fi
  image="localhost/cgal/testsuite:$variant"
  count=$((count + 1))
  grep -Fq $'\t--target\tcgal-base\t-t\t'"$image"$'\t' "$DOCKER_LOG"
  grep -Fq $'\t--target\tcgal-toolbox\t-t\t'"$image-toolbox"$'\t' "$DOCKER_LOG"
  grep -Fq $'\timage_tag='"$image"$'\t' "$DOCKER_LOG"
  grep -Fq $'\timage_tag='"$image-toolbox"$'\t' "$DOCKER_LOG"
  grep -Fxq 'FROM cgal-common AS cgal-base' "$file"
  grep -Fxq 'FROM cgal-common AS cgal-toolbox' "$file"
  awk '
    /^FROM .* AS cgal-common$/ { common=1; next }
    /^FROM cgal-common AS cgal-base$/ { common=0 }
    common && /^(ARG (dockerfile_url|image_tag)|ENV (DOCKERFILE_URL|IMAGE_TAG)=)/ { exit 1 }
  ' "$file"
  if grep -q '^ARG base_image=' "$file"; then
    base=$(sed -n 's|^ARG base_image=cgal/testsuite-docker:|localhost/cgal/testsuite:|p' "$file")
    grep -Fq "base_image=$base"$'\t--target\tcgal-base\t-t\t'"$image"$'\t' "$DOCKER_LOG"
    grep -Fq "base_image=$base"$'\t--target\tcgal-toolbox\t-t\t'"$image-toolbox"$'\t' "$DOCKER_LOG"
  fi
done
[ "$(grep -c '^build' "$DOCKER_LOG")" -eq $((count * 2)) ]
[ "$(grep -c '^run' "$DOCKER_LOG")" -eq "$count" ]

echo "build.sh tests passed"
