
# virt-manager and QEMU with SPICE support for EL9 (Alma / Rocky / Oracle / RHEL 9)

Prerequisites:
- `dnf config-manager --set-enabled crb`
- `dnf install epel-release`
- `dnf update`
- `dnf install rpmdevtools createrepo`

Use the `build.sh` script to build RPMs to `~/rpmbuild/RPMS`, and SRPMs to `~/rpmbuild/SRPMS`, which can then be copied to your local repositories. Make sure to set your RPM repository's priority to less than the system default of 99 so that it is prioritized over the system repositories.

When [enabling virtualization in EL9](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_virtualization/assembly_enabling-virtualization-in-rhel-9_configuring-and-managing-virtualization), and when installing the virtualization hypervisor packages, make sure to also install `virt-manager`.