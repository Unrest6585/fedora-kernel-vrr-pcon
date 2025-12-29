# Fedora Kernel with AMD VRR PCON Patches

Automated builds of the Fedora 43 kernel with patches for AMD VRR (Variable Refresh Rate) over PCON (Protocol Converter) support.

## Patches Included

These patches enable HDMI VRR support for DP-to-HDMI 2.1 adapters on displays that don't natively support AMD FreeSync:

| Patch | Description | Issue |
|-------|-------------|-------|
| 0001 | Add Chrontel CH7218 to VRR PCON whitelist | [#4773](https://gitlab.freedesktop.org/drm/amd/-/issues/4773) |
| 0002-0005 | Enable HDMI VRR over PCON | [#4805](https://gitlab.freedesktop.org/drm/amd/-/issues/4805) |

### Tested Hardware

- **Adapters**: VMM7100, Chrontel CH7218-based (Ugreen model 85564)
- **Displays**: Samsung S95B, LG C4, Sony Bravia 8, Dell AW3423DWF

## Installation

### From COPR (Recommended)

```bash
# Enable the COPR repository
sudo dnf copr enable YOUR_USERNAME/kernel-vrr-pcon

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
git clone https://github.com/YOUR_USERNAME/fedora-kernel-vrr-patches.git
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

These patches are pending upstream inclusion. Once merged into the mainline kernel, they will automatically be included in future Fedora releases and this repository will no longer be needed.

- Issue #4773: CH7218 whitelist addition
- Issue #4805: HDMI VRR over PCON support (4-patch series)

## Credits

- **Patches by**: Tomasz Pakuła
- **Tested by**: Bernhard Berger

## License

The patches are licensed under GPL-2.0, matching the Linux kernel license.
