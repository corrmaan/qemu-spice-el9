
# virt-manager and QEMU with SPICE support for Alma / Rocky / Oracle / RHEL 9 (aka el9)

The official virtualization packages for RHEL 9 lack support for hardware acceleration, and the drop in performance made my development environments unusuable. As a result my choices were rebuild the packages with SPICE support, or switch to a commercial/proprietary alternative. Ultimately I decided to rebuild the packages myself. 

Use the `build.sh` script to build the RPMs to `~/rpmbuild/RPMS`, which can then be copied to a repository.