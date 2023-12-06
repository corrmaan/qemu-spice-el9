#!/usr/bin/env bash
set -e

sudo dnf -y config-manager --set-enabled crb
sudo dnf -y install epel-release
sudo dnf -y update
sudo dnf -y install gcc rpm-build rpm-devel rpmlint make python3 bash coreutils diffutils patch rpmdevtools

dnf -y download --disablerepo=* \
    --repofrompath="fc36,http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/36/Everything/source/tree/" \
    --source spice-gtk spice spice-protocol
dnf -y download --disablerepo=* --enablerepo=appstream --source virt-manager qemu-kvm

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

sudo dnf -y builddep spice-protocol.spec
rpmbuild -ba spice-protocol.spec

sudo dnf -y install \
    ~/rpmbuild/RPMS/noarch/spice-protocol-*.rpm

sudo dnf -y builddep spice.spec
rpmbuild -ba spice.spec

sudo dnf -y install \
    ~/rpmbuild/RPMS/x86_64/spice-server-0.*.rpm \
    ~/rpmbuild/RPMS/x86_64/spice-server-devel-0.*.rpm

sudo dnf -y builddep qemu-kvm.spec
rpmbuild -ba qemu-kvm.spec

sudo dnf -y builddep spice-gtk.spec
rpmbuild -ba spice-gtk.spec

sudo dnf -y builddep virt-manager.spec
rpmbuild -ba virt-manager.spec

sudo dnf -y remove spice-protocol spice-server spice-server-devel

cd -