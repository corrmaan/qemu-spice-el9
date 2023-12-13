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
        --source spice-gtk spice spice-protocol
    dnf -y download --disablerepo=* --enablerepo=appstream --source virt-manager qemu-kvm

    rpm -ivh *.src.rpm

cd -

cd ~/rpmbuild/SOURCES/

    patch -p1 < ${BASEDIR}/qemu-kvm.rhelpatch.patch

cd -

cd ~/rpmbuild/SPECS/

    patch -p1 < ${BASEDIR}/qemu-kvm.spec.patch
    patch -p1 < ${BASEDIR}/spice-gtk.spec.patch
    patch -p1 < ${BASEDIR}/virt-manager.spec.patch

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

cd -

sudo dnf -y history rollback ${DNFCHECKPOINTID}

rm -rfv ${TMPDIR}

createrepo ~/rpmbuild/RPMS/
createrepo ~/rpmbuild/SRPMS/