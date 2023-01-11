#!/usr/bin/env bash
set -e

sudo dnf config-manager --set-enabled crb
sudo dnf install epel-release
sudo dnf update
sudo dnf install gcc rpm-build rpm-devel rpmlint make python3 python3-future bash coreutils diffutils patch rpmdevtools createrepo yum-utils git-core

rpmdev-setuptree

dnf download --disablerepo=* \
    --repofrompath="fc36,https://mirrors.kernel.org/fedora/releases/36/Everything/source/tree/" \
    --source spice-gtk

dnf download --disablerepo=* \
    --repofrompath="rawhide,https://mirrors.kernel.org/fedora/development/rawhide/Everything/source/tree/" \
    --source \
        edk2 fcode-utils gi-docgen libcacard lzfse openbios python-pefile python-smartypants python-virt-firmware \
        qemu SLOF spice spice-protocol virglrenderer SDL2_image

rpm -ivh *.rpm
rm -rf *.rpm

# Patch the source/spec files.
cd ~/rpmbuild/SPECS/

patch -p1 < ${OLDPWD}/SLOF.spec.patch
patch -p1 < ${OLDPWD}/qemu.spec.patch
patch -p1 < ${OLDPWD}/spice-gtk.spec.patch
sed -i 's/defined rhel/defined nullified/g' edk2.spec
sed -i 's/defined fedora/defined rhel/g' edk2.spec

sudo dnf builddep lzfse.spec virglrenderer.spec libcacard.spec fcode-utils.spec

rpmbuild -ba lzfse.spec virglrenderer.spec libcacard.spec fcode-utils.spec

sudo rpm -i ~/rpmbuild/RPMS/x86_64/fcode-utils-1*.rpm

sudo dnf builddep openbios.spec
rpmbuild -ba openbios.spec

sudo rpm -e fcode-utils

sudo dnf builddep python-pefile.spec python-virt-firmware.spec
rpmbuild -ba python-pefile.spec python-virt-firmware.spec

sudo rpm -i \
    ~/rpmbuild/RPMS/noarch/python3-pefile-2*.rpm \
    ~/rpmbuild/RPMS/noarch/python3-virt-firmware-1*.rpm

sudo dnf builddep edk2.spec SLOF.spec spice-protocol.spec
rpmbuild -ba edk2.spec SLOF.spec spice-protocol.spec

sudo rpm -e python3-virt-firmware python3-pefile

sudo rpm -i \
    ~/rpmbuild/RPMS/x86_64/libcacard-2*.rpm \
    ~/rpmbuild/RPMS/x86_64/libcacard-devel-2*.rpm

sudo dnf builddep spice.spec SDL2_image.spec
rpmbuild -ba spice.spec SDL2_image.spec

sudo rpm -i \
    ~/rpmbuild/RPMS/x86_64/spice-server-0*.rpm \
    ~/rpmbuild/RPMS/x86_64/spice-server-devel-0*.rpm \
    ~/rpmbuild/RPMS/x86_64/virglrenderer-0*.rpm \
    ~/rpmbuild/RPMS/x86_64/virglrenderer-devel-0*.rpm \
    ~/rpmbuild/RPMS/x86_64/SDL2_image-2*.rpm \
    ~/rpmbuild/RPMS/x86_64/SDL2_image-devel-2*.rpm

sudo dnf builddep qemu.spec
rpmbuild -ba qemu.spec

sudo rpm -e spice-server spice-server-devel virglrenderer virglrenderer-devel SDL2_image SDL2_image-devel

sudo dnf builddep python-smartypants.spec gi-docgen.spec spice-gtk.spec
rpmbuild -ba python-smartypants.spec gi-docgen.spec spice-gtk.spec

sudo rpm -e libcacard libcacard-devel

cd -