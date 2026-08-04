# 1. Install the Raspberry Pis

**Applies to:** initial host bootstrap only. **Not a routine cluster-upgrade step.** Skip this step when rebuilding the existing hosts and their Ubuntu, SSH, network, and hardware identity must be preserved.

## Overview

Install the approved ARM64 Ubuntu Server image on exactly three Raspberry Pis, establish unique host identities and wired networking, and capture SSH host keys through a trusted local channel. This step creates hosts, not a Kubernetes cluster.

## Procedure

1. Confirm the approved Raspberry Pi model, boot medium, Ubuntu release/image, and image checksum in the current private task or inventory. Do not infer production values from this public guide.
2. Confirm physical or serial-console access to every node. Keep the previous boot medium available until the new host passes step 2.
3. Flash the checksum-verified ARM64 image with Raspberry Pi Imager or an equivalent local tool. Do one node at a time so identity cannot be swapped.
4. Configure cloud-init on the boot volume with:
   - one unique hostname per inventory server;
   - the approved administrator account and public SSH key;
   - password SSH disabled;
   - wired Ethernet DHCP enabled and Wi-Fi disabled unless the private design explicitly says otherwise;
   - memory cgroups enabled for K3s;
   - only the reviewed CA and PoE HAT settings required by the hardware.
5. Treat `ansible/roles/raspberry_pi/files/scripts/setup-boot-volume.sh` as a legacy helper, not an unattended interface. It assumes macOS `/Volumes/system-boot`, local `credentials/certs/`, `~/.ssh/id_rsa.pub`, a particular `cmdline.txt`, and PoE HAT settings. Review every generated file before ejecting the boot medium; replace workstation-specific inputs through the approved private boundary rather than editing secrets into Git.
6. Boot each node separately. From its trusted local console, record the hostname, board identity, active OS, network interface, and active SSH host public key plus SHA256 fingerprint in private inventory or handoff evidence.
7. Reserve or confirm the node address outside conflicting pools. Do not publish the address or topology here.
8. Do not accept an SSH first-use prompt. Step 2 installs the independently verified key in the controller trust store and proves strict access.

## Expected boundary

- Exactly three reachable Ubuntu hosts exist with distinct reviewed identities.
- No K3s service, data directory, CNI state, kubeconfig, or cluster token has been created.
- Host keys were observed locally, but controller trust and all lifecycle inputs still require step 2.
- The image kernel may differ from the cluster pin. That is expected only until step 4; do not run a general OS or firmware upgrade to correct it.
