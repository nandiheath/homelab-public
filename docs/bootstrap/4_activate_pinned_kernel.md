# 4. Activate the pinned kernel

**Applies to:** initial bootstrap and destructive rebuild. It also applies during a cluster upgrade only when kernel maintenance is separately reviewed and authorized; it is never implied by K3s upgrade authorization.

## Overview

Install the exact Raspberry Pi kernel packages declared by private inventory, preserve the approved fallback kernel, and reboot the hosts serially. Never turn this into a general package, OS, firmware, or bootloader upgrade.

## Procedure

1. Complete step 2. For a rebuild, require the `cluster_absent` preflight and prove K3s remains absent. For an existing healthy cluster, use only the maintenance mode explicitly approved by the current task and follow its drain/PDB safeguards.
2. Read `kernel_running_release`, exact `raspi_kernel_packages`, and retained fallback release from private inventory. Confirm they match the operation guard and reviewed task. The current runbook pin is `5.15.0-1105-raspi`; do not silently substitute a newer value.
3. Confirm every host has sufficient `/boot/firmware` capacity and the retained fallback boot files before package installation.
4. Obtain the fresh exact confirmation required by the inventory pin, for example:

   ```text
   ACTIVATE KERNEL 5.15.0-1105-raspi ON <cluster-id>
   ```

5. For a clean rebuild, run:

   ```bash
   ansible-playbook -i "$INVENTORY" ansible/playbooks/kernel_upgrade.yaml \
     -e raspi_kernel_mode=cluster_absent \
     -e "{\"operation_guard_confirmation\":\"ACTIVATE KERNEL 5.15.0-1105-raspi ON ${CLUSTER_ID}\"}"
   ```

6. Allow only the exact `linux-image-raspi` and `linux-raspi` package pins. Do not run `dist-upgrade`, a generic latest upgrade, `autoremove`, firmware updates, bootloader updates, or an OS release upgrade.
7. Let the playbook reboot one node at a time. After each reboot require strict SSH recovery, the exact `uname -r`, no reboot-required marker, expected boot files, retained fallback kernel, and the expected K3s state for the selected mode.
8. Stop the whole phase if one node does not return or activates an unexpected kernel. Use physical/serial recovery; do not continue to the next node.
9. Record package, boot-file, active-kernel, fallback, and K3s-state evidence without copying private identity into public files.

## Expected boundary

Every node runs the exact reviewed kernel and retains one verified fallback. On a new or reset cluster, K3s is still absent. The source image's potentially mismatched kernel is now resolved; step 5 may install K3s under a new authorization.
