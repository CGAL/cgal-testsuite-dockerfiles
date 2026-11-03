# Multi-Stage Dockerfile Approach for Toolbox Variants

## Overview

Instead of using Python scripts to generate Dockerfiles, this approach uses **Docker's native multi-stage builds** to define both standard and toolbox variants in a single Dockerfile.

## The Approach

Each Dockerfile has two build targets:

- **Stage 1 (`cgal-base`)**: Standard CGAL testsuite image (unchanged)
- **Stage 2 (`cgal-toolbox`)**: Toolbox variant built from stage 1

```dockerfile
# Stage 1: Standard image
FROM debian:stable as cgal-base
# ... standard CGAL configuration ...

# Stage 2: Toolbox variant
FROM cgal-base as cgal-toolbox
# ... add toolbox-specific configurations ...
```

Build whichever you need:

```bash
docker build --build-context root=. --target cgal-base -t cgal/testsuite:debian-stable .
docker build --build-context root=. --target cgal-toolbox -t cgal/testsuite:debian-stable-toolbox .
```

Pass `--build-context root=.` when building from a distribution directory; some Dockerfiles use `COPY --from=root` to access files at the repository root.

## Benefits

- ✅ **No Code Generation** - Single Dockerfile, Docker-native multi-stage builds
- ✅ **Simple** - No Python scripts, just Docker
- ✅ **Maintainable** - All variants in one file per distribution
- ✅ **Clear** - Both targets defined in same file
- ✅ **Efficient** - Build layers are shared between targets
- ✅ **Standard** - Uses Docker best practices

## File Structure

```plain
cgal-testsuite-dockerfiles/
├── Debian-stable/
│   ├── Dockerfile                    # Single multi-stage Dockerfile
│   │   ├── Stage: cgal-base         (standard image)
│   │   └── Stage: cgal-toolbox      (toolbox variant)
│   └── init.cmake
│
├── Ubuntu/
│   ├── Dockerfile                    # Single multi-stage Dockerfile
│   │   ├── Stage: cgal-base
│   │   └── Stage: cgal-toolbox
│   └── init.cmake
│
├── Fedora/
│   ├── Dockerfile                    # Single multi-stage Dockerfile
│   │   ├── Stage: cgal-base
│   │   └── Stage: cgal-toolbox
│   └── init.cmake
│
└── build.sh                  # Simple shell script to build both
```

## Creating a Multi-Stage Dockerfile

Here's the pattern for each distribution:

### For Debian/Ubuntu

```dockerfile
# STAGE 1: Standard CGAL testsuite image
FROM debian:stable as cgal-base

ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

# ... all standard CGAL installation ...
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libgmp-dev \
    # ... etc ...

ENV CGAL_TEST_PLATFORM="Debian-Stable"
COPY init.cmake /tmp/init.cmake

# STAGE 2: Toolbox variant
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox-debian" \
      usage="This image is meant to be used with the toolbox command"

# Remove apt configurations optimized for containers
RUN rm -f /etc/apt/apt.conf.d/docker-*

# Configure hostname resolution
RUN sed -Ei 's/^(hosts:.*)(\<files\>)\s*(.*)/\1\2 myhostname \3/' /etc/nsswitch.conf

# Install/ensure libnss-myhostname
RUN apt-get update && \
    apt-get install -y libnss-myhostname && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules
```

### For Fedora/RHEL

```dockerfile
# STAGE 1: Standard CGAL testsuite image
FROM fedora:latest as cgal-base

# ... standard CGAL installation ...

# STAGE 2: Toolbox variant
FROM cgal-base as cgal-toolbox

LABEL com.github.containers.toolbox="true" \
      name="cgal-toolbox-fedora"

# Remove dnf container configurations
RUN rm -f /etc/dnf/dnf.conf.d/container-*.conf

# Configure hostname resolution
RUN sed -Ei 's/^(hosts:.*)(\<files\>)\s*(.*)/\1\2 myhostname \3/' /etc/nsswitch.conf

# Install/ensure libnss-myhostname
RUN dnf install -y libnss-myhostname && dnf clean all

# Create required directories
RUN mkdir -p /usr/share/empty /etc/pkcs11/modules
```

## Building

### Build Script Method (Recommended)

The included `build.sh` script handles everything:

```bash
# Build both standard and toolbox for a variant
./build.sh debian-stable

# Build only standard
./build.sh debian-stable --std-only

# Build only toolbox
./build.sh debian-stable --toolbox

# Build all variants
./build.sh --all

# Build and push to registry
./build.sh debian-stable --push --registry docker.io/cgal
```

### Manual Docker Build

The named context `root=.` makes repository-root files available to Dockerfiles that use `COPY --from=root`.

```bash
# Build standard image
docker build --build-context root=. --target cgal-base \
             -t cgal/testsuite:debian-stable \
             Debian-stable/

# Build toolbox variant
docker build --build-context root=. --target cgal-toolbox \
             -t cgal/testsuite:debian-stable-toolbox \
             Debian-stable/
```

### Build Both with Single Command

```bash
# Standard
docker build --build-context root=. --target cgal-base -t cgal/testsuite:debian-stable Debian-stable/

# Toolbox (built from same Dockerfile)
docker build --build-context root=. --target cgal-toolbox -t cgal/testsuite:debian-stable-toolbox Debian-stable/
```

## Using the Build Script

### Basic Usage

```bash
# Make it executable
chmod +x build.sh

# Build a variant
./build.sh debian-stable

# See help
./build.sh --help
```

### Build All Variants

```bash
./build.sh --all
```

This finds all Dockerfile directories and builds both standard and toolbox variants for each.

### Build and Push

```bash
./build.sh --all --push --registry docker.io/cgal
```

Builds everything and pushes to the specified registry.

### Build Only Standard or Only Toolbox

```bash
# Only standard images
./build.sh --all --std-only

# Only toolbox variants
./build.sh --all --toolbox
```

## Usage After Building

### Standard Image (Unchanged)

```bash
# Run standard container
docker run -it cgal/testsuite:debian-stable bash

# Use in CI/CD (unchanged)
docker:
  image: cgal/testsuite:debian-stable
  script:
    - /tmp/run-testsuite.sh
```

### Toolbox Variant (New)

```bash
# Create toolbox environment
toolbox create --image localhost/cgal/testsuite:debian-stable-toolbox

# Enter environment
toolbox enter -c cgal-testsuite-debian-stable

# Run commands
toolbox run cmake --version
toolbox run gcc --version

# Or use in CI/CD
docker:
  image: cgal/testsuite:debian-stable-toolbox
  script:
    - toolbox create --image cgal/testsuite:debian-stable-toolbox
    - toolbox run /tmp/run-testsuite.sh
```

## Updating Dockerfiles

When you modify a Dockerfile with multi-stage builds:

1. Edit the standard image section (before `as cgal-toolbox`)
2. Rebuild both targets:

   ```bash
   ./build.sh debian-stable
   ```

The shared layers will be reused, so the build is efficient.

## Adding Toolbox to Existing Dockerfile

To convert an existing single-stage Dockerfile:

1. Add `as cgal-base` to the FROM line:

   ```dockerfile
   FROM debian:stable as cgal-base
   ```

2. Keep all existing configuration in stage 1

3. Add stage 2 at the end:

   ```dockerfile
   FROM cgal-base as cgal-toolbox
   LABEL com.github.containers.toolbox="true" \
         # ... metadata ...

   # Toolbox-specific configurations
   RUN rm -f /etc/apt/apt.conf.d/docker-*
   RUN sed -Ei 's/^(hosts:.*)(\<files\>)\s*(.*)/\1\2 myhostname \3/' /etc/nsswitch.conf
   RUN apt-get update && apt-get install -y libnss-myhostname && apt-get clean
   RUN mkdir -p /usr/share/empty /etc/pkcs11/modules
   ```

Done! Now build with `--target` to get either version.

## Comparison: Approaches

| Aspect | Multi-Stage | Python Generator |
| -------- | ------------- | ------------------ |
| Docker Native | ✅ Yes | ❌ No |
| Simplicity | ✅ Simple | ❌ Complex |
| No Scripts | ✅ Just shell | ❌ Python needed |
| Build Efficiency | ✅ Shared layers | ⚠️ Duplicate |
| Maintainability | ✅ All in one file | ⚠️ Generated files |
| Standard Practice | ✅ Industry standard | ❌ Custom tooling |

## Sharing Base Image Layers

One advantage of multi-stage: layers are shared!

When you build both targets:

```bash
docker build --build-context root=. --target cgal-base -t cgal/testsuite:debian-stable .
docker build --build-context root=. --target cgal-toolbox -t cgal/testsuite:debian-stable-toolbox .
```

The second build reuses all layers from the first build. Very efficient.

## Docker Compose (Optional)

You can also use docker-compose to build both targets:

```yaml
# docker-compose.build.yml
version: '3'

services:
  cgal-standard:
    build:
      context: ./Debian-stable
      target: cgal-base
    image: cgal/testsuite:debian-stable
    profiles: ["standard"]

  cgal-toolbox:
    build:
      context: ./Debian-stable
      target: cgal-toolbox
    image: cgal/testsuite:debian-stable-toolbox
    profiles: ["toolbox"]
```

Build with:

```bash
# Build standard
docker-compose -f docker-compose.build.yml build cgal-standard

# Build toolbox
docker-compose -f docker-compose.build.yml build cgal-toolbox

# Build both
docker-compose -f docker-compose.build.yml build
```

## Quick Reference

### Common Commands

```bash
# Make script executable
chmod +x build.sh

# List help
./build.sh --help

# Build one variant (both targets)
./build.sh debian-stable

# Build all variants
./build.sh --all

# Build only standard images
./build.sh --all --std-only

# Build only toolbox variants
./build.sh --all --toolbox

# Build and push to registry
./build.sh debian-stable --push --registry docker.io/cgal

# Manual Docker build
docker build --build-context root=. --target cgal-base -t cgal/testsuite:debian-stable Debian-stable/
docker build --build-context root=. --target cgal-toolbox -t cgal/testsuite:debian-stable-toolbox Debian-stable/
```

### Environment Variables

```bash
# Use custom registry
REGISTRY=quay.io ./build.sh debian-stable

# Use custom namespace
NAMESPACE=myorg ./build.sh debian-stable

# Use custom image name
IMAGE_NAME=cgal-dev ./build.sh debian-stable
```

## Examples

### Example 1: Build Debian Variant

```bash
./build.sh debian-stable
```

Builds:

- `localhost/cgal/testsuite:debian-stable`
- `localhost/cgal/testsuite:debian-stable-toolbox`

### Example 2: Build All and Push

```bash
./build.sh --all --push --registry docker.io/cgal
```

Finds all distributions and:

1. Builds all standard images
2. Builds all toolbox variants
3. Pushes all to docker.io/cgal

### Example 3: CI/CD Integration

```bash
#!/bin/bash
set -e

# Build in CI
./build.sh debian-stable

# Test both
docker run localhost/cgal/testsuite:debian-stable cmake --version
docker run localhost/cgal/testsuite:debian-stable-toolbox cmake --version

# Push if tests pass
docker push localhost/cgal/testsuite:debian-stable
docker push localhost/cgal/testsuite:debian-stable-toolbox
```

## Troubleshooting

### Q: How do I see what targets are available?

**A:** Look at the Dockerfile's `as <stage_name>` lines, or check the script output.

### Q: Can I modify a target?

**A:** Yes! Edit the Dockerfile and rebuild. The target definitions are just FROM stages.

### Q: Do the targets have to be named `cgal-base` and `cgal-toolbox`?

**A:** No, you can use any names. Just update the `--target` arguments in the build commands.

### Q: What if I only want the standard image?

**A:** Build with `--target cgal-base` only, or use `./build.sh debian-stable --std-only`.

### Q: Can I add more stages?

**A:** Absolutely! Add another `FROM cgal-base as custom-variant` with your configurations.

## Next Steps

1. **Update existing Dockerfiles** to add multi-stage support:
   - Change `FROM debian:stable` to `FROM debian:stable as cgal-base`
   - Add toolbox stage at the end

2. **Use the build script**: `./build.sh debian-stable`

3. **Test both variants**:

   ```bash
   docker run cgal/testsuite:debian-stable cmake --version
   toolbox create --image localhost/cgal/testsuite:debian-stable-toolbox
   toolbox enter
   ```

4. **Integrate into CI/CD**: Update your build pipelines to build both targets

## Resources

- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Build Documentation](https://docs.docker.com/engine/reference/commandline/build/)
- [Containers/Toolbox](https://github.com/containers/toolbox)
