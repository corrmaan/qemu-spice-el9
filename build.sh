#!/usr/bin/env bash
set -e

rpmdev-setuptree
rpmdev-wipetree

BASEDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TMPDIR=$(mktemp -d)
DNFCHECKPOINTID=$(dnf history | head -n 3 | tail -n1 | xargs | cut -d ' ' -f 1)

cd ${TMPDIR}

    dnf -y download --disablerepo=* \
        --repofrompath="fc36,http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/36/Everything/source/tree/" \
        --source spice-gtk spice-protocol
    dnf -y download --disablerepo=* \
        --repofrompath="fc36,http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/36/Everything/source/tree/" \
        --source spice
    dnf -y download --disablerepo=* --enablerepo=appstream --source seavgabios-bin qemu-kvm virt-manager

    rpm -ivh *.src.rpm

cd -

cd ~/rpmbuild/SOURCES/

    git init && git add -A && git commit -m "Initial commit"

    patch -p1 < ${BASEDIR}/qemu-kvm.kvm-redhat-enable-CONFIG_SPICE.patch
    git add -A && git commit -m "qemu-kvm.kvm-redhat-enable-CONFIG_SPICE.patch"

    patch -p1 < ${BASEDIR}/qemu-kvm.kvm-redhat-enable-CONFIG_TDX.patch
    git add -A && git commit -m "qemu-kvm.kvm-redhat-enable-CONFIG_TDX.patch"

    patch -p1 < ${BASEDIR}/seabios.qxl.patch
    git add -A && git commit -m "seabios.qxl.patch"

cd -

cd ~/rpmbuild/SPECS/

    git init && git add -A && git commit -m "Initial commit"

    ### qemu-kvm

    sudo dnf -y builddep spice-protocol.spec
    rpmbuild -ba spice-protocol.spec
    sudo dnf -y install \
        ~/rpmbuild/RPMS/noarch/spice-protocol-*.rpm

    sudo dnf -y builddep spice.spec
    rpmbuild -ba spice.spec
    sudo dnf -y install \
        ~/rpmbuild/RPMS/x86_64/spice-server-0.*.rpm \
        ~/rpmbuild/RPMS/x86_64/spice-server-devel-0.*.rpm

    patch -p1 < ${BASEDIR}/qemu-kvm.spec.patch
    git add -A && git commit -m "qemu-kvm.spec.patch"
    sudo dnf -y builddep qemu-kvm.spec
    rpmbuild -ba qemu-kvm.spec

    ### virt-manager

    patch -p1 < ${BASEDIR}/spice-gtk.spec.patch
    git add -A && git commit -m "spice-gtk.spec.patch"
    sudo dnf -y builddep spice-gtk.spec
    rpmbuild -ba spice-gtk.spec

    patch -p1 < ${BASEDIR}/virt-manager.spec.patch
    git add -A && git commit -m "virt-manager.spec.patch"
    sudo dnf -y builddep virt-manager.spec
    rpmbuild -ba virt-manager.spec

    ### seabios

    patch -p1 < ${BASEDIR}/seabios.spec.patch
    git add -A && git commit -m "seabios.spec.patch"
    sudo dnf -y builddep seabios.spec
    rpmbuild -ba seabios.spec

cd -

sudo dnf -y history rollback ${DNFCHECKPOINTID}

rm -rfv ${TMPDIR}

createrepo ~/rpmbuild/RPMS/
createrepo ~/rpmbuild/SRPMS/
