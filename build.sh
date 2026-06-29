#!/usr/bin/env bash
set -e

BASEDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TMPDIR=$(mktemp -d)
TMPREPO=$(mktemp --suffix=.repo)
DNFCHECKPOINTID=$(dnf history | head -n 3 | tail -n1 | xargs | cut -d ' ' -f 1)
REPODIR="/etc/yum.repos.d"

rpmdev-setuptree
rpmdev-wipetree
createrepo ~/rpmbuild/RPMS/

cat << EOF > ${TMPREPO}
[tmp]
name=Temporary Repository
baseurl=file://${HOME}/rpmbuild/RPMS
enabled=1
gpgcheck=0
priority=1
EOF

sudo cp -av ${TMPREPO} ${REPODIR}/$(basename ${TMPREPO})
sudo chmod -v --reference=${REPODIR}/epel.repo ${REPODIR}/$(basename ${TMPREPO})
sudo chown -v --reference=${REPODIR}/epel.repo ${REPODIR}/$(basename ${TMPREPO})

cd ${TMPDIR}

    dnf -y download --disablerepo=* --enablerepo=appstream --source seavgabios-bin qemu-kvm virt-manager

    rm -rfv $(ls -1 qemu-kvm-*.src.rpm | tail -n 1)

    dnf -y download --disablerepo=* \
        --repofrompath="fc44releases,http://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/source/tree/" \
        --repofrompath="fc44updates,http://download.fedoraproject.org/pub/fedora/linux/updates/44/Everything/source/tree/" \
        --source spice spice-gtk spice-protocol

    rpm -ivh *.src.rpm

cd -

cd ~/rpmbuild/SOURCES/

    git init && git add -A && git commit -m "Initial commit"

    patch -p1 < ${BASEDIR}/qemu-kvm.kvm-redhat-enable-CONFIG_SPICE.patch
    git add -A && git commit -m "qemu-kvm.kvm-redhat-enable-CONFIG_SPICE.patch"

    patch -p1 < ${BASEDIR}/seabios.qxl.patch
    git add -A && git commit -m "seabios.qxl.patch"

cd -

cd ~/rpmbuild/SPECS/

    git init && git add -A && git commit -m "Initial commit"

    ### qemu-kvm

    sudo dnf -y --refresh builddep spice-protocol.spec
    rpmbuild -ba spice-protocol.spec
    createrepo ~/rpmbuild/RPMS/

    sudo dnf -y --refresh builddep spice.spec
    rpmbuild -ba spice.spec
    createrepo ~/rpmbuild/RPMS/

    patch -p1 < ${BASEDIR}/qemu-kvm.spec.patch
    git add -A && git commit -m "qemu-kvm.spec.patch"
    sudo dnf -y --refresh builddep qemu-kvm.spec
    rpmbuild -ba --define='distsuffix _8' qemu-kvm.spec
    createrepo ~/rpmbuild/RPMS/

    ### virt-manager

    patch -p1 < ${BASEDIR}/spice-gtk.spec.patch
    git add -A && git commit -m "spice-gtk.spec.patch"
    sudo dnf -y --refresh builddep spice-gtk.spec
    rpmbuild -ba spice-gtk.spec
    createrepo ~/rpmbuild/RPMS/

    patch -p1 < ${BASEDIR}/virt-manager.spec.patch
    git add -A && git commit -m "virt-manager.spec.patch"
    sudo dnf -y --refresh builddep virt-manager.spec
    rpmbuild -ba virt-manager.spec
    createrepo ~/rpmbuild/RPMS/

    ### seabios

    patch -p1 < ${BASEDIR}/seabios.spec.patch
    git add -A && git commit -m "seabios.spec.patch"
    sudo dnf -y --refresh builddep seabios.spec
    rpmbuild -ba seabios.spec
    createrepo ~/rpmbuild/RPMS/

cd -

createrepo ~/rpmbuild/SRPMS/

sudo dnf -y history rollback ${DNFCHECKPOINTID}

rm -rfv ${TMPREPO} ${TMPDIR}