#!/bin/bash
# Build CGAL testsuite Dockerfiles using multi-stage builds
#
# This script builds both standard and toolbox variants from a single
# multi-stage Dockerfile.
#
# Usage:
#   ./build-toolbox.sh                          # Show help
#   ./build-toolbox.sh debian-stable            # Build both variants
#   ./build-toolbox.sh debian-stable --std-only # Build only standard
#   ./build-toolbox.sh debian-stable --toolbox  # Build only toolbox
#   ./build-toolbox.sh --all                    # Build all distributions
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
TARGET_VARIANT=""

# Show usage
usage() {
  cat <<EOF
${BLUE}Build CGAL testsuite Docker images using multi-stage builds${NC}

Usage:
  $0 [VARIANT] [OPTIONS]

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
    TARGET_VARIANT="all"
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
    TARGET_VARIANT="$1"
    shift
    ;;
  esac
done

# Find variants
find_variants() {
  local variants=()
  for dir in */; do
    if [ -f "$dir/Dockerfile" ] && [ "$dir" != "Dockerfiles.toolbox/" ]; then
      # Convert to lowercase variant name
      local name
      name=$(basename "$dir" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
      variants+=("$name:$dir")
    fi
  done
  echo "${variants[@]}"
}

# Normalize variant name
normalize_variant() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
}

# Check if variant directory exists
get_variant_dir() {
  local variant="$1"
  for dir in */; do
    local dirname
    dirname=$(basename "$dir" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
    if [ "$dirname" = "$variant" ]; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

# Build standard image
build_standard() {
  local variant="$1"
  local dir="$2"
  local image="${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}:${variant}"

  echo -e "${BLUE}Building standard image: ${variant}${NC}"
  echo "  From: $dir/Dockerfile (target: cgal-base)"
  echo "  Tag:  $image"
  echo ""

  if docker build --build-context root=. --target cgal-base -t "$image" "$dir"; then
    echo -e "${GREEN}✓ Built: $image${NC}"

    if [ "${PUSH_IMAGES:-0}" -eq 1 ]; then
      echo -e "${BLUE}Pushing: $image${NC}"
      if docker push "$image"; then
        echo -e "${GREEN}✓ Pushed: $image${NC}"
      else
        echo -e "${RED}✗ Failed to push: $image${NC}"
        return 1
      fi
    fi
    return 0
  else
    echo -e "${RED}✗ Failed to build: $image${NC}"
    return 1
  fi
}

# Build toolbox variant
build_toolbox() {
  local variant="$1"
  local dir="$2"
  local image="${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}:${variant}-toolbox"

  echo -e "${BLUE}Building toolbox variant: ${variant}${NC}"
  echo "  From: $dir/Dockerfile (target: cgal-toolbox)"
  echo "  Tag:  $image"
  echo ""

  if docker build --build-context root=. --target cgal-toolbox -t "$image" "$dir"; then
    echo -e "${GREEN}✓ Built: $image${NC}"

    if [ "${PUSH_IMAGES:-0}" -eq 1 ]; then
      echo -e "${BLUE}Pushing: $image${NC}"
      if docker push "$image"; then
        echo -e "${GREEN}✓ Pushed: $image${NC}"
      else
        echo -e "${RED}✗ Failed to push: $image${NC}"
        return 1
      fi
    fi
    return 0
  else
    echo -e "${RED}✗ Failed to build: $image${NC}"
    return 1
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

if [ "$TARGET_VARIANT" = "all" ]; then
  # Build all variants
  echo -e "${YELLOW}Finding all Dockerfile variants...${NC}"
  echo ""

  readarray -t variants_raw < <(find_variants)

  if [ ${#variants_raw[@]} -eq 0 ]; then
    echo -e "${RED}No Dockerfiles found!${NC}"
    exit 1
  fi

  # Parse variant:dir pairs
  declare -a variant_names
  declare -a variant_dirs
  for pair in "${variants_raw[@]}"; do
    variant_names+=("${pair%%:*}")
    variant_dirs+=("${pair##*:}")
  done

  echo -e "${YELLOW}Found ${#variant_names[@]} variant(s):${NC}"
  for v in "${variant_names[@]}"; do
    echo "  - $v"
  done
  echo ""

  # Build each variant
  for i in "${!variant_names[@]}"; do
    variant="${variant_names[$i]}"
    dir="${variant_dirs[$i]}"

    echo ""

    if [ $BUILD_STANDARD -eq 1 ]; then
      build_standard "$variant" "$dir" && : $((success_count++)) || : $((fail_count++))
    fi

    if [ $BUILD_TOOLBOX -eq 1 ]; then
      echo ""
      build_toolbox "$variant" "$dir" && : $((success_count++)) || : $((fail_count++))
    fi
  done
else
  # Build specific variant
  variant=$(normalize_variant "$TARGET_VARIANT")
  dir=$(get_variant_dir "$variant")

  if [ -z "$dir" ]; then
    echo -e "${RED}Error: Variant '$TARGET_VARIANT' not found${NC}"
    echo ""
    echo "Available variants:"
    for pair in $(find_variants); do
      echo "  - ${pair%%:*}"
    done
    exit 1
  fi

  if [ $BUILD_STANDARD -eq 1 ]; then
    build_standard "$variant" "$dir" && : $((success_count++)) || : $((fail_count++))
  fi

  if [ $BUILD_TOOLBOX -eq 1 ]; then
    echo ""
    build_toolbox "$variant" "$dir" && : $((success_count++)) || : $((fail_count++))
  fi
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
