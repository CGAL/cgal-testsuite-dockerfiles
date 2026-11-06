#!/bin/bash
# Build CGAL testsuite Dockerfiles using multi-stage builds
#
# This script builds both standard and toolbox variants from a single
# multi-stage Dockerfile.
#
# Usage:
#   ./build.sh                          # Show help
#   ./build.sh debian-stable            # Build both variants
#   ./build.sh debian-stable --std-only # Build only standard
#   ./build.sh debian-stable --toolbox  # Build only toolbox
#   ./build.sh --all                    # Build all distributions
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REGISTRY="${REGISTRY:-localhost}"
NAMESPACE="${NAMESPACE:-cgal}"
IMAGE_NAME="${IMAGE_NAME:-testsuite}"
BUILD_STANDARD=1
BUILD_TOOLBOX=1
TARGET_VARIANTS=()
BUILD_ALL=0
PUSH_IMAGES=0

# Show usage
usage() {
  cat <<EOF
${BLUE}Build CGAL testsuite Docker images using multi-stage builds${NC}

Usage:
  $0 [VARIANT...] [OPTIONS]

Variants:
  debian-stable, ubuntu, fedora, archlinux, etc.
  Use --all to build all variants found

Options:
  --std-only     Build only the standard (non-toolbox) image
  --toolbox      Build only the toolbox variant
  --push         Push images to registry after building
  --registry URL Use custom registry (default: localhost)
  --help         Show this help message

Examples:
  $0 debian-stable              # Build both standard and toolbox
  $0 debian-stable --std-only   # Build only standard
  $0 debian-stable --toolbox    # Build only toolbox variant
  $0 --all                      # Build all variants
  $0 debian-stable --push       # Build and push to registry

Environment Variables:
  REGISTRY      Registry URL (default: localhost)
  NAMESPACE     Image namespace (default: cgal)
  IMAGE_NAME    Image name (default: testsuite)

EOF
}

# Parse arguments
if [ $# -eq 0 ]; then
  usage
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
  --help)
    usage
    exit 0
    ;;
  --all)
    BUILD_ALL=1
    shift
    ;;
  --std-only)
    BUILD_TOOLBOX=0
    shift
    ;;
  --toolbox)
    BUILD_STANDARD=0
    shift
    ;;
  --push)
    PUSH_IMAGES=1
    shift
    ;;
  --registry)
    REGISTRY="$2"
    shift 2
    ;;
  -*)
    echo -e "${RED}Unknown option: $1${NC}"
    usage
    exit 1
    ;;
  *)
    TARGET_VARIANTS+=("$1")
    shift
    ;;
  esac
done

# Normalize variant name
normalize_variant() {
  local name
  name=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
  # Keep the historical tag of this image
  case "$name" in
  ubuntu-gcc-master-cpp20-release | ubuntu-gcc-master-cxx20-release | ubuntu-gcc_master_cxx20-release)
    name=ubuntu-gcc_master_cxx20-release
    ;;
  esac
  echo "$name"
}

# List "variant:dir" pairs for all directories containing a Dockerfile
find_variants() {
  local dir
  for dir in */; do
    [ -f "$dir/Dockerfile" ] && echo "$(normalize_variant "${dir%/}"):${dir%/}"
  done
  return 0
}

# Print the directory of a variant, or fail if it does not exist
get_variant_dir() {
  local pair
  while read -r pair; do
    if [ "${pair%%:*}" = "$1" ]; then
      echo "${pair#*:}"
      return 0
    fi
  done < <(find_variants)
  return 1
}

# Build (and optionally push) one image.
# Arguments: variant, dir, Docker target, tag suffix ("" or "-toolbox")
build_image() {
  local variant="$1" dir="$2" target="$3" suffix="$4"
  local target_args=(--target "$target")
  local image="${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}:${variant}${suffix}"
  local commit_url=""

  # Same build arguments as the Makefile; user-provided --build-arg come last and win.
  if [ -n "${GITHUB_SHA:-}" ]; then
    commit_url="https://github.com/${GITHUB_REPOSITORY}/blob/${GITHUB_SHA}"
  fi
  local auto_args=(
    --build-arg "dockerfile_url=${commit_url}/${dir}/Dockerfile"
    --build-arg "image_tag=${image}"
  )

  echo -e "${BLUE}Building ${target} image: ${variant}${NC}"
  echo "  From: $dir/Dockerfile (target: $target)"
  echo "  Tag:  $image"
  echo ""

  # Derived images (FROM another testsuite image) pass base_image as a build arg
  if ! grep -q 'AS cgal-base' "$dir/Dockerfile"; then
    # Not expected to reach here since we've updated all derived images
    echo -e "${RED}Warning: $dir/Dockerfile is not multi-stage${NC}"
  fi

  # Extract the base image from the ARG line if this is a derived image
  if grep -q '^ARG base_image=' "$dir/Dockerfile"; then
    local base_image_default=$(grep '^ARG base_image=' "$dir/Dockerfile" | sed 's/^ARG base_image=//')
    # Replace the default registry/namespace/image with the actual ones we're using
    base_image_default=$(echo "$base_image_default" | sed "s|^cgal/testsuite-docker:|${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}:|")
    auto_args+=(--build-arg "base_image=${base_image_default}")
  fi

  if ! docker build --build-context root=. "${auto_args[@]}" "${target_args[@]}" -t "$image" "$dir"; then
    echo -e "${RED}✗ Failed to build: $image${NC}"
    return 1
  fi
  echo -e "${GREEN}✓ Built: $image${NC}"

  if [ "${PUSH_IMAGES:-0}" -eq 1 ]; then
    echo -e "${BLUE}Pushing: $image${NC}"
    if ! docker push "$image"; then
      echo -e "${RED}✗ Failed to push: $image${NC}"
      return 1
    fi
    echo -e "${GREEN}✓ Pushed: $image${NC}"
  fi
}

# Build the requested images of one variant and update the counters
build_variant() {
  local variant="$1" dir="$2"

  if [ $BUILD_STANDARD -eq 1 ]; then
    echo ""
    build_image "$variant" "$dir" cgal-base "" && : $((success_count++)) || : $((fail_count++))
  fi
  
  if [ $BUILD_TOOLBOX -eq 1 ]; then
    echo ""
    build_image "$variant" "$dir" cgal-toolbox "-toolbox" && : $((success_count++)) || : $((fail_count++))
  fi
}

# Main build logic
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     CGAL Testsuite Multi-Stage Docker Builder              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Registry:   $REGISTRY"
echo "  Namespace:  $NAMESPACE"
echo "  Image:      $IMAGE_NAME"
echo "  Standard:   $([ $BUILD_STANDARD -eq 1 ] && echo 'Yes' || echo 'No')"
echo "  Toolbox:    $([ $BUILD_TOOLBOX -eq 1 ] && echo 'Yes' || echo 'No')"
echo ""

success_count=0
fail_count=0

if [ $BUILD_ALL -eq 1 ]; then
  echo -e "${YELLOW}Finding all Dockerfile variants...${NC}"

  readarray -t variants < <(find_variants)
  if [ ${#variants[@]} -eq 0 ]; then
    echo -e "${RED}No Dockerfiles found!${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Found ${#variants[@]} variant(s):${NC}"
  for pair in "${variants[@]}"; do
    echo "  - ${pair%%:*}"
  done

  for pair in "${variants[@]}"; do
    build_variant "${pair%%:*}" "${pair#*:}"
  done
else
  for target_variant in "${TARGET_VARIANTS[@]}"; do
    variant=$(normalize_variant "$target_variant")
    if ! dir=$(get_variant_dir "$variant"); then
      echo -e "${RED}Error: Variant '$target_variant' not found${NC}"
      echo ""
      echo "Available variants:"
      find_variants | sed 's/:.*//; s/^/  - /'
      exit 1
    fi
    build_variant "$variant" "$dir"
  done
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Build Summary                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Successful builds:${NC} $success_count"
echo -e "${RED}✗ Failed builds:${NC} $fail_count"
echo ""

if [ $fail_count -eq 0 ]; then
  echo -e "${GREEN}All builds completed successfully!${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Test standard: docker run $REGISTRY/$NAMESPACE/$IMAGE_NAME:debian-stable"
  echo "  2. Test toolbox:  toolbox create --image $REGISTRY/$NAMESPACE/$IMAGE_NAME:debian-stable-toolbox"
  echo "  3. Enter toolbox: toolbox enter"
  if [ "${PUSH_IMAGES:-0}" -ne 1 ]; then
    echo "  4. Push images:   docker push $REGISTRY/$NAMESPACE/$IMAGE_NAME:*"
  fi
  exit 0
else
  echo -e "${RED}Some builds failed. Please check the output above.${NC}"
  exit 1
fi
