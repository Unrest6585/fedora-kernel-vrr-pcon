#!/bin/bash
# Build script for patched Fedora kernel
set -euo pipefail

FEDORA_VERSION="${FEDORA_VERSION:-44}"
KERNEL_NVR="${KERNEL_NVR:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
PATCHES_DIR="${SCRIPT_DIR}/patches"

echo "==> Setting up build environment..."
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [ -n "${KERNEL_NVR}" ]; then
    NVR="${KERNEL_NVR}"
    echo "==> Using pinned kernel NVR: ${NVR}"
else
    # Find the newest stable kernel NVR across Koji tags.
    echo "==> Looking up latest stable kernel NVR for f${FEDORA_VERSION}..."
    NVR=""
    for tag in \
        "f${FEDORA_VERSION}-updates" \
        "f${FEDORA_VERSION}"; do
        TAG_NVR=$(koji list-tagged --latest "${tag}" kernel 2>/dev/null \
            | awk 'NR>2 && /^kernel-/{print $1; exit}')
        if [ -n "${TAG_NVR}" ]; then
            echo "    Found in tag ${tag}: ${TAG_NVR}"
            if [ -z "${NVR}" ] || { rc=0; rpmdev-vercmp "${TAG_NVR}" "${NVR}" &>/dev/null || rc=$?; [ "$rc" -eq 11 ]; }; then
                NVR="${TAG_NVR}"
            fi
        fi
    done

    if [ -z "${NVR}" ]; then
        echo "Error: Could not determine kernel NVR from Koji"
        exit 1
    fi
    echo "==> Using newest stable: ${NVR}"
fi

# Download the SRPM from Koji.
SRPM="${NVR}.src.rpm"
if [ ! -f "${SRPM}" ]; then
    echo "==> Downloading ${SRPM} from Koji..."
    koji download-build --arch=src "${NVR}"
else
    echo "==> Using cached ${SRPM}"
fi

# Extract SRPM
echo "==> Extracting SRPM..."
rpm2cpio "${SRPM}" | cpio -idmv

# Copy patches
echo "==> Copying VRR patches..."
cp "${PATCHES_DIR}"/*.patch .

# Modify the spec file to include our patches
echo "==> Modifying kernel.spec..."

# Get the last patch number
LAST_PATCH=$(grep -E "^Patch[0-9]+:" kernel.spec | tail -1 | sed 's/Patch\([0-9]*\):.*/\1/')
NEXT_PATCH=$((LAST_PATCH + 1))

# Add patch definitions after the last existing patch
PATCH_DEFS=""
PATCH_APPLIES=""
for patch in "${PATCHES_DIR}"/*.patch; do
    pname=$(basename "${patch}")
    PATCH_DEFS="${PATCH_DEFS}Patch${NEXT_PATCH}: ${pname}\n"
    PATCH_APPLIES="${PATCH_APPLIES}ApplyOptionalPatch ${pname}\n"
    NEXT_PATCH=$((NEXT_PATCH + 1))
done

# Insert patch definitions
sed -i "/^Patch${LAST_PATCH}:/a\\
${PATCH_DEFS}" kernel.spec

# Find where patches are applied and add ours
# The Fedora kernel spec uses ApplyOptionalPatch function
sed -i "/^# END OF PATCH APPLICATIONS/i\\
# VRR PCON patches\\
${PATCH_APPLIES}" kernel.spec

# Append release suffix to the specrelease (before %{?buildid}%{?dist})
sed -i 's/^%define specrelease \([0-9]*\)\(%{?buildid}%{?dist}\)/%define specrelease \1.vrr.pcon\2/' kernel.spec

echo "==> Building SRPM..."
rpmbuild -bs kernel.spec \
    --define "_sourcedir ${BUILD_DIR}" \
    --define "_srcrpmdir ${BUILD_DIR}"

NEW_SRPM=$(ls -1t kernel-*.src.rpm | head -1)
echo "==> Created: ${NEW_SRPM}"
mv "${NEW_SRPM}" "${SCRIPT_DIR}/"

echo "==> Done! SRPM ready for COPR upload: ${SCRIPT_DIR}/${NEW_SRPM}"
