#!/usr/bin/env bash
set -e

sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
sudo dnf update
sudo dnf install gcc rpm-build rpm-devel rpmlint make python3 bash coreutils diffutils patch rpmdevtools

dnf download --disablerepo=* \
    --repofrompath="fc36,https://download.fedoraproject.org/pub/fedora/linux/releases/36/Everything/source/tree/" \
    --source spice-gtk spice spice-protocol libcacard
dnf download --source virt-manager qemu-kvm

rpmdev-setuptree
rpm -ivh *.rpm
rm -rf *.rpm

cd ~/rpmbuild/SOURCES/

git init && git add -A && git commit -m "Initial commit"

patch -p1 < ${OLDPWD}/qemu-kvm.rhelpatch.patch
git add -A && git commit -m "Enable QXL and IVSHMEM"

cd -

cd ~/rpmbuild/SPECS/

git init && git add -A && git commit -m "Initial commit"

patch -p1 < ${OLDPWD}/qemu-kvm.spec.patch
git add qemu-kvm.spec && git commit -m "qemu-kvm.spec patch"

patch -p1 < ${OLDPWD}/spice-gtk.spec.patch
git add spice-gtk.spec && git commit -m "spice-gtk.spec patch"

patch -p1 < ${OLDPWD}/virt-manager.spec.patch
git add virt-manager.spec && git commit -m "virt-manager.spec patch"

sudo dnf builddep libcacard.spec
rpmbuild -ba libcacard.spec

sudo dnf builddep  spice-protocol.spec
rpmbuild -ba spice-protocol.spec

sudo dnf install \
    ~/rpmbuild/RPMS/x86_64/libcacard-2.8.1-2.el9.x86_64.rpm \
    ~/rpmbuild/RPMS/x86_64/libcacard-devel-2.8.1-2.el9.x86_64.rpm

sudo dnf builddep spice.spec
rpmbuild -ba spice.spec

sudo dnf install \
    ~/rpmbuild/RPMS/x86_64/spice-server-0.15.0-4.el9.x86_64.rpm \
    ~/rpmbuild/RPMS/x86_64/spice-server-devel-0.15.0-4.el9.x86_64.rpm

sudo dnf builddep qemu-kvm.spec
rpmbuild -ba qemu-kvm.spec

sudo dnf builddep spice-gtk.spec
rpmbuild -ba spice-gtk.spec

sudo dnf builddep virt-manager.spec
rpmbuild -ba virt-manager.spec

cd -