# Fedora Kernel with AMD VRR PCON Patches

Automated builds of the Fedora 43 kernel with patches for AMD VRR (Variable Refresh Rate) over PCON (Protocol Converter) support.

## Patches Included

These patches enable HDMI VRR support for DP-to-HDMI 2.1 adapters on displays that don't natively support AMD FreeSync:

| Patch | Description | Issue |
|-------|-------------|-------|
| 0001-0027 | v4 upstream AMD VRR, HDMI gaming features, and HDMI VRR over PCON series | [#4773](https://gitlab.freedesktop.org/drm/amd/-/issues/4773), [#4805](https://gitlab.freedesktop.org/drm/amd/-/issues/4805) |

### Patchset Changelog

This repository is currently based on **v4** of Tomasz Pakuła's upstream series:

- **v4**: Full 27-patch series for AMD VRR fixes, HDMI gaming features, HDMI VRR, ALLM, passive VRR properties, CH7218 PCON support, and HDMI VRR over PCON. This repo carries all 27 patches, with patches 23-27 rebased for Fedora 43's 7.0.2 kernel source layout.
- **v3**: Expanded the earlier PCON-only work into a 19-patch AMD VRR and HDMI gaming features series, including VTEM/HF-VSIF work and HDMI VRR plumbing.
- **v2**: Earlier HDMI VRR over PCON patchset used by this repo before Fedora 7.0.x; superseded by the broader v3/v4 series.
- **v1**: Initial HDMI VRR over PCON work, superseded upstream.

Upstream v4 thread: [`[PATCH v4 00/27] drm/amd: VRR fixes, HDMI Gaming Features`](https://www.mail-archive.com/dri-devel%40lists.freedesktop.org/msg589340.html).

### Tested Hardware

- **Adapters**: VMM7100, Chrontel CH7218-based (Ugreen model 85564)
- **Displays**: Samsung S95B, LG C1, LG C4, Sony Bravia 8, Dell AW3423DWF

## Installation

### From COPR (Recommended)

```bash
# Enable the COPR repository
sudo dnf copr enable sneed/kernel-vrr-pcon

# Install the patched kernel
sudo dnf install kernel

# Reboot to use the new kernel
sudo reboot
```

### Manual Build

```bash
# Install build dependencies
sudo dnf install rpm-build rpmdevtools dnf-plugins-core cpio

# Clone this repository
git clone https://github.com/sneed/fedora-kernel-vrr-patches.git
cd fedora-kernel-vrr-patches

# Run the build script
chmod +x build.sh
./build.sh

# Install the resulting SRPM or build locally
rpmbuild --rebuild kernel-*.src.rpm
```

## GitHub Actions Setup

To enable automatic builds when new Fedora kernels are released:

### 1. Create a COPR API Token

1. Go to https://copr.fedorainfracloud.org/api/
2. Log in with your Fedora Account
3. Copy your API credentials

### 2. Add GitHub Secrets

Add these secrets to your repository (Settings → Secrets and variables → Actions):

| Secret | Description |
|--------|-------------|
| `COPR_LOGIN` | Your COPR login token |
| `COPR_USERNAME` | Your COPR/Fedora username |
| `COPR_TOKEN` | Your COPR API token |

### 3. Workflow Triggers

The workflow runs:
- **Daily** at 6 AM UTC to check for new kernels
- **On push** when patches or workflow files change
- **Manually** via workflow_dispatch (with optional force build)

## Configuration

Edit `.github/workflows/build.yml` to customize:

```yaml
env:
  FEDORA_VERSION: '43'        # Target Fedora version
  COPR_PROJECT: 'kernel-vrr-pcon'  # COPR project name
```

## Upstream Status

These patches track the v4 upstream series posted on February 16, 2026: [`[PATCH v4 00/27] drm/amd: VRR fixes, HDMI Gaming Features`](https://www.mail-archive.com/dri-devel%40lists.freedesktop.org/msg589340.html).

This repository carries the full v4 27-patch series. Patches 23-27 were rebased for Fedora 43's 7.0.2 kernel source layout because the upstream hunks only needed context updates in DRM core files.

Once the relevant patches are merged into the mainline kernel, they will automatically be included in future Fedora releases and this repository will no longer be needed.

- Issue #4773: CH7218 whitelist addition
- Issue #4805: HDMI VRR over PCON support

## Credits

- **Patches by**: Tomasz Pakuła
- **Tested by**: Bernhard Berger

## License

The patches are licensed under GPL-2.0, matching the Linux kernel license.
